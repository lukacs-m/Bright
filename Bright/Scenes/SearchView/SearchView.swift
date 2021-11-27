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

    var body: some View {
        Text("search")
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
