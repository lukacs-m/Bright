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

    @State private var opacity: Double = 1
    @Binding var photoDisplay: PhotoDisplay
    @Binding var hero: Bool
    
    private let smallWidth: CGFloat = (UIScreen.screenWidth - 15) / 2
    private let bigWidth: CGFloat = UIScreen.screenWidth - (AppThemeConfig.StyleSize.mainPadding * 2)
    private let bigHeight: CGFloat = UIScreen.screenWidth * AppThemeConfig.StyleSize.mainPhotoTileRatio

    private var frameWidth: CGFloat {
        photoDisplay.expand ? smallWidth : bigWidth
    }
    private var frameheight: CGFloat {
        photoDisplay.expand ? smallWidth : bigHeight
    }
    
    var body: some View {
        mainContainer
            .valueChanged(value: photoDisplay) { newValue in
                guard newValue.expand else {
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    viewModel.fetchData(for: photoDisplay.photo)
                }
            }
    }
}

extension DetailView {
    private var mainContainer: some View {
        ZStack(alignment: .topLeading) {
            Color.white
                .edgesIgnoringSafeArea(.all)
            if viewModel.photos.isEmpty {
                PhotoTileDisplay
            }
            if !viewModel.photos.isEmpty {
                ScrollView {
                    VStack {
                        imageGrid
                        if let stats = viewModel.photoStatistic {
                            HStack {
                                statisticDisplayContainer(with: stats)
                                    .padding(.horizontal)
                                Spacer()
                            }.padding(.bottom, 30)
                        }
                    }
                }
                closeButton
            }
        }
    }
}

extension DetailView {
    private var imageGrid: some View {
        UIGrid(columns: 2, list: viewModel.photos) { photo in
            AsyncImage(url: photo.getURL(),
                       placeholder: { Text("") },
                       image: { Image(uiImage: $0).resizable() }
            ).scaledToFill()
                .frame(width: smallWidth, height: smallWidth)
                .clipped()
        }.padding(.horizontal, 5)
    }
}

extension DetailView {
    private var closeButton: some View {
        Group {
            if photoDisplay.expand {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)){
                            photoDisplay.expand.toggle()
                            hero.toggle()
                            viewModel.cleanContent()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .renderingMode(.template)
                            .foregroundColor(.gray)
                            .frame(width: 35, height: 35)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .padding(.top, 15)
                    .padding(.trailing, 15)
                }
            }
        }
    }
}

extension DetailView {
    private var PhotoTileDisplay: some View {
        ZStack(alignment: .bottomLeading) {
            ZStack(alignment: .top) {
                AsyncImage(url: photoDisplay.photo.getURL(),
                           placeholder: { Text("") },
                           image: { Image(uiImage: $0).resizable() }
                ).scaledToFill()
                
                if let description = photoDisplay.photo.photoDescription, !photoDisplay.expand {
                    VStack {
                        Text(description.capitalized)
                            .lineLimit(5)
                            .font(.system(size: 30, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                            .padding(.top, 45)
                            .padding(.horizontal, 20)
                        Spacer()
                    }
                    .frame(width: frameWidth, height: frameheight)
                }
            }
            .frame(width: frameWidth, height: frameheight)
            .cornerRadius(photoDisplay.expand ? 0 : 25)
            .padding(.horizontal, photoDisplay.expand ? 5 : 20)
            
            if !photoDisplay.expand {
                userInfos
                    .opacity(photoDisplay.expand ? 0 : 1)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
            }
        }
    }
}

extension DetailView {
    private var userInfos: some View {
        HStack(spacing: 15) {
            AsyncImage(
                url: photoDisplay.photo.user.getURL(),
                placeholder: { Text("... Loading")}) {
                    Image(uiImage: $0)
                        .resizable()
                }
                .frame(width: 65, height: 65)
                .clipShape(Circle())
                .shadow(radius: 10)
                .overlay(Circle().stroke(Color.white, lineWidth: 3))
            
            VStack(alignment: .leading, spacing: 5) {
                Spacer()
                Text(photoDisplay.photo.user.username).fontWeight(.semibold)
                Text("\(photoDisplay.photo.user.totalLikes) likes").fontWeight(.semibold)
            }.frame(height: 65)
            .foregroundColor(.white)
        }
    }
}

extension DetailView {
    private func statisticDisplayContainer(with stats: PhotoStatistics) -> some View {
        VStack(alignment: .leading) {
            Text("Picture Statistics")
                .font(.system(size: 25, weight: .regular, design: .default))

            HStack {
                Image("views")
                    .resizable()
                    .frame(width: 30, height: 30)
                Text("\(stats.views.total) views")
            }
            HStack {
                Image("download")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .padding(.trailing, 5)
                Text("\(stats.downloads.total) downloads")
            }
        }.foregroundColor(.gray)
    }
}
