package com.example.androidportfolio

import android.os.Parcelable
import com.google.gson.annotations.SerializedName
import kotlinx.android.parcel.Parcelize
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Query

data class MovieResponse(
    @SerializedName("results") val results: List<MovieItem>,
)

@Parcelize
data class MovieItem(
    @SerializedName("id") val id: String,
    @SerializedName("title") val title: String,
    @SerializedName("overview") val overview: String,
    @SerializedName("poster_path") val posterPath: String
): Parcelable

interface MovieApiService {
    @GET("movie/popular")
    suspend fun fetchMovies(
        @Query("api_key") apiKey: String,
        @Query("page") page: Int
    ): MovieResponse
}

class MovieRepository {
    private val retrofit = Retrofit.Builder()
        .baseUrl("https://api.themoviedb.org/3/")
        .addConverterFactory(GsonConverterFactory.create())
        .build()

    private val service = retrofit.create(MovieApiService::class.java)

    suspend fun fetchMovies(page: Int): List<MovieItem>? {
        return try {
            service.fetchMovies("a38bb7041808747f410e16a68a4ac2ae", page).results
        } catch (error: Exception) {
            error.printStackTrace()
            null
        }
    }
}
