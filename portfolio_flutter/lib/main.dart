import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_flutter/MovieDetails.dart';
import 'LoadingWidget.dart';
import 'MovieBloc.dart';
import 'MovieRepository.dart';
import 'colors.dart';

void main() {
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<MovieBloc>(
        create: (context) => MovieBloc(movieRepository: MovieRepository()),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
      ),
      home: MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({Key? key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<MovieBloc>(context).add(FetchMoviesEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      BlocProvider.of<MovieBloc>(context).add(FetchMoviesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: BlocBuilder<MovieBloc, MovieState>(
        builder: (context, state) {
          if (state is MovieLoadingState) {
            return const Center(child: LoadingWidget());
          } else if (state is MovieLoadedState) {
            _scrollController.addListener(_onScroll);
            return ListView.separated(
              controller: _scrollController,
              itemCount: state.movies.length + 1,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey[300],
              ),
              itemBuilder: (context, index) {
                if (index == state.movies.length) {
                  return Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(20),
                      child: const LoadingWidget());
                }
                final movie = state.movies[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailWidget(movie: movie),
                      ),
                    );
                  },
                  child: ListTile(
                    contentPadding: EdgeInsets.only(left: 8, right: 8),
                    title: Row(
                      children: [
                        SizedBox(
                          width: 104,
                          height: 140,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Hero(
                                tag: 'picture_movie_${movie.id}',
                                child: CachedNetworkImage(
                                  imageUrl: 'http://image.tmdb.org/t/p/w500${movie.posterPath}',
                                  fit: BoxFit.cover,
                                  placeholder: (context, string) {
                                    return const Center(
                                      child: LoadingWidget(),
                                    );
                                  },
                                  errorWidget: (context, url, error) {
                                    return const Center(
                                      child: LoadingWidget(),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                movie.overview,
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Icon(
                          CupertinoIcons.right_chevron,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is MovieErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 20),
                  CupertinoButton(
                    onPressed: () {
                      BlocProvider.of<MovieBloc>(context)
                          .add(FetchMoviesEvent());
                    },
                    padding: EdgeInsets.zero,
                    child: Text(
                      'Try again',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: CupertinoColors.systemBlue, fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Erro ao carregar filmes'));
          }
        },
      ),
    );
  }

  buildAppBar(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoNavigationBar(
        middle: const Text('Movies'),
        backgroundColor: CupertinoColors.systemGrey.withOpacity(0.2),
      );
    } else {
      return AppBar(
        centerTitle: true,
        title: const Text(
          'Movies',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
      );
    }
  }
}
