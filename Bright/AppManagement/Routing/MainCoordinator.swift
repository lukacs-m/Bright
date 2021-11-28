//
//  MainCoordinator.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//

import SwiftUI

// MARK: - TabViewRouting

protocol TabbarViewNavigation {
    func goToPage(for destination: TabbarDestination) -> AnyView
}

// MARK: - Tab enum

enum TabbarDestination: CaseIterable {
    case today
    case search
    
    static func getName(for type: TabbarDestination) -> String {
        switch type {
        case .today:
           return "Today"
        case .search:
            return "Search"
        }
    }

    static func getIconName(for type: TabbarDestination) -> String {
        switch type {
        case .today:
            return "today"
        case .search:
            return "magnifyingglass"
        }
    }

    static func getTabNumber(for type: TabbarDestination) -> Int {
        switch type {
        case .today:
            return 0
        case .search:
            return 1
        }
    }
}

final class MainCoordinator {}

// MARK: - TabViewRouting

extension MainCoordinator: TabbarViewNavigation {
    func goToPage(for destination: TabbarDestination) -> AnyView {
        switch destination {
        case .today:
           return TodayView().eraseToAnyView()
        case .search:
           return SearchView().eraseToAnyView()
        }
    }
}
