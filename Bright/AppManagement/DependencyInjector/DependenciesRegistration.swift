//
//  DependenciesRegistration.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//  
//

extension DIInjector: DIInjectorRegistering {
    public static func registerAllServices() {
        registerTools()
        registerRepositories()
        registerRouting()
        registerViewModels()
    }
}
