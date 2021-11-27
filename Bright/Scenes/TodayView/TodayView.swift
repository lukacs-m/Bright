//
//  TodayView.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//  
//

import SwiftUI

struct TodayView: View {
    @InjectedObject private var viewModel: TodayViewModel

    var body: some View {
        Text("today")
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
    }
}
