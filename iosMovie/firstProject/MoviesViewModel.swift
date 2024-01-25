//
//  MoviesViewModel.swift
//  firstProject
//
//  Created by Caio Henrique on 12/10/23.
//

import Foundation

class MoviesViewModel: ObservableObject {
    @Published var movies: [MovieItem]? = []
    @Published var isLoading = true
    @Published var isError = false
    @Published var lastVisibleItem = false

    private let movieRepository = MovieRepository()

    func fetchMovies() {
        isLoading = true
        isError = false

        movieRepository.fetchMovies { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let movies = result {
                    self?.movies = movies
                } else {
                    self?.isError = true
                }
            }
        }
    }
}
