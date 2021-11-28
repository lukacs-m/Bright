//
//  User.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//

import Foundation

// MARK: - User
struct User: Codable, Identifiable {
    let id: String
    let username, name, firstName: String
    let profileImage: ProfileImage
    let totalCollections, totalLikes, totalPhotos: Int

    enum CodingKeys: String, CodingKey {
        case id
        case username, name
        case firstName = "first_name"
        case profileImage = "profile_image"
        case totalCollections = "total_collections"
        case totalLikes = "total_likes"
        case totalPhotos = "total_photos"
    }
    
    func getURL() -> URL {
        URL(string: profileImage.medium) ?? URL(fileURLWithPath: "")
    }
}

// MARK: - ProfileImage
struct ProfileImage: Codable {
    let small, medium, large: String
}
