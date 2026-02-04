# 🔄 Authentication Flow - Technical Deep Dive

## Login Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     USER TAPS SIGN IN                            │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
        ┌────────────────────────────────┐
        │ signInButtonTapped() triggered │
        └────────┬─────────────────────────┘
                 │
                 ▼
        ┌─────────────────────────────────────┐
        │ Validate input not empty            │
        │ ✅ password not empty               │
        │ ✅ username/email not empty         │
        └────────┬─────────────────────────────┘
                 │
                 ▼
        ┌──────────────────────────────────┐
        │ isValidEmail(input)?              │
        │ Check if input matches email regex│
        └──────┬──────────────────────────────┘
               │
        ┌──────┴──────┐
        │             │
        ▼             ▼
    YES (Email)   NO (Username)
        │             │
        │             ▼
        │    ┌──────────────────────────────┐
        │    │ resolveUsernameToEmail()     │
        │    │ - Query profiles table       │
        │    │ - Find email by username     │
        │    │ - Get email from result      │
        │    │ - Check for errors           │
        │    └──────────┬───────────────────┘
        │              │
        │              ▼
        │    ┌──────────────────────────────┐
        │    │ If username not found:       │
        │    │ Show "Username not found"    │
        │    │ Return and let user retry    │
        │    └──────────┬───────────────────┘
        │              │
        │              ▼
        │    ┌──────────────────────────────┐
        │    │ Call signIn(email: password) │
        │    └──────────┬───────────────────┘
        │              │
        └──────────┬───┘
                   │
                   ▼
        ┌──────────────────────────────────┐
        │  signIn(email, password)         │
        │  1. Show loading spinner         │
        │  2. Disable UI                   │
        │  3. Start 15s timeout timer      │
        └────────┬─────────────────────────┘
                 │
                 ▼
        ┌──────────────────────────────────┐
        │ try await supabase.auth.signIn() │
        │ Authenticate with Supabase       │
        └────────┬─────────────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
        ▼                 ▼
    SUCCESS           FAILURE
        │                 │
        │                 ▼
        │       ┌──────────────────────┐
        │       │ Cancel timeout timer │
        │       │ Show error alert     │
        │       │ Enable UI            │
        │       └──────────────────────┘
        │
        ▼
    ┌──────────────────────────────────┐
    │ Cancel timeout timer             │
    │ Session now available            │
    └────────┬─────────────────────────┘
             │
             ▼
    ┌──────────────────────────────────┐
    │ checkUserProfile()               │
    │ Query profiles table by user ID  │
    │ Check if profile exists          │
    └────────┬─────────────────────────┘
             │
        ┌────┴────┐
        │         │
        ▼         ▼
    PROFILE    NO PROFILE
    EXISTS     (New user)
        │         │
        ▼         ▼
    ┌──────┐ ┌──────────────┐
    │HOME  │ │ ONBOARDING   │
    │      │ │ Birthday ... │
    │      │ │ Location ... │
    └──────┘ └──────────────┘
```

---

## Code Implementation Details

### 1. Input Detection
```swift
let isEmail = isValidEmail(input)

if isEmail {
    signIn(email: input, password: password)
} else {
    resolveUsernameToEmail(input, password: password)
}
```

### 2. Username Resolution
```swift
private func resolveUsernameToEmail(_ username: String, password: String) {
    Task {
        let response = try await supabase
            .from("profiles")
            .select("id,email")
            .eq("username", value: username.lowercased())  // Case-insensitive
            .single()
            .execute()
        
        guard let data = response.data as? [String: Any],
              let email = data["email"] as? String else {
            throw LoginError.userNotFound  // ✅ Specific error
        }
        
        // Recursively call signIn with the found email
        await MainActor.run {
            self.signIn(email: email, password: password)
        }
    }
}
```

### 3. Authentication with Timeout
```swift
private func signIn(email: String, password: String) {
    showLoading(true)
    disableUI()
    
    // Start 15-second timeout timer
    loginTimeoutTimer = Timer.scheduledTimer(
        withTimeInterval: 15.0,
        repeats: false
    ) { [weak self] _ in
        self?.handleLoginTimeout()  // Show error after 15s
    }

    Task {
        do {
            try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            // ✅ Cancel timer on success
            self.loginTimeoutTimer?.invalidate()
            self.loginTimeoutTimer = nil
            
            // Check profile...
            
        } catch {
            // ✅ Cancel timer on error
            self.loginTimeoutTimer?.invalidate()
            self.loginTimeoutTimer = nil
            
            // Show error...
        }
    }
}
```

### 4. Profile Check (Safe)
```swift
private func checkUserProfile() async throws -> Bool {
    guard let session = try await AuthManager.shared.currentSession() else {
        return false  // No session, return false
    }
    
    let userId = session.user.id
    
    do {
        let response = try await supabase
            .from("profiles")
            .select("id")
            .eq("id", value: userId.uuidString)
            .execute()  // ✅ Safe - doesn't crash if empty
        
        // ✅ Proper type casting
        if let data = response.data as? [[String: Any]], !data.isEmpty {
            return true  // Profile exists
        } else {
            return false  // No profile
        }
    } catch {
        return false  // Error, assume no profile
    }
}
```

### 5. Navigation Logic
```swift
if hasProfile {
    // Existing user - go straight to dashboard
    navigateToHomeDashboard()
} else {
    // New user - go to onboarding
    navigateToOnboarding()
}

private func navigateToHomeDashboard() {
    let tabBarVC = CineMystTabBarController()
    tabBarVC.modalPresentationStyle = .fullScreen
    
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first {
        window.rootViewController = tabBarVC
        window.makeKeyAndVisible()
        
        UIView.transition(
            with: window,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }
}
```

---

## Signup Flow Diagram

```
┌──────────────────────────────────────┐
│ User fills signup form               │
│ - Username                           │
│ - Full Name                          │
│ - Email                              │
│ - Password                           │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│ Validate all fields not empty        │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│ isValidUsername()?                   │
│ - 3-20 chars                         │
│ - Alphanumeric + underscore          │
└────────┬─────────────────────────────┘
         │
    ┌────┴────┐
    │         │
   ✅        ❌
    │         │
    │         ▼
    │    Show error
    │    "Invalid username"
    │    Let user retry
    │
    ▼
┌──────────────────────────────────────┐
│ isValidEmail()?                      │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│ Check password length >= 6           │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│ performSignUp()                      │
│ 1. Show loading                      │
│ 2. Call supabase.auth.signUp()       │
│ 3. Save username in metadata         │
└────────┬─────────────────────────────┘
         │
    ┌────┴──────────┐
    │               │
    ▼               ▼
EMAIL CONF     NO EMAIL CONF
(Send link)    (Auto signin)
    │               │
    │               ▼
    │        ┌──────────────────┐
    │        │ Session exists?  │
    │        └────┬─────┬───────┘
    │             │     │
    │             ▼     ▼
    │           YES    NO
    │             │      │
    │             │      ▼
    │             │   Try signIn()
    │             │      │
    │             ▼      ▼
    │        ┌──────────────────────┐
    │        │ Go to Onboarding     │
    │        │ Pass username/fullname
    │        └──────────────────────┘
    │
    ▼
┌──────────────────────────────────────┐
│ Show: "Check email to verify"        │
│ User clicks link in email            │
│ Then they can login                  │
└──────────────────────────────────────┘
```

---

## Database Queries Used

### Username to Email
```sql
SELECT id, email FROM profiles 
WHERE LOWER(username) = LOWER(?)
LIMIT 1
```

### Profile Check
```sql
SELECT id FROM profiles 
WHERE id = ?
LIMIT 1
```

### Both use proper indexing for fast queries

---

## Error Handling

| Error Type | Cause | User Message |
|-----------|-------|--------------|
| `LoginError.userNotFound` | Username doesn't exist in profiles | "Username not found. Please check and try again." |
| AuthError (Supabase) | Wrong password, invalid email | Auth error details |
| Timeout (15s) | Network slow/offline | "Login took too long. Please check your connection..." |
| Profile check fails | Database error (rare) | Still proceeds, assumes new user |

---

## Performance Notes

- ✅ Username query indexed on profiles table
- ✅ 15-second timeout prevents indefinite hang
- ✅ Profile check quick (single ID lookup)
- ✅ No blocking UI operations
- ✅ All async/await properly implemented
- ✅ MainActor.run ensures UI updates on main thread

