// Mentor.swift
// Shared Mentor model used by multiple view controllers

import Foundation

struct Mentor {
    let name: String
    let role: String
    let rating: Double
    let imageName: String?

    init(name: String, role: String, rating: Double, imageName: String? = "Image") {
        self.name = name
        self.role = role
        self.rating = rating
        self.imageName = imageName
    }
}
