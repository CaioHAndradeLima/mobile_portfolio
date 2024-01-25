// Events
import 'package:flutter_bloc/flutter_bloc.dart';

import 'MovieRepository.dart';

abstract class MovieEvent {}

class FetchMoviesEvent extends MovieEvent {}

// States
abstract class MovieState {}

class MovieLoadingState extends MovieState {}

class MovieLoadedState extends MovieState {
  final List<MovieItem> movies;

  MovieLoadedState({required this.movies});
}

class MovieErrorState extends MovieState {
  final String errorMessage;

  MovieErrorState({required this.errorMessage});
}

// Bloc
class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieRepository movieRepository;
  DateTime? lastCalledTime;
  final List<MovieItem> listMovies = [];

  var currentPage = 0;
  MovieBloc({required this.movieRepository}) : super(MovieLoadingState()) {
    on<FetchMoviesEvent>((event, emit) async {
      if(!await shouldCallAgain()) {
        return;
      }

      if(listMovies.isEmpty) {
        emit(MovieLoadingState());
      }
      try {
        final movies = await movieRepository.fetchMovies(++currentPage);

        if (movies != null) {
          listMovies.addAll(movies);
          emit(MovieLoadedState(movies: listMovies));
        } else if(listMovies.isEmpty) {
          emit(MovieErrorState(errorMessage: 'Failed to fetch movies'));
        }
      } catch (e) {

        if(listMovies.isEmpty) {
          emit(MovieErrorState(errorMessage: 'Failed to fetch movies'));
        }
      }
    });
  }


  Future<bool> shouldCallAgain() async {
    final currentTime = DateTime.now();

    if (lastCalledTime == null || currentTime.difference(lastCalledTime!) >= Duration(seconds: 3)) {
      lastCalledTime = currentTime;
      return true;
    }

    return false;
  }
}
