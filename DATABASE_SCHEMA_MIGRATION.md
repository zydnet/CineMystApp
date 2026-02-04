# Database Schema Migration - Instagram-Style Architecture

## Overview
This migration consolidates the CineMyst database from a multi-table design to an Instagram-style, centralized identity architecture with a single `profiles` table as the source of truth.

## Key Changes

### 1. **New Profiles Table Schema** (19 Columns Total)

```sql
CREATE TABLE profiles (
    -- Core Identity
    id UUID PRIMARY KEY,                    -- Foreign key to auth.users
    username TEXT UNIQUE NOT NULL,          -- For Instagram-style username login
    email TEXT UNIQUE,                      -- ✨ NEW - For username → email resolution
    
    -- Basic Information
    full_name TEXT,
    date_of_birth DATE,
    
    -- Profile Media
    profile_picture_url TEXT,               -- Original profile picture
    avatar_url TEXT,                        -- ✨ NEW - Avatar/display picture
    
    -- Professional Information
    role VARCHAR(50),                       -- 'artist' or 'casting_professional' (optional)
    employment_status TEXT,
    
    -- Location
    location_state TEXT,
    postal_code VARCHAR(6),                 -- Indian pincode format (6 digits)
    location_city TEXT,
    
    -- Extended Profile
    bio TEXT,                               -- ✨ NEW - User biography
    phone_number TEXT,                      -- ✨ NEW - Contact phone
    website_url TEXT,                       -- ✨ NEW - Personal/professional website
    
    -- Account Status
    is_verified BOOLEAN DEFAULT FALSE,      -- ✨ NEW - Verification status
    connection_count INTEGER DEFAULT 0,     -- ✨ NEW - Number of connections
    onboarding_completed BOOLEAN DEFAULT FALSE, -- ✨ NEW - Onboarding progress
    
    -- Activity Tracking
    last_active_at TIMESTAMPTZ,             -- ✨ NEW - Last login/activity timestamp
    
    -- Audit
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT check_role CHECK (role IN ('artist', 'casting_professional')),
    CONSTRAINT check_postal_code CHECK (postal_code ~ '^\d{6}$'),
    UNIQUE(username),
    UNIQUE(email)
);
```

### 2. **Migration Steps**

#### Step 1: Add New Columns to Profiles Table
```bash
1. Open Supabase Dashboard
2. Navigate to SQL Editor
3. Run: database/update_profiles_schema.sql
4. Verify schema with verification query
```

#### Step 2: Migrate Existing Data
```sql
-- For existing users, populate email from auth.users
UPDATE profiles p
SET email = au.email
FROM auth.users au
WHERE p.id = au.id
AND p.email IS NULL;
```

#### Step 3: Update Swift Code
- ✅ Updated `ProfileRecordForSave` struct (20 fields)
- ✅ Updated `ProfileRecord` struct (21 fields)
- ✅ Updated `saveProfile()` function
- ✅ Updated `SignUpViewController` initial profile creation
- ✅ Updated `LoginViewController` username resolution

### 3. **Swift Code Updates**

#### ProfileRecordForSave Struct (Encoding)
```swift
struct ProfileRecordForSave: Encodable {
    let id: String
    let username: String?
    let email: String?               // ✨ NEW
    let fullName: String?
    let dateOfBirth: String?
    let profilePictureUrl: String?
    let avatarUrl: String?           // ✨ NEW
    let role: String?                // Now Optional (Instagram-style)
    let employmentStatus: String?
    let locationState: String?
    let postalCode: String?
    let locationCity: String?
    let bio: String?                 // ✨ NEW
    let phoneNumber: String?         // ✨ NEW
    let websiteUrl: String?          // ✨ NEW
    let isVerified: Bool?            // ✨ NEW
    let connectionCount: Int?        // ✨ NEW
    let onboardingCompleted: Bool?   // ✨ NEW
    let lastActiveAt: String?        // ✨ NEW
    // ... CodingKeys omitted for brevity
}
```

#### ProfileRecord Struct (Decoding)
```swift
struct ProfileRecord: Codable {
    // Same fields as ProfileRecordForSave
    // Plus: createdAt, updatedAt for audit tracking
}
```

### 4. **Authentication Flow Changes**

#### Signup Flow (Instagram-Style)
1. User enters: username, email, password, full name
2. ✅ Create auth.users record via Supabase.auth.signUp()
3. ✅ Create profiles record immediately (onboarding_completed = false)
4. ✅ Navigate to Dashboard (role selection optional, happens in settings)
5. User can set role later in profile settings

#### Login Flow (Username Support)
1. User enters: username/email + password
2. ✅ If email: Direct auth.signIn(email)
3. ✅ If username: Query profiles table for email, then auth.signIn(email)
4. ✅ Check if profile exists
5. ✅ Navigate to Dashboard or Onboarding

### 5. **Key Differences from Old Schema**

| Feature | Old | New |
|---------|-----|-----|
| **Identity** | Multiple tables (user_profiles, artist_profiles, casting_profiles) | Single `profiles` table (source of truth) |
| **Role Selection** | Forced on signup | Optional (moved to settings) |
| **Onboarding** | Mandatory profile setup | LinkedIn-style optional |
| **Username Login** | Email-only | Username + Email |
| **Email Storage** | auth.users only | Synced to profiles for login |
| **Extended Fields** | Separate tables | All in profiles table |
| **Instagram-Style** | No | ✨ Yes - centralized identity |

### 6. **Database Functions** (Optional)

#### Auto-sync email on auth signup (Recommended)
```sql
CREATE OR REPLACE FUNCTION sync_email_to_profile()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE profiles
    SET email = NEW.email
    WHERE id = NEW.id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER sync_email_to_profile_trigger
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION sync_email_to_profile();
```

### 7. **Testing Checklist**

- [ ] New user signup with username
- [ ] Login with email
- [ ] Login with username
- [ ] Profile appears after signup
- [ ] onboarding_completed = false initially
- [ ] Set role in settings updates profile
- [ ] Messages feature still works (uses profiles table)
- [ ] Existing users can still login (email)
- [ ] New profile fields visible (bio, website_url, etc)

### 8. **Rollback Plan**

If needed, the old tables remain available:
- `artist_profiles` - Artist-specific data
- `casting_profiles` - Casting professional data
- `user_profiles` - (deprecated) Old user profile data

Keep these for reference but deprecate over time.

### 9. **Future Optimizations**

1. **RLS Policies**: Ensure proper row-level security on profiles table
2. **Profile Completion**: Track `onboarding_completed` status for prompts
3. **Verification**: Implement verification workflow for `is_verified` flag
4. **Activity**: Use `last_active_at` for "Last Seen" feature
5. **Connections**: Implement connection system using `connection_count`

## Summary

✅ **Completed:**
- Consolidated database schema to single `profiles` table
- Updated Swift structs (ProfileRecordForSave, ProfileRecord)
- Implemented username login with email resolution
- Added Instagram-style optional role selection
- All new fields included (bio, website_url, is_verified, etc)
- No compilation errors

📋 **To Do:**
- [ ] Run database migration script in Supabase
- [ ] Verify schema with SQL queries
- [ ] Test signup/login flows end-to-end
- [ ] Verify messages feature still works
- [ ] Update RLS policies if needed
