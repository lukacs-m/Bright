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
    @State private var opacity:Double = 1
 
    var body: some View {
        mainContainer
            .valueChanged(value: viewModel.shouldShowTabbar) { newValue in
                opacity = !newValue ? 0 : 1
            }
    }
}

extension MainTabView {
    private var mainContainer: some View {
        tabView
    }
}

extension MainTabView {
    private var tabView: some View {
        ZStack(alignment: .bottom) {
            switch selectedTab {
            case 0:
                LazyView(coordinator.goToPage(for: .today))
            case 1:
                LazyView(coordinator.goToPage(for: .search)).embedInNavigation()
            default:
                Text("test")
            }
            VStack(spacing: 0) {
                
                Divider()
                    .padding(.bottom, 8)
                HStack {
                    ForEach(TabbarDestination.allCases, id:\.self) { tabLink in
                        Button(action: {
                            selectedTab = TabbarDestination.getTabNumber(for: tabLink)
                        }) {
                            Spacer()
                            createTabItem(for: tabLink)
                                .foregroundColor(selectedTab == TabbarDestination.getTabNumber(for: tabLink) ? Color.blue : Color.gray)
                            Spacer()
                        }
                    }
                }
                .padding(.bottom, 20)
                .edgesIgnoringSafeArea(.bottom)
            }.edgesIgnoringSafeArea(.bottom)
            .background(Color(UIColor.systemBackground)).opacity(0.98)
            .opacity(opacity)
        }.edgesIgnoringSafeArea(.bottom)
    }
}

extension MainTabView {
    private func createTabItem(for type: TabbarDestination) -> some View {
        VStack(spacing: 3) {
            if type == .search {
                Image(systemName: TabbarDestination.getIconName(for: type))
                    .font(.system(size: 24))
            } else {
                Image(TabbarDestination.getIconName(for: type))
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
            }
            Text(TabbarDestination.getName(for: type))
                .font(.system(size: 12))
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
