
import 'package:http/http.dart' as http;
import 'dart:convert';

class MovieRepository {
  Future<List<MovieItem>?> fetchMovies(int page) async {
    final apiUrl =
        "https://api.themoviedb.org/3/movie/popular?api_key=a38bb7041808747f410e16a68a4ac2ae&page=$page";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];

        List<MovieItem> movies = results
            .map((movieData) => MovieItem.fromJson(movieData))
            .toList();

        return movies;
      } else {
        print("Erro na solicitação: ${response.reasonPhrase}");
        return null;
      }
    } catch (error) {
      print("Erro na solicitação: $error");
      return null;
    }
  }
}

class MovieResponse {
  late List<MovieItem>? results;

  MovieResponse({required this.results});

  MovieResponse.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <MovieItem>[];
      json['results'].forEach((v) {
        results!.add(MovieItem.fromJson(v));
      });
    }
  }
}

class MovieItem {
  late String id;
  late String title;
  late String overview;
  late String posterPath;

  MovieItem({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
  });

  MovieItem.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    title = json['title'];
    overview = json['overview'];
    posterPath = json['poster_path'];
  }
}
