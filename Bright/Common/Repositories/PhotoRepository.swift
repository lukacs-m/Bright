//
//  PhotoRepository.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//

import Combine
import Foundation

protocol PhotosFetching {
    func photos() -> AnyPublisher<[Photo], Error>
    func photoStatistic(for id: String) -> AnyPublisher<PhotoStatistics, Error>
}

final class PhotosRepository: PhotosFetching {
    private var api: JoltNetworkServicing
    private var photosCache = Cache<String, [Photo]>()
    private var photoStatisticsCache = Cache<String, PhotoStatistics>()
    private var cancelBag = Set<AnyCancellable>()

    init(with api: JoltNetworkServicing) {
        self.api = api
    }

    func photos() -> AnyPublisher<[Photo], Error> {
        let path = APIConfig.EndPoints.photos
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
    
    func photoStatistic(for id: String) -> AnyPublisher<PhotoStatistics, Error> {
        let path = "\(APIConfig.EndPoints.photos)/\(id)/statistics"
        if let cachedStats = photoStatisticsCache[path] {
            return .just(cachedStats)
        }
        
        let voidPublisher: AnyPublisher<PhotoStatistics, Error> = api.joltNetworkClient.get(path)
        
        return voidPublisher
            .map { [weak self] stats in
                self?.photoStatisticsCache[path] = stats
                return stats
            }.eraseToAnyPublisher()
    }
}
