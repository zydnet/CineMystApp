# Swipe Screen Improvements - Task Video & Profile Image Display

## Overview
Enhanced the SwipeScreenViewController to show applicant task videos when submitted, or profile pictures when no video exists. Added backend integration to shortlist candidates on swipe right.

## Changes Made

### 1. CandidateModel.swift
**Updated model structure to support both videos and profile images:**

```swift
struct CandidateModel {
    let applicationId: UUID      // ✨ NEW: For updating application status
    let actorId: UUID            // ✨ NEW: For fetching profile data
    let name: String
    let videoURL: URL?           // Task submission video URL
    let profileImageUrl: String? // ✨ NEW: Profile image when no video
    let location: String
    let experience: String
}
```

**Changes:**
- Added `applicationId` to track which application this card represents
- Added `actorId` for profile fetching
- Added `profileImageUrl` to show profile picture when no video exists
- Removed `videoName` (no longer using bundled videos)
- Removed `sampleData` (using real backend data only)

### 2. CandidateCardView.swift
**Enhanced to display either video or profile image:**

**New UI Components:**
```swift
private let profileImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.backgroundColor = .darkGray
    iv.clipsToBounds = true
    return iv
}()
```

**Video/Image Selection Logic:**
```swift
private func setupVideo() {
    if let videoURL = model.videoURL {
        // Show video player
        profileImageView.isHidden = true
        videoContainerView.isHidden = false
        // ... setup AVPlayer
    } else {
        // Show profile image
        videoContainerView.isHidden = true
        profileImageView.isHidden = false
        
        if let imageUrlString = model.profileImageUrl, let imageURL = URL(string: imageUrlString) {
            loadImage(from: imageURL)
        } else {
            // Show placeholder icon
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
}
```

**Image Loading:**
```swift
private func loadImage(from url: URL) {
    URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
        guard let data = data, error == nil, let image = UIImage(data: data) else {
            // Show placeholder on error
            DispatchQueue.main.async {
                self?.profileImageView.image = UIImage(systemName: "person.circle.fill")
                self?.profileImageView.tintColor = .systemGray
            }
            return
        }
        DispatchQueue.main.async {
            self?.profileImageView.image = image
        }
    }.resume()
}
```

### 3. SwipeScreenViewController.swift
**Major improvements to data loading and shortlist functionality:**

#### A. Enhanced Profile Fetching
```swift
private func fetchUserProfile(userId: UUID) async throws -> (name: String, imageUrl: String?) {
    struct UserProfile: Codable {
        let fullName: String?
        let username: String?
        let avatarUrl: String?  // ✨ NEW
        
        enum CodingKeys: String, CodingKey {
            case fullName = "full_name"
            case username
            case avatarUrl = "avatar_url"
        }
    }
    
    let profile: UserProfile = try await supabase
        .from("profiles")
        .select()
        .eq("id", value: userId.uuidString)
        .single()
        .execute()
        .value
    
    let name = profile.fullName ?? profile.username ?? "User \(userId.uuidString.prefix(8))"
    return (name, profile.avatarUrl)
}
```

#### B. Show ALL Applications (Not Just Those With Submissions)
**Before:**
- Only showed applications that had task submissions
- Applicants without videos were hidden

**After:**
- Shows ALL applications for the job
- Displays task video if submitted
- Displays profile image if no video submitted

```swift
// Build cards for ALL applications (not just those with submissions)
let submissionsByApp = Dictionary(grouping: submissions, by: { $0.applicationId })

self.cardData = applications.compactMap { app in
    let profile = userProfiles[app.actorId] ?? ("User", nil)
    let userName = profile.name
    let profileImageUrl = profile.imageUrl
    
    // Check if there are task submissions
    if let appSubs = submissionsByApp[app.id], let latest = appSubs.first {
        let videoURL = latest.submissionUrl
        guard !videoURL.isEmpty else {
            // Empty video URL - show profile image
            return CandidateModel(
                applicationId: app.id,
                actorId: app.actorId,
                name: userName,
                videoURL: nil,
                profileImageUrl: profileImageUrl,
                location: "India",
                experience: "Portfolio Submitted"
            )
        }
        
        // Has video submission
        return CandidateModel(
            applicationId: app.id,
            actorId: app.actorId,
            name: userName,
            videoURL: URL(string: videoURL),
            profileImageUrl: profileImageUrl,
            location: "India",
            experience: "Task Submitted"
        )
    } else {
        // No task submission - show profile image
        return CandidateModel(
            applicationId: app.id,
            actorId: app.actorId,
            name: userName,
            videoURL: nil,
            profileImageUrl: profileImageUrl,
            location: "India",
            experience: "Portfolio Submitted"
        )
    }
}
```

#### C. Shortlist on Swipe Right
**Before:**
- Swiping right only incremented local counter
- No backend update

**After:**
- Swiping right updates application status to "shortlisted" in Supabase
- Counter increments
- Background task syncs to backend

```swift
private func animateSwipe(_ card: UIView, direction: CGFloat) {
    // Get the card model
    guard let cardIndex = cardViews.firstIndex(of: card) else { return }
    let modelIndex = cardData.count - cardViews.count + cardIndex
    
    guard modelIndex < cardData.count else { return }
    let model = cardData[modelIndex]

    if direction > 0 {
        // Swiped right - shortlist the candidate
        shortlistedCount += 1
        shortlistedCountLabel.text = "\(shortlistedCount)"
        
        // Update application status to shortlisted in backend
        Task {
            await updateApplicationStatus(applicationId: model.applicationId, status: .shortlisted)
        }
    } else {
        // Swiped left - pass the candidate
        passedCount += 1
        passedCountLabel.text = "\(passedCount)"
    }

    // Animate card removal
    UIView.animate(withDuration: 0.3, animations: {
        card.center.x += direction * 500
        card.alpha = 0
    }, completion: { _ in
        card.removeFromSuperview()
        self.pushNextCard()
    })
}

private func updateApplicationStatus(applicationId: UUID, status: Application.ApplicationStatus) async {
    do {
        struct ApplicationUpdate: Encodable {
            let status: String
        }
        
        let update = ApplicationUpdate(status: status.rawValue)
        
        try await supabase
            .from("applications")
            .update(update)
            .eq("id", value: applicationId.uuidString)
            .execute()
        
        print("✅ Updated application \(applicationId.uuidString.prefix(8)) to status: \(status.rawValue)")
    } catch {
        print("❌ Failed to update application status: \(error)")
    }
}
```

## User Flow

### 1. Director Opens Swipe Screen
- SwipeScreenViewController loads all applications for the job
- Fetches task submissions from backend
- Fetches profile data (name + avatar_url) from profiles table

### 2. Card Display Logic
**For Each Application:**
```
IF task submission exists AND video URL is not empty:
    ✅ Show task video in card
    Experience: "Task Submitted"
ELSE:
    ✅ Show profile image from avatar_url
    Experience: "Portfolio Submitted"
    IF no avatar_url:
        Show placeholder icon (person.circle.fill)
```

### 3. Swipe Actions

**Swipe Right (Like):**
1. Increment shortlisted counter
2. Update application status to "shortlisted" in Supabase
3. Card animates off screen to the right
4. Next card appears

**Swipe Left (Pass):**
1. Increment passed counter
2. No status update (remains as current status)
3. Card animates off screen to the left
4. Next card appears

### 4. Button Actions
- **Dislike Button (X):** Same as swipe left
- **Like Button (Heart):** Same as swipe right
- **List Button:** Navigate to ApplicationsViewController

## Database Integration

### Tables Used

**1. applications**
```sql
- id (UUID)
- job_id (UUID)
- actor_id (UUID)
- status (ENUM: portfolio_submitted, task_submitted, shortlisted, selected, rejected)
```

**2. task_submissions**
```sql
- id (UUID)
- application_id (UUID)
- submission_url (TEXT) -- Video URL
- submitted_at (TIMESTAMP)
```

**3. profiles**
```sql
- id (UUID)
- full_name (TEXT)
- username (TEXT)
- avatar_url (TEXT) -- Profile image URL
```

### Status Flow
```
portfolio_submitted → [Swipe Right] → shortlisted
                   → [Swipe Left]  → (remains portfolio_submitted)

task_submitted → [Swipe Right] → shortlisted
              → [Swipe Left]  → (remains task_submitted)
```

## Benefits

### 1. No More Static Data
- ❌ Removed hardcoded sample data
- ✅ All cards come from real applications
- ✅ Dynamic content based on submissions

### 2. Complete Applicant Visibility
- ❌ Before: Only saw applicants with video submissions
- ✅ Now: See ALL applicants regardless of submission status
- ✅ Profile images shown when videos not available

### 3. Backend Integration
- ✅ Swipe right properly shortlists candidates
- ✅ Status updates persist in database
- ✅ ApplicationsViewController will show updated statuses
- ✅ ShortlistedViewController will show shortlisted candidates

### 4. Better UX
- ✅ Smooth fallback to profile images
- ✅ Placeholder icon when no image available
- ✅ Consistent experience across all applicants
- ✅ Real-time status updates

## Testing Checklist

- [ ] Open job with multiple applications
- [ ] Verify cards show for ALL applications
- [ ] Check video plays for applicants with task submissions
- [ ] Check profile image shows for applicants without submissions
- [ ] Swipe right on a card
- [ ] Verify counter increments
- [ ] Check ApplicationsViewController shows "shortlisted" status
- [ ] Check ShortlistedViewController shows the applicant
- [ ] Swipe left on a card
- [ ] Verify counter increments but status unchanged
- [ ] Test with applicant who has no avatar_url
- [ ] Verify placeholder icon appears
- [ ] Test button actions (heart/X buttons)
- [ ] Verify empty state when no applications

## Error Handling

### Profile Image Loading
- If avatar_url is invalid or image fails to load
- Shows placeholder icon (person.circle.fill) in gray
- Graceful degradation - no crash

### Video Loading
- If submission_url is empty or invalid
- Falls back to profile image display
- Logs warning but continues

### Backend Updates
- If shortlist update fails
- Error logged to console
- User still sees counter increment (optimistic UI)
- Can be manually fixed in ApplicationsViewController

## Future Enhancements

1. **Undo Action**: Allow directors to undo last swipe
2. **Detailed View**: Tap card to see full profile
3. **Filter Options**: Filter by submission status
4. **Batch Actions**: Select multiple and shortlist at once
5. **Analytics**: Track swipe patterns and decisions
6. **Video Controls**: Add play/pause, mute/unmute buttons
7. **Rejection Reasons**: Collect feedback on passed candidates
