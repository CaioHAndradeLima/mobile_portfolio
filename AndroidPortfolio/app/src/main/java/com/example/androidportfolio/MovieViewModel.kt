package com.example.androidportfolio

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import javax.inject.Inject

sealed class MovieState {
    object Loading : MovieState()
    data class Loaded(val movies: List<MovieItem>) : MovieState()
    data class Error(val errorMessage: String) : MovieState()
}

class MovieViewModel @Inject constructor() : ViewModel() {
    private val repository: MovieRepository = MovieRepository()
    private val _moviesState = MutableLiveData<MovieState>()
    val moviesState: LiveData<MovieState> = _moviesState
    var listMovies : MutableList<MovieItem>? = null
    var page = 1
    fun fetchMovies() {
        if (listMovies == null)
            _moviesState.value = MovieState.Loading

        CoroutineScope(Dispatchers.Main).launch {
            val movies = repository.fetchMovies(page)
            if (movies != null) {
                listMovies = if(listMovies == null) {
                    mutableListOf()
                } else {
                    mutableListOf(*listMovies!!.toTypedArray());
                }
                listMovies!!.addAll(movies)
                ++page
                _moviesState.value = MovieState.Loaded(listMovies!!)
            } else if(listMovies == null) {
                _moviesState.value = MovieState.Error("Erro ao carregar filmes")
            }
        }
    }

    fun getMovie(id: String) = listMovies?.first { it.id == id }
}

