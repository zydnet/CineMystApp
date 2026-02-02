//
//  Post.swift
//  CineMystApp
//
//  Created by user@50 on 11/11/25.
//


//
//  Post.swift
//  CineMystApp
//
//  Data model for posts in the feed
//

import Foundation
import UIKit

// MARK: - Post Model (for display in feed)
struct Post: Codable, Identifiable {
    let id: String
    let userId: String
    let username: String
    let userProfilePictureUrl: String?
    let caption: String?
    let mediaUrls: [PostMedia]
    let likesCount: Int
    let commentsCount: Int
    let sharesCount: Int
    let createdAt: Date
    
    // Computed properties for display
    var displayName: String { username }
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case username
        case userProfilePictureUrl = "user_profile_picture_url"
        case caption
        case mediaUrls = "media_urls"
        case likesCount = "likes_count"
        case commentsCount = "comments_count"
        case sharesCount = "shares_count"
        case createdAt = "created_at"
    }
}

// MARK: - Post Media
struct PostMedia: Codable {
    let url: String
    let type: String  // image or video
    let thumbnailUrl: String?
    let width: Int?
    let height: Int?
    
    enum CodingKeys: String, CodingKey {
        case url = "media_url"
        case type = "media_type"
        case thumbnailUrl = "thumbnail_url"
        case width
        case height
    }
    
    // Convenience for display
    var mediaType: MediaType {
        MediaType(rawValue: type) ?? .image
    }
    
    enum MediaType: String {
        case image
        case video
    }
}
// MARK: - Post Creation Request (for API)
struct CreatePostRequest: Encodable {
    let userId: String
    let caption: String?
    let mediaUrls: [PostMedia]?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case caption
        case mediaUrls = "media_urls"
    }
}

// MARK: - Local Post Draft (before upload)
struct PostDraft {
    var caption: String = ""
    var selectedMedia: [DraftMedia] = []
    var location: String?
    var taggedUsers: [String] = []
    
    var hasContent: Bool {
        !caption.isEmpty || !selectedMedia.isEmpty
    }
}

struct DraftMedia {
    let image: UIImage?
    let videoURL: URL?
    let type: MediaType
    
    enum MediaType {
        case image
        case video
    }
    
    var isImage: Bool { type == .image }
    var isVideo: Bool { type == .video }
}
