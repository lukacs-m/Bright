//
//  DetailView.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//  
//

import SwiftUI

struct DetailView: View {
    @InjectedObject private var viewModel: DetailViewModel

    var body: some View {
        Text("detail")
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
    }
}
