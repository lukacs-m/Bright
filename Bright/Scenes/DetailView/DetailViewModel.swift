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
    @Published var photos: [Photo] = []
    @Published var photoStatistic: PhotoStatistics?

    @Injected private var photoRepository: PhotosFetching
    @Injected private var userRepository: UserFetching
    @Injected private var uiRepository: UIModificator

    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setUp()
    }
    
    func fetchData(for photo: Photo) {
        photos.append(photo)
        Publishers.CombineLatest(userRepository.portfolio(for: photo.user.username),
                                 photoRepository.photoStatistic(for: photo.id))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    print("Error: \(error.localizedDescription)")
                }
            }) { [weak self] userPhotos, stats in
                var newPhotos = userPhotos
                if !newPhotos.contains(photo) {
                    _ = newPhotos.removeLast()
                    newPhotos.append(photo)
                }
                newPhotos.move(photo, to: 0)
                self?.photos = newPhotos
                self?.photoStatistic = stats
            }
            .store(in: &cancellables)
    }
    
    func cleanContent() {
        photos.removeAll()
        photoStatistic = nil
        uiRepository.setTabbarVisibility(with: true)
    }
}

private extension DetailViewModel {
    func setUp() {}
}
