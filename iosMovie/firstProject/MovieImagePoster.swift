//
//  MovieImagePoster.swift
//  firstProject
//
//  Created by Caio Henrique on 12/10/23.
//

import Foundation
import SwiftUI

struct MovieImagePoster {
    let movie: MovieItem

    var body: some View {
        VStack {

            AsyncImage(url: URL(string: "http://image.tmdb.org/t/p/w500" + movie.poster_path)) { phase in
                switch phase {
                case .empty: ZStack {
                    Image(systemName: "questionMark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)

                    ProgressView()
                }
                case .success: phase.image?
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                default: Image(systemName: "questionMark")
                }
                
            }
        }
    }
}
