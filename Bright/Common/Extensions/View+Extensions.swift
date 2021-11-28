//
//  View+Extensions.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//

import SwiftUI
import Combine

extension View {
  
    @ViewBuilder public func isHidden(_ hidden: Bool) -> some View {
        if hidden {
            self.hidden()
        } else {
            self
        }
    }
    
    @ViewBuilder func valueChanged<T: Equatable>(value: T, onChange: @escaping (T) -> Void) -> some View {
        if #available(iOS 14.0, *) {
            self.onChange(of: value, perform: onChange)
        } else {
            self.onReceive(Just(value)) { (value) in
                onChange(value)
            }
        }
    }
    
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
    
    func embedInNavigation() -> some View {
        NavigationView { self }
    }
}

