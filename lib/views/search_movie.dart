import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/error_model.dart';
import '../models/genre_model.dart';
import '../models/movie_model.dart';
import '../utils/api.dart';
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
  late GenreModel genreModel = (ModalRoute.of(context)!.settings.arguments
      as Map)['genre'] as GenreModel;
  late MovieModel favoriteMovieModel =
      (ModalRoute.of(context)!.settings.arguments as Map)['favorite']
          as MovieModel;
  Future<MovieModel>? searchedMovieModel;
  String text = '';
  int currentPage = 1;
  Timer? _debounce;

  @override
  initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  paginateSearchedMovie(String step, String query) {
    var count = currentPage;
    if (step == 'next') {
      count += 1;
    } else if (step == "back") {
      if (currentPage > 1) {
        count -= 1;
      } else {
        count = 1;
      }
    }

    late Future<MovieModel> refreshedData;
    try {
      refreshedData = API().searchMovie(query, count.toString());
    } catch (error) {
      if (error is ErrorModel) {
        print("error 5");
      }
    }

    setState(() {
      currentPage = count;
      searchedMovieModel = refreshedData;
    });
  }

  //https://stackoverflow.com/questions/51791501/how-to-debounce-textfield-onchange-in-dart
  _onSearchChanged(String query) {
    late Future<MovieModel> refreshedData;

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      try {
        refreshedData = API().searchMovie(query);
      } catch (error) {
        if (error is ErrorModel) {
          print("error 4");
        }
      }

      setState(() {
        text = query;
        currentPage = 1;
        searchedMovieModel = refreshedData;
      });
    });
  }

  Widget widgetSearchPaginationWidget() {
    return FutureBuilder<MovieModel>(
      future: searchedMovieModel,
      builder: (BuildContext context, AsyncSnapshot<MovieModel> snapshot) {
        var dataExist = false;

        if (!snapshot.hasData) {
          dataExist = false;
        } else {
          if (snapshot.data!.totalResults! > 0) {
            dataExist = true;
          } else {
            dataExist = false;
          }
        }
        if (dataExist == false) {
          return Container();
        }

        return CommonWidget().paginationButtonWidget(currentPage, () {
          paginateSearchedMovie('back', text);
        }, () {
          paginateSearchedMovie('next', text);
        }, snapshot.data!.totalPages);
      },
    );
  }

  Widget searchedGridWidget() {
    return FutureBuilder<MovieModel>(
        future: searchedMovieModel,
        builder: (BuildContext context, AsyncSnapshot<MovieModel> snapshot) {
          var dataExist = false;

          if (!snapshot.hasData) {
            dataExist = false;
          } else {
            if (snapshot.data!.totalResults! > 0) {
              dataExist = true;
            } else {
              dataExist = false;
            }
          }

          if (dataExist == false) {
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

          var searchedMovie = snapshot.data!;
          // Filter all non-english movie, especially russian movies
          // Intended to do so
          var englishMovieList = searchedMovie.results!.where((movie) {
            return movie.originalLanguage == 'en';
          }).toList();
          var genre = genreModel;
          var genreList = genre.genres!;

          var favoriteMovieList = <MovieData>[];
          if (favoriteMovieModel.results != null) {
            favoriteMovieList = favoriteMovieModel.results!;
          }

          return Expanded(
              child: GridView.builder(
            itemCount: englishMovieList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisExtent: 550,
                crossAxisCount:
                    MediaQuery.of(context).size.shortestSide < 768 ? 2 : 4,
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

              var isSavedFav = false;
              var contain =
                  favoriteMovieList.where((fav) => fav.id == movieItem.id!);

              if (contain.isNotEmpty) {
                isSavedFav = true;
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
                  movieItem.voteAverage!,
                  isSavedFav);
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
                      child: TextField(
                        onChanged: (text) {
                          _onSearchChanged(text);
                        },
                        keyboardAppearance: Brightness.dark,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter a movie name',
                        ),
                      )),
                )
              ],
            ),
            widgetSearchPaginationWidget(),
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
