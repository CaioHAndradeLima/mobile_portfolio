package com.example.androidportfolio

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.Crossfade
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Divider
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavGraphBuilder
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import coil.compose.AsyncImage
import com.example.androidportfolio.ui.theme.AndroidPortfolioTheme
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject
import androidx.navigation.compose.rememberNavController
import com.example.androidportfolio.ui.theme.colorScheme

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    @Inject
    lateinit var viewModel: MovieViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        viewModel.fetchMovies()
        setContent {
            AndroidPortfolioTheme {

                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = Color.Black
                ) {
                    SetupNavHost(viewModel = viewModel)
                }
            }
        }
    }
}


@Composable
fun SetupNavHost(viewModel: MovieViewModel) {
    val navController = rememberNavController()

    NavHost(
        navController = navController,
        startDestination = "movies_list"
    ) {
        addMoviesList(navController, viewModel)
        addMovieDetails(navController, viewModel)
    }
}

private fun NavGraphBuilder.addMoviesList(navController: NavHostController, viewModel: MovieViewModel) {
    composable("movies_list") {
        MovieListScreen(navController, viewModel)
    }
}

private fun NavGraphBuilder.addMovieDetails(navController: NavHostController, viewModel: MovieViewModel) {
    composable("details/{movieId}") { backStackEntry ->
        val movieId = backStackEntry.arguments?.getString("movieId")!!
        MovieDetailsScreen(navController, movieId, viewModel)
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MovieDetailsScreen(navController: NavHostController, id: String, movieViewModel: MovieViewModel) {

    val movie = remember { movieViewModel.getMovie(id)!! }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(movie.title, color = Color.White)
                },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(
                            tint = Color.White,
                            imageVector = Icons.Default.ArrowBack,
                            contentDescription = "Back",
                        )
                    }
                },
                colors = TopAppBarDefaults.smallTopAppBarColors(containerColor = Color.Transparent )
            )
        },
        content = { padding ->
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
            ) {
                Crossfade(targetState = movie) { currentMovie ->
                    CoilImageComponent(
                        imageUrl = "http://image.tmdb.org/t/p/w500${currentMovie.posterPath}",
                        modifier = Modifier
                            .fillMaxWidth()
                            .height((LocalConfiguration.current.screenWidthDp * 1.30).dp),
                        contentScale = ContentScale.FillBounds,
                        boxModifier = Modifier
                            .fillMaxWidth()
                            .height((LocalConfiguration.current.screenWidthDp * 1.30).dp)
                            .clip(shape = RoundedCornerShape(bottomEnd = 4.dp, bottomStart = 4.dp))
                            .background(Color.Gray),
                    )
                }
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = movie.title,
                    textAlign = TextAlign.Center,
                    style = MaterialTheme.typography.headlineMedium,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp)
                )
                Text(
                    text = movie.overview,
                    textAlign = TextAlign.Start,
                    style = MaterialTheme.typography.bodyMedium,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp)
                )
                Spacer(modifier = Modifier.height(32.dp))
            }
        }
    )
}

@Composable
fun MovieListScreen(navController: NavHostController, viewModel: MovieViewModel) {
    val moviesState by viewModel.moviesState.observeAsState()

    Scaffold(
        topBar = { MovieListAppBar() },
        content = { padding ->
            when (val state = moviesState) {
                is MovieState.Loading -> LoadingScreen()
                is MovieState.Loaded -> {
                    if (state.movies.isNotEmpty()) {
                            MovieList(
                                state.movies, padding,
                                onItemClick = { movie ->
                                    navController.currentBackStackEntry?.arguments?.putParcelable("movie", movie)
                                    navController.navigate("details/${movie.id}")
                                }, searchMoreItems = {
                                    viewModel.fetchMovies()
                                })
                    } else {
                        Text("Not found movies")
                    }
                }

                is MovieState.Error -> ErrorScreen(state.errorMessage) {
                    viewModel.fetchMovies()
                }

                else -> Text("Network error")
            }
        }
    )
}

@Composable
fun ErrorScreen(errorMessage: String, onRetry: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = errorMessage,
            textAlign = TextAlign.Center,
            style = TextStyle(fontSize = 14.sp)
        )
        Spacer(modifier = Modifier.height(20.dp))
        Button(
            onClick = { onRetry() },
            colors = ButtonDefaults.buttonColors(containerColor = colorScheme.primary),
            contentPadding = PaddingValues(horizontal = 36.dp, vertical = 4.dp)
        ) {
            Text(
                text = "Try Again",
                style = TextStyle(color = Color.White, fontSize = 16.sp)
            )
        }
    }
}

@Composable
fun LoadingScreen() {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        CircularProgressIndicator(
            color = colorScheme.primary,
            strokeWidth = 3.dp
        )
    }
}

@Composable
fun MovieListAppBar() {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .height(56.dp),
        color = Color.Black.copy(alpha = 0.85f)
    ) {
        Text(
            text = "Movies",
            modifier = Modifier.padding(16.dp),
            color = Color.White,
            fontSize = 18.sp,
            fontWeight = FontWeight.Bold
        )
    }
}

@Composable
fun MovieList(
    movies: List<MovieItem>,
    paddingValues: PaddingValues,
    onItemClick: (MovieItem) -> Unit,
    searchMoreItems: () -> Unit
) {

    val listState = rememberLazyListState()
    LazyColumn(
        state = listState,
        modifier = Modifier
            .padding(paddingValues)
            .padding(horizontal = 8.dp)
    ) {
        items(movies.size + 1) { index ->

            if(index == movies.size) {
                searchMoreItems()
                LoadingItem(Modifier.padding(20.dp))
            } else {
                MovieListItem(movie = movies[index], onItemClick = onItemClick)
            }
        }
    }
}

@Composable
fun LoadingItem(modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .wrapContentHeight(),
        contentAlignment = Alignment.Center
    ) {
        CircularProgressIndicator()
    }
}

@Composable
fun MovieListItem(
    movie: MovieItem,
    onItemClick: (MovieItem) -> Unit
) {
    Surface(
        modifier = Modifier
            .clickable(
                onClick = {
                    onItemClick(movie)
                })
            .background(Color.Green)
    ) {
        Column {
            Spacer(modifier = Modifier.height(8.dp))
            Row {
                CoilImageComponent(
                    imageUrl = "http://image.tmdb.org/t/p/w500${movie.posterPath}"
                )
                Spacer(modifier = Modifier.width(8.dp))
                Column {
                    Text(
                        text = movie.title,
                        style = TextStyle(
                            fontWeight = FontWeight.Bold,
                            fontSize = 14.sp
                        ),
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = movie.overview,
                        style = TextStyle(fontSize = 12.sp),
                        maxLines = 5,
                        overflow = TextOverflow.Ellipsis
                    )
                }
                Spacer(modifier = Modifier.weight(1f))
            }
            Spacer(modifier = Modifier.height(8.dp))
            Divider(color = Color.Gray, thickness = 0.4.dp)
        }
    }
}


@Composable
fun CoilImageComponent(
    imageUrl: String,
    width: Dp = 104.dp,
    boxModifier: Modifier = Modifier
        .width(104.dp)
        .height(140.dp)
        .clip(shape = RoundedCornerShape(8.dp))
        .background(Color.Gray),
    modifier: Modifier = Modifier
        .width(width)
        .height((width.value * 1.36).dp),
    contentScale: ContentScale = ContentScale.Crop
) {
    Box(
        modifier = boxModifier

    ) {
        AsyncImage(
            model = imageUrl,
            contentDescription = "Movie Poster",
            contentScale = contentScale,
            modifier = modifier,
        )
    }
}