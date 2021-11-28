//
//  SearchBar.swift
//  Bright
//
//  Created by Martin Lukacs on 29/11/2021.
//

import SwiftUI

struct SearchBar: View {
    @Binding var query: String

    var body: some View {
        HStack {
            HStack(spacing: 15) {
                Image(systemName: "magnifyingglass")
                TextField("Please enter the name of a city", text: $query)
                    .keyboardType(.alphabet)
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.gray.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            if !query.isEmpty {
                Button(action: {
                    self.query = ""
                }) {
                    Text("Cancel")
                }
            }
        }
    }
}
