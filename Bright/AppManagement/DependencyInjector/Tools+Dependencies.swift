//
//  Tools+Dependencies.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//  
//

extension DIInjector {

    public static func registerTools() {
        register { API() as JoltNetworkServicing }.scope(.application)
    }
}
