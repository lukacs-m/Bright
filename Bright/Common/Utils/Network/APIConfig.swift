//
//  APIConfig.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//

import Foundation

enum APIConfig {
    static let baseUrl = "https://api.unsplash.com/"
}

// MARK: - API endpoints

extension APIConfig {
    enum EndPoints {
        static let photos = "photos"
        static let user = "users"
    }
}

// MARK: - Request options

extension APIConfig {
    enum Settings {
        static let timeout: Double = 15
    }
}

// MARK: - API Authentification variables

extension APIConfig {
    static var apiKey: String {
        // 1
        guard let filePath = Bundle.main.path(forResource: "Bright-Info", ofType: "plist") else {
            fatalError("Couldn't find file 'Bright-Info.plist'.")
        }
        // 2
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
            fatalError("Couldn't find key 'API_KEY' in 'Bright-Info.plist'.")
        }
        // 3
        if value.starts(with: "_") {
            fatalError("Register for a unsplash developer account and get an API key at https://unsplash.com.")
        }
        return value
    }
}
