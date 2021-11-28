//
//  Repositories+Dependencies.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//  
//

extension DIInjector {

    public static func registerRepositories() {
        register { PhotosRepository(with: DIInjector.resolve()) as PhotosFetching }.scope(.application)
        register { UserRepository(with: DIInjector.resolve()) as UserFetching }.scope(.application)
        register { UIRepository() as UIModificator }.scope(.application)
        register { SearchRepository(with: DIInjector.resolve()) as SearchContentFetching }.scope(.application)
    }
}
