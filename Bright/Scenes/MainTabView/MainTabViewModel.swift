//
//  MainTabViewModel.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//  
//

import Foundation
import Combine

final class MainTabViewModel: ObservableObject {
    @Published var shouldShowTabbar = true
    
    @Injected private var uiRepository: UIModificator

    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setUp()
    }
}

private extension MainTabViewModel {
    func setUp() {
        uiRepository.shouldShowTabbar
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { value in
                self.shouldShowTabbar = value
            })
            .store(in: &cancellables)
    }
}
