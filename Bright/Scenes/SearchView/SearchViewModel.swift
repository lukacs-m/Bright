//
//  SearchViewModel.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//  
//

import Foundation
import Combine

enum SearchFilters: String, Codable, CaseIterable {
    case none = "All"
    case black_and_white
    case black
    case white
    case yellow
    case orange
    case red
    case purple
    case magenta
    case green
    case teal
    case blue
}

enum PageState: Equatable {
    case empty(String)
    case loading
    case full
    
    static let genericEmptyMessage = Self.empty("It's a bit empty here. Let's go looking for a fresh beer")
}

final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var photos: [Photo] = []
    @Published private(set) var state: PageState = PageState.genericEmptyMessage
    @Published private(set) var selectedFilter: SearchFilters = .none
    
    @Injected private var searchRepository: SearchContentFetching

    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setUp()
    }
    
    func setFilterSelection(for filter: SearchFilters) {
        selectedFilter = filter
    }
    
    func isCurrentlySelected(for filter: SearchFilters) -> Bool {
        selectedFilter == filter
    }
}

private extension SearchViewModel {
    func setUp() {
        fullFilteredQuery
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] search in
                self?.state = search.results.isEmpty ? PageState.genericEmptyMessage : .full
                self?.photos = search.results
            })
            .store(in: &cancellables)
    }
    
    private var isCleanQuery: AnyPublisher<String, Never> {
        $query
            .dropFirst()
            .debounce(for: 0.4, scheduler: RunLoop.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
        
    var fullFilteredQuery: AnyPublisher<Search, Never> {
        Publishers.CombineLatest(isCleanQuery, $selectedFilter)
            .map { [weak self] query, filter -> AnyPublisher<Search, Never> in
                guard let self = self else {
                    return Just(Search(total: 0, totalPages: 0, results: [])).eraseToAnyPublisher()
                }
                let params = self.searchRepository.filterParams(for: query, and: filter)
                self.state = .loading
                return self.searchRepository.search(for: params)
                    .replaceError(with: Search(total: 0, totalPages: 0, results: []))
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
