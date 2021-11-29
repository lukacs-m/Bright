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
    @State private var animate = false

    var body: some View {
        mainContainer
    }
}

extension TodayView {
    private var mainContainer: some View {
        ScrollView(animate ? [] : .vertical) {
            VStack{
                listHeader
                    .opacity(animate ? 0 : 1)
                mainList
            }
        }
    }
}

// MARK: - Page Header
extension TodayView {
    private var listHeader: some View {
        HStack{
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.date)
                    .foregroundColor(.gray)
                    .font(.system(size: 20, weight: .bold, design: .default))
                Text("Today")
                    .font(.system(size: 45, weight: .bold, design: .default))
            }
            Spacer()
        }
        .padding()
    }
}

// MARK: - List of Photos

extension TodayView {
    private var mainList: some View {
        VStack(spacing: 35) {
            if !viewModel.photos.isEmpty {
                ForEach(0..<viewModel.photos.count) { index in
                    detailTile(for: index)
                }
            }
        }.padding(.bottom, 85)
    }
}

extension TodayView {
    private func detailTile(for index: Int) -> some View {
        GeometryReader { proxy in
            DetailView(photoDisplay: $viewModel.photos[index], animate: $animate)
                .offset(y:  viewModel.photos[index].expand ? -(proxy.frame(in: .global).minY - (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)) : 0)
                .offset(x: viewModel.photos[index].expand ? -proxy.frame(in: .global).minX : 0)
                .opacity(animate ? (viewModel.photos[index].expand ? 1 : 0) : 1)
                .onTapGesture {
                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)
                    ) {
                        if !viewModel.photos[index].expand {
                            animate.toggle()
                            viewModel.photos[index].expand.toggle()
                            viewModel.hideTabbar()
                        }
                    }
                }
        }
        .frame(height: viewModel.photos[index].expand ? UIScreen.main.bounds.height : UIScreen.screenWidth * AppThemeConfig.StyleSize.mainPhotoTileRatio)
        
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
    }
}
