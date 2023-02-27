import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/genre_model.dart';
import '../models/movie_model.dart';
import 'base/app_drawer.dart';
import 'base/common_widget.dart';
import 'base/customized_app_bar.dart';

class SearchMovie extends StatefulWidget {
  static var routeName = '/search_movie';

  const SearchMovie({super.key});

  @override
  State<SearchMovie> createState() => _SearchMovieState();
}

class _SearchMovieState extends State<SearchMovie> {
  late GenreModel genreModel =
      ModalRoute.of(context)!.settings.arguments as GenreModel;
  Future<MovieModel>? searchedMovieModel;
  int currentPage = 1;

  @override
  initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Widget searchedGridWidget() {
    return FutureBuilder<MovieModel>(
        future: searchedMovieModel,
        builder: (BuildContext context, AsyncSnapshot<MovieModel> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text(
                "No Result",
                style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                )),
              ),
            );
          }

          var favoriteMovie = snapshot.data!;
          // Filter all non-english movie, especially russian movies
          // Intended to do so
          var englishMovieList = favoriteMovie.results!.where((movie) {
            return movie.originalLanguage == 'en';
          }).toList();
          var genre = genreModel;
          var genreList = genre.genres!;

          return Expanded(
              child: GridView.builder(
            itemCount: englishMovieList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisExtent: 550,
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0),
            itemBuilder: (BuildContext context, int index) {
              var movieItem = englishMovieList[index];

              var genreTag = Container();

              if (movieItem.genreIds != null &&
                  movieItem.genreIds!.isNotEmpty) {
                var genre = genreList
                    .firstWhere((genre) => genre.id == movieItem.genreIds![0]);
                genreTag = Container(
                    margin: const EdgeInsets.only(right: 8, bottom: 8),
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blueAccent),
                    child: Text(genre.name!.toUpperCase()));
              }

              return CommonWidget().movieGridCellWidget(
                  context,
                  movieItem.id!,
                  movieItem.posterPath,
                  movieItem.originalTitle!,
                  movieItem.releaseDate!,
                  movieItem.adult!,
                  movieItem.originalLanguage!,
                  genreTag,
                  movieItem.voteAverage!);
            },
          ));
        });
  }

  Widget searchedMovieWidget() {
    return SafeArea(
        child: GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
          color: Colors.black,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                      margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
                      child: const TextField(
                        keyboardAppearance: Brightness.dark,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter a movie name',
                        ),
                      )),
                )
              ],
            ),
            searchedGridWidget(),
          ])),
    ));
  }

  @override
  Widget build(BuildContext build) {
    return Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar: appBar("Search", Colors.deepPurple, context),
        body: searchedMovieWidget());
  }
}
