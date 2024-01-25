import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'LoadingWidget.dart';
import 'MovieRepository.dart';
import 'package:palette_generator/palette_generator.dart';

class MovieDetailWidget extends StatefulWidget {
  final MovieItem movie;

  const MovieDetailWidget({Key? key, required this.movie}) : super(key: key);

  @override
  _MovieDetailWidgetState createState() => _MovieDetailWidgetState();
}

final class _MovieDetailWidgetState extends State<MovieDetailWidget> {
  PaletteGenerator? _paletteGenerator;
  Color textColor = Colors.black;
  Color appBarTextColor = Colors.white;
  late double heightImage = MediaQuery.of(context).size.width * 1.4;

  @override
  void initState() {
    super.initState();
    _generatePalette();
  }

  Future<void> _generatePalette() async {
    const double imageWidth = 500;
    const double imageHeight = 750;

    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
          CachedNetworkImageProvider(
            'http://image.tmdb.org/t/p/w500${widget.movie.posterPath}',
          ),
      size: const Size(imageWidth, imageHeight),
      region: const Rect.fromLTWH(
        0,
        imageHeight - 10,
        imageWidth,
        10,
      ),
    );

    final PaletteGenerator paletteUpGenerator =
    await PaletteGenerator.fromImageProvider(
      CachedNetworkImageProvider(
        'http://image.tmdb.org/t/p/w500${widget.movie.posterPath}',
      ),
      size: const Size(imageWidth, imageHeight),
      region: const Rect.fromLTWH(
        0,
        0,
        imageWidth,
        10,
      ),
    );

    setState(() {
      _paletteGenerator = paletteGenerator;
      Color? newColor = _paletteGenerator?.dominantColor?.color;
      Color? newColorAppBar = paletteUpGenerator.dominantColor?.color;
      textColor = newColor != null
          ? getTextColorBasedOnBackground(newColor)
          : Colors.black;

      appBarTextColor = newColorAppBar != null
          ? getTextColorBasedOnBackground(newColorAppBar)
          : Colors.white;
    });
  }

  Color getTextColorBasedOnBackground(Color backgroundColor) {
    final luminance = (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) / 255;
    const threshold = 0.5;

    return luminance > threshold ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paletteGenerator?.dominantColor?.color ?? Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () { Navigator.of(context).pop(); },
          child: Text(Platform.isIOS ? 'Movies' : 'back', style: TextStyle(
            fontWeight: FontWeight.w600, color: appBarTextColor, fontSize: 16
          ),),
        ),
        leading: InkWell(
            onTap: () { Navigator.of(context).pop(); },
            child: Icon(Platform.isIOS ? CupertinoIcons.left_chevron : Icons.arrow_back, color: appBarTextColor,
            size: 24,),),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMovieImagePoster(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.movie.title,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.movie.overview,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieImagePoster(BuildContext context) {
    return Hero(
      tag: 'picture_movie_${widget.movie.id}',
      child: CachedNetworkImage(
        imageUrl: 'http://image.tmdb.org/t/p/w500${widget.movie.posterPath}',
        height: heightImage,
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
    );
  }
}

class SpecialColor extends Color {
  const SpecialColor() : super(0x00000000);

  @override
  int get alpha => 0xFF;
}
