//
//  PostManager.swift
//  CineMystApp
//
//  Handles all post-related API operations
//

import Foundation
import Supabase
import UIKit

final class PostManager {
    static let shared = PostManager()
    private init() {}
    
    private var client: SupabaseClient { supabase }
    
    // MARK: - Fetch Posts
    func fetchPosts(limit: Int = 50, offset: Int = 0) async throws -> [Post] {
        let response = try await client
            .from("posts")
            .select("""
                id,
                user_id,
                caption,
                likes_count,
                comments_count,
                shares_count,
                created_at,
                profiles(username, profile_picture_url),
                post_media(media_url, media_type, thumbnail_url, width, height, display_order)
            """)
            .order("created_at", ascending: false)
            .range(from: offset, to: offset + limit - 1)
            .execute()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let posts = try decoder.decode([PostResponse].self, from: response.data)
        
        return posts.map { postResponse in
            Post(
                id: postResponse.id,
                userId: postResponse.userId,
                username: postResponse.profiles?.username ?? "Unknown",
                userProfilePictureUrl: postResponse.profiles?.profilePictureUrl,
                caption: postResponse.caption,
                mediaUrls: postResponse.postMedia ?? [],
                likesCount: postResponse.likesCount,
                commentsCount: postResponse.commentsCount,
                sharesCount: postResponse.sharesCount,
                createdAt: postResponse.createdAt
            )
        }
    }
    
    // MARK: - Fetch User Posts (for Profile)
    func fetchUserPosts(userId: String, limit: Int = 50) async throws -> [Post] {
        let response = try await client
            .from("posts")
            .select("""
                id,
                user_id,
                caption,
                likes_count,
                comments_count,
                shares_count,
                created_at,
                profiles(username, profile_picture_url),
                post_media(media_url, media_type, thumbnail_url, width, height, display_order)
            """)
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let posts = try decoder.decode([PostResponse].self, from: response.data)
        
        return posts.map { postResponse in
            Post(
                id: postResponse.id,
                userId: postResponse.userId,
                username: postResponse.profiles?.username ?? "Unknown",
                userProfilePictureUrl: postResponse.profiles?.profilePictureUrl,
                caption: postResponse.caption,
                mediaUrls: postResponse.postMedia ?? [],
                likesCount: postResponse.likesCount,
                commentsCount: postResponse.commentsCount,
                sharesCount: postResponse.sharesCount,
                createdAt: postResponse.createdAt
            )
        }
    }
    
    private func fetchUserProfile(userId: String) async throws -> ProfileRecord? {
        let response = try await client
            .from("profiles")
            .select("id, username, profile_picture_url")
            .eq("id", value: userId)
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        return try? decoder.decode(ProfileRecord.self, from: response.data)
    }
    
    // MARK: - Create Post
    func createPost(caption: String?, media: [DraftMedia]) async throws -> Post {
        print("📝 Starting post creation...")
        print("   Caption: \(caption ?? "nil")")
        print("   Media count: \(media.count)")
        
        guard let session = try await AuthManager.shared.currentSession() else {
            print("❌ No active session")
            throw PostError.notAuthenticated
        }
        
        let userId = session.user.id
        print("✅ User ID: \(userId)")
        
        // Upload media files and collect their URLs
        var mediaItems: [(url: String, type: String, thumbnail: String?, width: Int?, height: Int?)] = []
        
        for (index, mediaItem) in media.enumerated() {
            print("📤 Uploading media \(index + 1)/\(media.count)...")
            
            if let image = mediaItem.image {
                let url = try await uploadImage(image, userId: userId, index: index)
                print("✅ Image uploaded: \(url)")
                
                mediaItems.append((
                    url: url,
                    type: "image",
                    thumbnail: url,
                    width: Int(image.size.width),
                    height: Int(image.size.height)
                ))
            } else if let videoURL = mediaItem.videoURL {
                let url = try await uploadVideo(videoURL, userId: userId, index: index)
                print("✅ Video uploaded: \(url)")
                
                mediaItems.append((
                    url: url,
                    type: "video",
                    thumbnail: nil,
                    width: nil,
                    height: nil
                ))
            }
        }
        
        print("✅ All media uploaded. Creating post record...")
        
        // Build post payload
        var postPayload: [String: Any] = [
            "user_id": userId.uuidString,
            "likes_count": 0,
            "comments_count": 0,
            "shares_count": 0
        ]
        
        if let caption = caption, !caption.isEmpty {
            postPayload["caption"] = caption
        }
        
        print("📦 Payload keys: \(postPayload.keys)")
        
        // Insert post
        do {
            let postJsonData = try JSONSerialization.data(withJSONObject: postPayload)
            
            let insertResponse = try await client
                .from("posts")
                .insert(postJsonData)
                .execute()
            
            print("✅ Post inserted to database")
            
            // Parse the post ID from response
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let insertedPosts = try decoder.decode([PostResponse].self, from: insertResponse.data)
            guard let insertedPost = insertedPosts.first else {
                print("❌ No post ID in insert response")
                throw PostError.invalidData
            }
            
            let postId = insertedPost.id
            print("✅ Post ID: \(postId)")
            
            // Insert media items into post_media table
            print("📸 Inserting media records...")
            for (index, mediaItem) in mediaItems.enumerated() {
                var mediaPayload: [String: Any] = [
                    "post_id": postId,
                    "media_url": mediaItem.url,
                    "media_type": mediaItem.type,
                    "display_order": index
                ]
                
                if let thumbnail = mediaItem.thumbnail {
                    mediaPayload["thumbnail_url"] = thumbnail
                }
                if let width = mediaItem.width {
                    mediaPayload["width"] = width
                }
                if let height = mediaItem.height {
                    mediaPayload["height"] = height
                }
                
                let mediaJsonData = try JSONSerialization.data(withJSONObject: mediaPayload)
                try await client
                    .from("post_media")
                    .insert(mediaJsonData)
                    .execute()
                
                print("✅ Media \(index + 1) inserted")
            }
            
            // Fetch complete post with media and profile
            print("🔄 Fetching complete post...")
            let fetchResponse = try await client
                .from("posts")
                .select("""
                    id,
                    user_id,
                    caption,
                    likes_count,
                    comments_count,
                    shares_count,
                    created_at,
                    profiles(username, profile_picture_url),
                    post_media(media_url, media_type, thumbnail_url, width, height, display_order)
                """)
                .eq("id", value: postId)
                .single()
                .execute()
            
            print("✅ Post fetched with media")
            
            // Debug: print raw response
            if let jsonString = String(data: fetchResponse.data, encoding: .utf8) {
                print("📦 Raw response: \(jsonString.prefix(200))...")
            }
            
            let postResponse = try decoder.decode(PostResponse.self, from: fetchResponse.data)
            
            print("✅ Post created successfully! ID: \(postResponse.id)")
            
            return Post(
                id: postResponse.id,
                userId: postResponse.userId,
                username: postResponse.profiles?.username ?? "Unknown",
                userProfilePictureUrl: postResponse.profiles?.profilePictureUrl,
                caption: postResponse.caption,
                mediaUrls: postResponse.postMedia ?? [],
                likesCount: postResponse.likesCount,
                commentsCount: postResponse.commentsCount,
                sharesCount: postResponse.sharesCount,
                createdAt: postResponse.createdAt
            )
        } catch {
            print("❌ Error creating post: \(error)")
            if let decodingError = error as? DecodingError {
                print("❌ Decoding error details:")
                switch decodingError {
                case .dataCorrupted(let context):
                    print("   Path: \(context.codingPath)")
                    print("   Debug: \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    print("   Missing key: \(key)")
                    print("   Path: \(context.codingPath)")
                case .typeMismatch(let type, let context):
                    print("   Expected type: \(type)")
                    print("   Path: \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("   Missing value of type: \(type)")
                    print("   Path: \(context.codingPath)")
                @unknown default:
                    print("   Unknown error")
                }
            }
            throw error
        }
    }
    
    // MARK: - Upload Media
    private func uploadImage(_ image: UIImage, userId: UUID, index: Int) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw PostError.imageCompressionFailed
        }
        
        let fileName = "\(userId.uuidString)/posts/\(UUID().uuidString)_\(index).jpg"
        
        try await client.storage
            .from("post-media")
            .upload(
                path: fileName,
                file: imageData,
                options: FileOptions(
                    cacheControl: "3600",
                    contentType: "image/jpeg"
                )
            )
        
        let publicURL = try client.storage
            .from("post-media")
            .getPublicURL(path: fileName)
        
        return publicURL.absoluteString
    }
    
    private func uploadVideo(_ videoURL: URL, userId: UUID, index: Int) async throws -> String {
        let videoData = try Data(contentsOf: videoURL)
        let fileName = "\(userId.uuidString)/posts/\(UUID().uuidString)_\(index).mp4"
        
        try await client.storage
            .from("post-media")
            .upload(
                path: fileName,
                file: videoData,
                options: FileOptions(
                    cacheControl: "3600",
                    contentType: "video/mp4"
                )
            )
        
        let publicURL = try client.storage
            .from("post-media")
            .getPublicURL(path: fileName)
        
        return publicURL.absoluteString
    }
    
    // MARK: - Like/Unlike Post
    func likePost(postId: String) async throws {
        // Increment likes count
        try await client.rpc(
            "increment_post_likes",
            params: ["post_id": postId]
        ).execute()
    }
    
    func unlikePost(postId: String) async throws {
        // Decrement likes count
        try await client.rpc(
            "decrement_post_likes",
            params: ["post_id": postId]
        ).execute()
    }
    
    // MARK: - Delete Post
    func deletePost(postId: String) async throws {
        try await client
            .from("posts")
            .delete()
            .eq("id", value: postId)
            .execute()
    }
}

// MARK: - Response Models
struct PostResponse: Codable {
    let id: String
    let userId: String
    let caption: String?
    let likesCount: Int
    let commentsCount: Int
    let sharesCount: Int
    let createdAt: Date
    let profiles: ProfileData?
    let postMedia: [PostMedia]?
    
    struct ProfileData: Codable {
        let username: String?
        let profilePictureUrl: String?
        
        enum CodingKeys: String, CodingKey {
            case username
            case profilePictureUrl = "profile_picture_url"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case caption
        case likesCount = "likes_count"
        case commentsCount = "comments_count"
        case sharesCount = "shares_count"
        case createdAt = "created_at"
        case profiles
        case postMedia = "post_media"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        caption = try container.decodeIfPresent(String.self, forKey: .caption)
        likesCount = try container.decode(Int.self, forKey: .likesCount)
        commentsCount = try container.decode(Int.self, forKey: .commentsCount)
        sharesCount = try container.decode(Int.self, forKey: .sharesCount)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        profiles = try container.decodeIfPresent(ProfileData.self, forKey: .profiles)
        postMedia = try container.decodeIfPresent([PostMedia].self, forKey: .postMedia)
    }
}


// MARK: - Errors
enum PostError: Error, LocalizedError {
    case notAuthenticated
    case imageCompressionFailed
    case uploadFailed
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "You must be signed in to post"
        case .imageCompressionFailed: return "Failed to process image"
        case .uploadFailed: return "Failed to upload media"
        case .invalidData: return "Invalid post data"
        }
    }
}
