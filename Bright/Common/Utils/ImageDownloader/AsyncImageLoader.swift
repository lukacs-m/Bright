//
//  AsyncImageLoader.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//

import Combine
import SwiftUI

struct AsyncImageLoader<Placeholder: View>: View {
    @ObservedObject private var loader: ImageLoader
    private let placeholder: Placeholder
    private let image: (UIImage) -> Image
    
    init(
        url: URL,
        @ViewBuilder placeholder: () -> Placeholder,
        @ViewBuilder image: @escaping (UIImage) -> Image = Image.init(uiImage:)
    ) {
        self.placeholder = placeholder()
        self.image = image
        _loader = ObservedObject(wrappedValue: DIInjector.resolve(args: url))
//          ImageLoader(url: url, cache: Environment(\.imageCache).wrappedValue)
    }
    
    var body: some View {
        content
            .onAppear(perform: loader.load)
    }
    
    private var content: some View {
        Group {
            if loader.image != nil {
                image(loader.image!)
            } else {
                placeholder
            }
        }
    }
}
