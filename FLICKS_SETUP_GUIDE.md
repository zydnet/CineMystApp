# Flicks/Reels Setup Guide

## Overview
This guide will help you set up the Flicks (short video) feature in CineMyst app with Supabase backend integration.

## Features Implemented
- ✅ Video recording from camera (up to 15 seconds)
- ✅ Video upload from photo library (up to 60 seconds)
- ✅ Video upload to Supabase Storage
- ✅ Thumbnail generation and upload
- ✅ Flicks feed with infinite scroll
- ✅ Like/Unlike functionality
- ✅ Comments on flicks
- ✅ Share count tracking
- ✅ User profile integration
- ✅ Floating create button on Flicks feed

## Files Created/Modified

### New Files
1. **FlicksService.swift** - Supabase API service for flicks
2. **FlickComposerViewController.swift** - UI for composing and uploading flicks
3. **FlickUploadViewController.swift** - Choose between recording or uploading from library
4. **supabase_flicks_schema.sql** - Database schema

### Modified Files
1. **CameraViewController.swift** - Added option to post to Flicks and gallery button
2. **ReelsViewController.swift** - Updated to fetch from Supabase, added create button
3. **ReelDataModel.swift** - Updated model to match Supabase data
4. **ReelCell.swift** - Added support for remote video URLs and like status

## Setup Instructions

### Step 1: Create Supabase Tables

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Copy the entire contents of `supabase_flicks_schema.sql`
4. Paste and run the SQL script
5. Verify that tables are created:
   - `flicks`
   - `flick_likes`
   - `flick_comments`

### Step 2: Set Up Storage Bucket

1. Go to **Storage** in Supabase dashboard
2. Create a new bucket called **`videos`**
3. Make it **Public**
4. The storage policies are already included in the SQL schema

### Step 3: Update ReelCell (if needed)

The `ReelCell` needs to support the new Reel model with additional properties:

```swift
// Make sure ReelCell.swift has these methods:
func configure(with reel: Reel) {
    // Set video URL (handle remote URLs)
    // Load author avatar from URL if available
    // Update likes, comments, shares
    // Set like button state based on isLiked
}

func updateLikeStatus(isLiked: Bool) {
    // Update like button appearance
}
```

### Step 4: Verify Authentication

Make sure users are authenticated before uploading:

```swift
// This is already handled in FlicksService.swift
guard let userId = try? await supabase.auth.session.user.id.uuidString else {
    throw NSError(...)
}
```

## Usage Flow

### Creating a Flick

#### Option 1: From Flicks Tab
1. Navigate to Flicks tab
2. Tap the floating **+** button (bottom right)
3. Choose **"Record Video"** or **"Upload from Library"**

#### Option 2: From Camera
1. Open camera from anywhere in the app
2. Switch to **Video** mode
3. **Long press** the capture button to record (max 15 seconds)
4. After recording, choose **"Post to Flicks"**

#### Option 3: Upload from Library
1. Tap **"Upload from Library"** from the upload options
2. Select a video (max 60 seconds)
3. Video is automatically validated for duration
4. Add optional caption and audio title
5. Tap **"Post Flick"** to upload

### Recording and Posting a Flick

1. User opens camera from anywhere in the app
2. Switch to **Video** mode
3. **Long press** the capture button to record (max 15 seconds)
4. After recording, choose **"Post to Flicks"**
5. Add optional caption and audio title
6. Tap **"Post Flick"** to upload

### Viewing Flicks

1. Navigate to Flicks tab
2. Videos load from Supabase
3. Swipe up/down to navigate between flicks
4. Tap heart to like
5. Tap comment icon to add comments
6. Tap share icon to increment share count

## Database Schema

### flicks table
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| user_id | UUID | Foreign key to auth.users |
| video_url | TEXT | URL to uploaded video |
| thumbnail_url | TEXT | URL to thumbnail image |
| caption | TEXT | Optional caption |
| audio_title | TEXT | Audio/music title |
| likes_count | INTEGER | Number of likes |
| comments_count | INTEGER | Number of comments |
| shares_count | INTEGER | Number of shares |
| created_at | TIMESTAMP | Creation time |

### flick_likes table
| Column | Type | Description |
|--------|------|-------------|
| flick_id | UUID | Foreign key to flicks |
| user_id | UUID | Foreign key to auth.users |
| created_at | TIMESTAMP | When liked |

### flick_comments table
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| flick_id | UUID | Foreign key to flicks |
| user_id | UUID | Foreign key to auth.users |
| comment | TEXT | Comment text |
| created_at | TIMESTAMP | When commented |

## API Methods

### FlicksService.shared

```swift
// Fetch flicks
let flicks = try await FlicksService.shared.fetchFlicks(limit: 10, offset: 0)

// Upload video
let videoUrl = try await FlicksService.shared.uploadFlickVideo(videoData, userId: userId)

// Upload thumbnail
let thumbnailUrl = try await FlicksService.shared.uploadThumbnail(imageData, userId: userId)

// Create flick
let flick = try await FlicksService.shared.createFlick(
    videoUrl: videoUrl,
    thumbnailUrl: thumbnailUrl,
    caption: "My caption",
    audioTitle: "Original Audio"
)

// Toggle like
let isLiked = try await FlicksService.shared.toggleLike(flickId: flickId)

// Check if liked
let isLiked = try await FlicksService.shared.isFlickLiked(flickId: flickId)

// Add comment
let comment = try await FlicksService.shared.addComment(flickId: flickId, comment: "Nice!")

// Fetch comments
let comments = try await FlicksService.shared.fetchComments(flickId: flickId)

// Increment shares
try await FlicksService.shared.incrementShareCount(flickId: flickId)
```

## Testing

### Test Upload Flow
1. Record a short video (5-10 seconds)
2. Choose "Post to Flicks"
3. Add caption: "Test flick #1"
4. Tap "Post Flick"
5. Check Supabase Storage for uploaded video
6. Check `flicks` table for new row

### Test Feed Flow
1. Open Flicks tab
2. Should see uploaded flicks
3. Swipe between videos
4. Test like button
5. Test comments

## Troubleshomarks

### Videos not loading
- Check Supabase Storage bucket is public
- Verify video URLs in `flicks` table
- Check network permissions in Info.plist

### Upload failing
- Verify user is authenticated
- Check storage bucket policies
- Ensure video file size is reasonable (<50MB)

### Empty feed
- Check if `flicks` table has data
- Verify RLS policies allow SELECT
- Check console for API errors

## Performance Optimization

### Video Playback
- Videos are loaded on-demand as user scrolls
- Only current video plays, others are paused
- AVPlayer reuses video layers

### Upload Optimization
- Videos compressed during upload
- Thumbnails generated at 0.5s mark
- JPEG compression at 0.7 quality

### Pagination
- Loads 10 flicks at a time
- Infinite scroll with offset-based pagination
- Prefetch likes status in background

## Security

### Row Level Security (RLS)
- Users can only modify their own flicks
- Anyone can view public flicks
- Users can only like/unlike for themselves

### Storage Security
- Users upload to their own folder: `flicks/{user_id}/`
- Public read access for playback
- Users can only delete their own videos

## Next Steps

### Suggested Enhancements
1. Add video filters/effects
2. Implement duet/collaboration features
3. Add trending/discover section
4. Enable video search
5. Add analytics (views, watch time)
6. Implement video reports/moderation
7. Add sound library
8. Enable video downloads

## Support

If you encounter issues:
1. Check Supabase logs in dashboard
2. Verify table schemas match
3. Test with Supabase client directly
4. Check console output for errors
