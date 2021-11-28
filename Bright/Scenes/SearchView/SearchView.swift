//
//  SearchView.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//  
//

import SwiftUI

struct SearchView: View {
    @InjectedObject private var viewModel: SearchViewModel
    private let smallWidth: CGFloat = (UIScreen.screenWidth - 15) / 2

    init() {
        UIScrollView.appearance().decelerationRate = .fast
    }
    
    var body: some View {
        containerView.navigationBarTitle("Search")
    }
}

private extension SearchView {
    var containerView: some View {
        scrollViewContainer
    }
}

// MARK: - Search content scrollview
private extension SearchView {
    var scrollViewContainer: some View {
            ScrollView {
                VStack(alignment: .center,
                           spacing: 5) {
                    
                    Section(header: searchBarSection) {
                        UIGrid(columns: 2, list: viewModel.photos) { photo in
                            AsyncImage(url: photo.getURL(),
                                       placeholder: { Text("") },
                                       image: { Image(uiImage: $0).resizable() }
                            ).scaledToFill()
                                .frame(width: smallWidth, height: smallWidth)
                                .clipped()
                        }.padding(.horizontal, 5)
                    }
                }.padding(.bottom, 65)
            }
            .pageState(for: viewModel.state)
    }
}

// MARK: - Search bar elements
private extension SearchView {
    var searchBarSection: some View {
        VStack {
            HStack {
                SearchBar(query: $viewModel.query).padding()
                Spacer()
            }
            filtersScrollBar()
        }
    }
}

// MARK: - Filter section
private extension SearchView {
    func filtersScrollBar() -> some View {
        let horizontalSpacing: CGFloat = 10
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: horizontalSpacing) {
                ForEach(SearchFilters.allCases, id: \.self) { filter in
                    filterBarElement(wiht: filter)
                }
            }
            .padding()
            
        }.background(Color.gray.opacity(0.3))
        .padding(.bottom)
    }
}

private extension SearchView {
    func filterBarElement(wiht filter: SearchFilters) -> some View {
        HStack {
            if filter != .none {
                Divider()
            }
            Button(action: {
                viewModel.setFilterSelection(for: filter)
            }) {
                FilterCell(title: filter.rawValue,
                           isSelected: viewModel.isCurrentlySelected(for: filter))
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
