//
//  PhotoStatistics.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//

import Foundation

// MARK: - PhotoStatistics
struct PhotoStatistics: Codable {
    let id: String
    let downloads, views, likes: Downloads
}

// MARK: - Downloads
struct Downloads: Codable {
    let total: Int
    let historical: Historical
}

// MARK: - Historical
struct Historical: Codable {
    let change: Int
    let resolution: String
    let quantity: Int
    let values: [Value]
}

// MARK: - Value
struct Value: Codable {
    let date: String
    let value: Int
}
