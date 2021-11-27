//
//  Photo.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//

import Foundation

typealias Photos = [Photo]

// MARK: - Photo
struct Photo: Codable {
    let id: String
    let createdAt, updatedAt: Date
    let promotedAt: Date?
    let width, height: Int
    let color, blurHash: String
    let photoDescription, altDescription: String?
    let urls: Urls
    let links: PhotoLinks
    let likes: Int
    let likedByUser: Bool
    let sponsorship: Sponsorship?
    let topicSubmissions: TopicSubmissions
    let user: User

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case promotedAt = "promoted_at"
        case width, height, color
        case blurHash = "blur_hash"
        case photoDescription = "description"
        case altDescription = "alt_description"
        case urls, links, likes
        case likedByUser = "liked_by_user"
        case sponsorship
        case topicSubmissions = "topic_submissions"
        case user
    }
}

// MARK: - PhotoLinks
struct PhotoLinks: Codable {
    let linksSelf, html, download, downloadLocation: String

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case html, download
        case downloadLocation = "download_location"
    }
}

// MARK: - Sponsorship
struct Sponsorship: Codable {
    let impressionUrls: [String]
    let tagline: String
    let taglineURL: String
    let sponsor: User

    enum CodingKeys: String, CodingKey {
        case impressionUrls = "impression_urls"
        case tagline
        case taglineURL = "tagline_url"
        case sponsor
    }
}

// MARK: - TopicSubmissions
struct TopicSubmissions: Codable {
    let the3DRenders, wallpapers, architecture, streetPhotography: The3_DRenders?
    let texturesPatterns, nature, travel: The3_DRenders?

    enum CodingKeys: String, CodingKey {
        case the3DRenders = "3d-renders"
        case wallpapers, architecture
        case streetPhotography = "street-photography"
        case texturesPatterns = "textures-patterns"
        case nature, travel
    }
}

// MARK: - The3_DRenders
struct The3_DRenders: Codable {
    let status: String
}

// MARK: - Urls
struct Urls: Codable {
    let raw, full, regular, small: String
    let thumb: String
}


//
//
//// MARK: - UsersPhoto
//struct UsersPhoto: Codable {
//    let id: String
//    let createdAt, updatedAt: Date
//    let promotedAt: JSONNull?
//    let width, height: Int
//    let color, blurHash: String
//    let usersPhotoDescription: String?
//    let altDescription: String
//    let urls: Urls
//    let links: UsersPhotoLinks
//    let likes: Int
//    let likedByUser: Bool
//    let sponsorship: JSONNull?
//    let topicSubmissions: TopicSubmissions
//    let user: User
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case createdAt = "created_at"
//        case updatedAt = "updated_at"
//        case promotedAt = "promoted_at"
//        case width, height, color
//        case blurHash = "blur_hash"
//        case usersPhotoDescription = "description"
//        case altDescription = "alt_description"
//        case urls, links, likes
//        case likedByUser = "liked_by_user"
//        case sponsorship
//        case topicSubmissions = "topic_submissions"
//        case user
//    }
//}
//
//// MARK: - UsersPhotoLinks
//struct UsersPhotoLinks: Codable {
//    let linksSelf, html, download, downloadLocation: String
//
//    enum CodingKeys: String, CodingKey {
//        case linksSelf = "self"
//        case html, download
//        case downloadLocation = "download_location"
//    }
//}
//
//// MARK: - TopicSubmissions
//struct TopicSubmissions: Codable {
//    let businessWork: BusinessWork?
//    let texturesPatterns: TexturesPatterns?
//
//    enum CodingKeys: String, CodingKey {
//        case businessWork = "business-work"
//        case texturesPatterns = "textures-patterns"
//    }
//}
//
//// MARK: - BusinessWork
//struct BusinessWork: Codable {
//    let status: String
//    let approvedOn: Date
//
//    enum CodingKeys: String, CodingKey {
//        case status
//        case approvedOn = "approved_on"
//    }
//}
//
//// MARK: - TexturesPatterns
//struct TexturesPatterns: Codable {
//    let status: String
//}
//
//// MARK: - Urls
//struct Urls: Codable {
//    let raw, full, regular, small: String
//    let thumb: String
//}
//
//// MARK: - User
//struct User: Codable {
//    let id: ID
//    let updatedAt: Date
//    let username: Username
//    let name, firstName: Name
//    let lastName: JSONNull?
//    let twitterUsername: Username
//    let portfolioURL: String
//    let bio: Bio
//    let location: JSONNull?
//    let links: UserLinks
//    let profileImage: ProfileImage
//    let instagramUsername: Username
//    let totalCollections, totalLikes, totalPhotos: Int
//    let acceptedTos, forHire: Bool
//    let social: Social
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case updatedAt = "updated_at"
//        case username, name
//        case firstName = "first_name"
//        case lastName = "last_name"
//        case twitterUsername = "twitter_username"
//        case portfolioURL = "portfolio_url"
//        case bio, location, links
//        case profileImage = "profile_image"
//        case instagramUsername = "instagram_username"
//        case totalCollections = "total_collections"
//        case totalLikes = "total_likes"
//        case totalPhotos = "total_photos"
//        case acceptedTos = "accepted_tos"
//        case forHire = "for_hire"
//        case social
//    }
//}
//
//enum Bio: String, Codable {
//    case followUsWindowsDoGreatThings = "Follow us @Windows. #DoGreatThings"
//}
//
//enum Name: String, Codable {
//    case windows = "Windows"
//}
//
//enum ID: String, Codable {
//    case kSlnstJTnY8 = "kSlnstJTnY8"
//}
//
//enum Username: String, Codable {
//    case windows = "windows"
//}
//
//// MARK: - UserLinks
//struct UserLinks: Codable {
//    let linksSelf, html, photos, likes: String
//    let portfolio, following, followers: String
//
//    enum CodingKeys: String, CodingKey {
//        case linksSelf = "self"
//        case html, photos, likes, portfolio, following, followers
//    }
//}
//
//// MARK: - ProfileImage
//struct ProfileImage: Codable {
//    let small, medium, large: String
//}
//
//// MARK: - Social
//struct Social: Codable {
//    let instagramUsername: Username
//    let portfolioURL: String
//    let twitterUsername: Username
//    let paypalEmail: JSONNull?
//
//    enum CodingKeys: String, CodingKey {
//        case instagramUsername = "instagram_username"
//        case portfolioURL = "portfolio_url"
//        case twitterUsername = "twitter_username"
//        case paypalEmail = "paypal_email"
//    }
//}
//
//typealias UsersPhotos = [UsersPhoto]
