//
//  SearchRepository.swift
//  Bright
//
//  Created by Martin Lukacs on 28/11/2021.
//

import Combine
import Foundation

protocol SearchContentFetching {
    func search(for params: [String: Any]) -> AnyPublisher<Search, Error>
    func filterParams(for query: String, and filter: SearchFilters) -> [String: Any]
}

final class SearchRepository: SearchContentFetching {
    private var api: JoltNetworkServicing
    private var photosCache = Cache<String, Search>()
    private var cancelBag = Set<AnyCancellable>()

    init(with api: JoltNetworkServicing) {
        self.api = api
    }
    
    func search(for params: [String : Any]) -> AnyPublisher<Search, Error> {
        let path = APIConfig.EndPoints.search
        let key = params.description
        if !key.isEmpty, let cachedSearch = photosCache[key] {
            return .just(cachedSearch)
        }
        
        let voidPublisher: AnyPublisher<Search, Error> = api.joltNetworkClient.get(path, parameters: params)
        
        return voidPublisher
            .map { [weak self] photos in
                self?.photosCache[key] = photos
                return photos
            }.eraseToAnyPublisher()
    }
    
    func filterParams(for query: String, and filter: SearchFilters) -> [String: Any] {
        var params: [String: Any] = [:]
        
        if filter != .none, !query.isEmpty {
            params = ["query": query, "color": filter.rawValue]
        } else if filter == .none, !query.isEmpty {
            params = ["query": query]
        } else if filter != .none, query.isEmpty {
            params = ["color": filter.rawValue]
        }
        return params
    }
}

struct Search: Codable {
    let total, totalPages: Int
    let results: [Photo]

    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}
