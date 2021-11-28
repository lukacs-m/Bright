//
//  Tools+Dependencies.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//  
//

extension DIInjector {

    public static func registerTools() {
        register { TemporaryImageCache() as ImageCache }
        register { (_, args) in ImageLoader(url: args(), cache: DIInjector.optional()) }
        register { API() as JoltNetworkServicing }.scope(.application)
    }
}
