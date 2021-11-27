//
//  DetailViewModel.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//  
//

import Foundation
import Combine

final class DetailViewModel: ObservableObject {
    
   // @Injected var router: XXX type of router

    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setUp()
    }
}

private extension DetailViewModel {
    func setUp() {
    }
}
