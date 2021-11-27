//
//  View+Extensions.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//

import SwiftUI

extension View {
  
    @ViewBuilder public func isHidden(_ hidden: Bool) -> some View {
        if hidden {
            self.hidden()
        } else {
            self
        }
    }
    
//    @ViewBuilder public func isLoading(_ loading: Bool = false) -> some View {
//        ZStack {
//            self
//            if loading {
//                Color.gray.opacity(0.2)
//                ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
//            }
//        }
//    }
    
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
    
    func embedInNavigation() -> some View {
        NavigationView { self }
    }

//    func tabBarHeightOffset(screenTag: Int, perform action: @escaping (CGFloat, Int) -> Void) -> some View {
//        modifier(TabBarHeighOffsetViewModifier(action: action, screenTag: screenTag))
//    }
//
//    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
//        modifier(DeviceRotationViewModifier(action: action))
//    }
}

