//
//  MovieDetailView.swift
//  firstProject
//
//  Created by Caio Henrique on 14/10/23.
//

import Foundation
import SwiftUI

public struct MovieDetailView: View {
    let movie: MovieItem
    @Namespace var namespace

    public var body: some View {
        GeometryReader { geometry in
            ScrollView {
                MovieImagePosterBig(movie: movie)
                    .matchedGeometryEffect(id: movie.id, in: namespace, isSource: true)
            }
        }
        .navigationTitle(movie.title)
    }
}

struct MovieImagePosterBig: View {
    let movie: MovieItem

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: "http://image.tmdb.org/t/p/w500" + movie.poster_path)) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Image(systemName: "questionmark")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)

                        ProgressView()
                    }
                case .success:
                    phase.image?
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                default:
                    Image(systemName: "questionmark")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                }
            }
            
            Text(movie.title)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
            
            Text(movie.overview)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()

        }
    }
}
