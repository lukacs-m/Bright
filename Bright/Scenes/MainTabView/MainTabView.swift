//
//  MainTabView.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//  
//

import SwiftUI

struct MainTabView: View {
    @InjectedObject private var viewModel: MainTabViewModel
    @Injected private var coordinator: TabbarViewNavigation

    @State private var selectedTab = 0

    var body: some View {
        mainContainer
    }
}

extension MainTabView {
    private var mainContainer: some View {
            tabView
    }
}

extension MainTabView {
    private var tabView: some View {
        TabView(selection: $selectedTab) {
            createTabItem(for: .today)
            createTabItem(for: .search, systemImage: true)
        }
    }
}

extension MainTabView {
    private func createTabItem(for type: TabbarDestination, systemImage: Bool = false) -> some View {
        LazyView(coordinator.goToPage(for: type).embedInNavigation())
            .tabItem {
                if systemImage {
                    Image(systemName: TabbarDestination.getIconName(for: type))
                } else {
                    Image(TabbarDestination.getIconName(for: type))
                }
                Text(TabbarDestination.getName(for: type))
            }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
