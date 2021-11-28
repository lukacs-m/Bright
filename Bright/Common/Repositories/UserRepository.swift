//
//  UserRepository.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//

import Combine
import Foundation

protocol UserFetching {
    func portfolio(for username: String) -> AnyPublisher<[Photo], Error>
}

final class UserRepository: UserFetching {
    private var api: JoltNetworkServicing
    private var photosCache = Cache<String, [Photo]>()
    private var cancelBag = Set<AnyCancellable>()

    init(with api: JoltNetworkServicing) {
        self.api = api
    }

    func portfolio(for username: String) -> AnyPublisher<[Photo], Error> {
        let path = "\(APIConfig.EndPoints.user)/\(username)/photos"
        if let cachedPhotos = photosCache[path] {
            return .just(cachedPhotos)
        }
        let voidPublisher: AnyPublisher<[Photo], Error> = api.joltNetworkClient.get(path)

        return voidPublisher
            .map { [weak self] photos in
                self?.photosCache[path] = photos
                return photos
            }.eraseToAnyPublisher()
    }
}
