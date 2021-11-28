//
//  Photo.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//

import Foundation

typealias Photos = [Photo]

// MARK: - Photo
struct Photo: Codable, Identifiable, Hashable {
  
    let id: String
    let photoDescription, altDescription: String?
    let urls: Urls
    let links: PhotoLinks
    let user: User

    enum CodingKeys: String, CodingKey {
        case id
        case photoDescription = "description"
        case altDescription = "alt_description"
        case urls, links
        case user
    }
    
    func getURL() -> URL {
        URL(string: urls.small) ?? URL(fileURLWithPath: "")
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.id == rhs.id
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

// MARK: - Urls
struct Urls: Codable {
    let raw, full, regular, small: String
    let thumb: String
}
