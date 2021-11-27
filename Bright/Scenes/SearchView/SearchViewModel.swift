//
//  SearchViewModel.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//  
//

import Foundation
import Combine

final class SearchViewModel: ObservableObject {
    
   // @Injected var router: XXX type of router

    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setUp()
    }
}

private extension SearchViewModel {
    func setUp() {
    }
}
