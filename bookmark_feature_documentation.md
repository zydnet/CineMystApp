# Bookmark Feature Documentation

## Overview
The bookmark feature allows users to save jobs for later viewing. Bookmarks are stored both locally (UserDefaults) and synced to the backend (Supabase job_bookmarks table).

## Architecture

### Components

#### 1. BookmarkManager (Local Storage)
- **Location**: `/Jobs/BookmarkManager.swift`
- **Purpose**: Manages local bookmark state using UserDefaults
- **Key Methods**:
  - `isBookmarked(_ id: UUID) -> Bool` - Check if a job is bookmarked
  - `toggle(_ id: UUID) -> Bool` - Toggle bookmark state, returns new state
  - `allBookmarkedIDs() -> [UUID]` - Get all bookmarked job IDs

#### 2. JobsService (Backend Sync)
- **Location**: `/Jobs/service/JobsService.swift`
- **Purpose**: Syncs bookmarks with Supabase backend
- **Key Methods**:
  - `toggleBookmark(jobId: UUID) async throws -> Bool` - Sync bookmark to backend
  - `fetchJobsByIds(jobIds: [UUID]) async throws -> [Job]` - Fetch jobs by IDs
  - `isJobBookmarked(jobId: UUID) async throws -> Bool` - Check backend bookmark status

#### 3. JobCardView (UI Component)
- **Location**: `/Jobs/JobCardView.swift`
- **Purpose**: Displays job cards with bookmark button
- **Key Properties**:
  - `onBookmarkTap: (() -> Void)?` - Callback when bookmark button tapped
  - `updateBookmark(isBookmarked: Bool)` - Update bookmark icon (filled/unfilled)

## User Flow

### Bookmarking a Job

1. User taps bookmark icon on a job card in JobsViewController
2. `BookmarkManager.shared.toggle(job.id)` updates local storage
3. `JobCardView.updateBookmark(isBookmarked:)` updates icon visual state
4. Background Task syncs to backend via `JobsService.shared.toggleBookmark(jobId:)`

**Code Example** (from JobsViewController.swift):
```swift
card.onBookmarkTap = { [weak self] in
    let newState = BookmarkManager.shared.toggle(job.id)
    card.updateBookmark(isBookmarked: newState)
    
    // Sync to backend
    Task {
        do {
            try await JobsService.shared.toggleBookmark(jobId: job.id)
            print("✅ Bookmark synced to backend for job: \(job.title)")
        } catch {
            print("❌ Failed to sync bookmark: \(error)")
        }
    }
}
```

### Viewing Saved Jobs

1. User taps bookmark icon in navigation bar (JobsViewController)
2. Navigates to SavedPostViewController
3. `viewWillAppear` loads bookmarked job IDs from `BookmarkManager`
4. Fetches full job data from backend via `JobsService.shared.fetchJobsByIds()`
5. Displays job cards with filled bookmark icons

### Removing Bookmarks

1. User taps bookmark icon on a saved job card (in SavedPostsViewController)
2. `BookmarkManager.shared.toggle(job.id)` removes from local storage
3. Card animates out and removes itself from view
4. If no more bookmarks, shows empty state
5. Background Task syncs removal to backend

**Code Example** (from SavedPostViewController.swift):
```swift
card.onBookmarkTap = { [weak self] in
    let newState = BookmarkManager.shared.toggle(job.id)
    card.updateBookmark(isBookmarked: newState)
    
    // Remove card from view if unbookmarked
    if !newState {
        UIView.animate(withDuration: 0.3, animations: {
            card.alpha = 0
            card.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self?.contentView.removeArrangedSubview(card)
            card.removeFromSuperview()
            
            // Show empty state if no more cards
            if self?.contentView.arrangedSubviews.isEmpty == true {
                self?.showEmptyState()
            }
        }
    }
    
    // Sync to backend
    Task {
        do {
            try await JobsService.shared.toggleBookmark(jobId: job.id)
        } catch {
            print("❌ Failed to sync bookmark removal: \(error)")
        }
    }
}
```

## Database Schema

### job_bookmarks Table
```sql
CREATE TABLE job_bookmarks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID REFERENCES jobs(id) ON DELETE CASCADE,
    actor_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    bookmarked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(job_id, actor_id)
);
```

## UI States

### JobsViewController
- Bookmark icon: Unfilled (empty bookmark) when not saved
- Bookmark icon: Filled (bookmark.fill) when saved
- Icon updates immediately on tap

### SavedPostViewController
- Empty State: "No saved jobs yet\nBookmark jobs to see them here"
- Error State: "Failed to load saved jobs\nPlease try again"
- Loaded State: Shows all bookmarked job cards
- Animation: Smooth fade-out and scale when removing bookmarks

## Implementation Details

### Sync Strategy
- **Local-First**: BookmarkManager provides instant UI feedback
- **Background Sync**: Backend sync happens asynchronously
- **Graceful Degradation**: If backend sync fails, local state is maintained

### Error Handling
- Local storage operations are synchronous and reliable
- Backend sync errors are logged but don't affect UX
- Failed syncs will be attempted again on next app launch (future enhancement)

### Performance
- Local bookmark checks are instant (UserDefaults)
- Saved jobs screen loads on-demand in `viewWillAppear`
- Backend fetches only bookmarked job IDs (not all jobs)

## Testing Checklist

- [ ] Bookmark a job from JobsViewController
- [ ] Verify bookmark icon changes to filled state
- [ ] Open SavedPostsViewController
- [ ] Verify bookmarked job appears
- [ ] Unbookmark job from SavedPostsViewController
- [ ] Verify card animates out
- [ ] Return to JobsViewController
- [ ] Verify bookmark icon is unfilled
- [ ] Bookmark multiple jobs
- [ ] Verify all appear in SavedPostsViewController
- [ ] Kill and restart app
- [ ] Verify bookmarks persist

## Future Enhancements

1. **Sync Retry Logic**: Retry failed backend syncs
2. **Pull-to-Refresh**: Refresh saved jobs list
3. **Bookmark Count**: Show count in navigation bar
4. **Offline Support**: Queue sync operations when offline
5. **Bookmark Collections**: Organize bookmarks into folders
6. **Share Bookmarks**: Share saved jobs with other users
