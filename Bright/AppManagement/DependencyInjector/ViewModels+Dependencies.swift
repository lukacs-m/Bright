//
//  ViewModels+Dependencies.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//  
//

extension DIInjector {
    public static func registerViewModels() {
        register { MainTabViewModel() }.scope(.shared)
        register { TodayViewModel() }.scope(.shared)
        register { DetailViewModel() }.scope(.shared)
        register { SearchViewModel() }.scope(.shared)
    }
}

