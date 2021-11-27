//
//  LazyView.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//

import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content

    public init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    public var body: Content {
        build()
    }
}

