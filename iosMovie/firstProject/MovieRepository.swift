//
//  MovieRepository.swift
//  firstProject
//
//  Created by Caio Henrique on 12/10/23.
//

import Foundation
import Alamofire

class MovieRepository {
    func fetchMovies(completion: @escaping ([MovieItem]?) -> Void) {
        let apiUrl = "https://api.themoviedb.org/3/movie/popular?api_key=a38bb7041808747f410e16a68a4ac2ae"
        
        AF.request(apiUrl).responseDecodable(of: MovieResponse.self) { response in
            switch response.result {
            case .success(let results):
                completion(results.results)
            case .failure(let error):
                print("Erro na solicitação: \(error)")
                completion(nil)
            }
        }
    }
}


struct MovieResponse: Identifiable, Decodable {
    let id = UUID()
    let results: [MovieItem]?

    private enum CodingKeys: String, CodingKey {
        case results
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        results = try container.decode([MovieItem].self, forKey: .results)
    }
}

struct MovieItem: Identifiable, Decodable {
    let id = UUID()
    let title: String
    let overview: String
    let poster_path: String


    private enum CodingKeys: String, CodingKey {
        case title
        case overview
        case poster_path
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        overview = try container.decode(String.self, forKey: .overview)
        poster_path = try container.decode(String.self, forKey: .poster_path)
    }
}
