//
//  AppConfig.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//

import Foundation

enum AppConfigs {
    // MARK: - Cache

    enum Cache {
        static let entryLifetime: TimeInterval = 172_800 // 2 days
        static let maximumEntryCount: Int = 1000
    }
    
    enum Style {
        static let mainPadding = 20
        static let mainCell: Int = 1000
    }
}
