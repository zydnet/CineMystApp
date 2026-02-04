//
//  Reel Data Model.swift
//  CineMystApp
//
//  Created by user@55 on 25/11/25.
//

import Foundation
import UIKit

struct Reel {
    let videoURL: String
    let authorName: String
    let authorAvatar: UIImage?
    let likes: String
    let comments: String
    let shares: String
    let audioTitle: String
}
struct ReelComment {
    let username: String
    let text: String
    let timeAgo: String
}

struct ShareUser {
    let name: String
    let username: String
}
