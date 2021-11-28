//
//  EmptySearchView.swift
//  Bright
//
//  Created by Martin Lukacs on 29/11/2021.
//

import SwiftUI

struct EmptySearchView: View {
    let message: String
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "magnifyingglass.circle")
                    .resizable()
                    .frame(width: 50, height: 50, alignment: .center)
                Spacer()
            }
            HStack {
                Spacer()
                Text(message)
                    .foregroundColor(.gray)
                    .fontWeight(.light)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            }
        }
    }
}
