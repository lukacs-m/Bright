//
//  UIRepository.swift
//  Bright
//
//  Created by Martin Lukacs on 28/11/2021.
//

import Combine
import Foundation

protocol UIModificator {
    var shouldShowTabbar: CurrentValueSubject<Bool, Never> { get }
    func setTabbarVisibility(with shouldBeVisible: Bool)
}

final class UIRepository: UIModificator {
    var shouldShowTabbar: CurrentValueSubject<Bool, Never> = .init(true)
    
    func setTabbarVisibility(with shouldBeVisible: Bool) {
        shouldShowTabbar.send(shouldBeVisible)
    }
}
