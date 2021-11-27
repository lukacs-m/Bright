//
//  Routing+Dependencies.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//  
//

extension DIInjector {

    public static func registerRouting() {
        register { MainCoordinator() as TabbarViewNavigation }

    }
}
