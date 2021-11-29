//
//  TodayViewModel.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//  
//

import Foundation
import Combine

struct PhotoDisplay: Identifiable, Equatable {
    var id: String
    let photo: Photo
    var expand: Bool
    
    static func == (lhs: PhotoDisplay, rhs: PhotoDisplay) -> Bool {
        lhs.id == rhs.id && lhs.expand == rhs.expand
    }
}

final class TodayViewModel: ObservableObject {
    @Published var photos: [PhotoDisplay] = []
    @Published var date: String = ""
    @Injected private var photoRepository: PhotosFetching
    @Injected private var uiRepository: UIModificator
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setUp()
    }
    
    func hideTabbar() {
        uiRepository.setTabbarVisibility(with: false)
    }
}

private extension TodayViewModel {
    func setUp() {
        photoRepository.photos()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    print("Error: \(error.localizedDescription)")
                }
            }) { [weak self] photos in
                self?.photos = photos.map { PhotoDisplay(id: $0.id, photo: $0, expand: false) }
            }
            .store(in: &cancellables)
        date = getDate()
    }
    
    func getDate() -> String {
        return Date().toString(format: "EEEE, MMMM yyyy")
    }
}
