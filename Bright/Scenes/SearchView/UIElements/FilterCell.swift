//
//  FilterCell.swift
//  Bright
//
//  Created by Martin Lukacs on 29/11/2021.
//

import SwiftUI

struct FilterCell: View {
    var title: String
    var isSelected: Bool
    
    var body: some View {
        Text(title.capitalized)
            .foregroundColor(isSelected ? .orange : .black)
        .fontWeight(.regular)
    }
}
