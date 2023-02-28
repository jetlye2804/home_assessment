import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_assessment/views/base/common_widget.dart';
import 'package:home_assessment/views/base/customized_app_bar.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../models/movie_model.dart';
import '../utils/api.dart';
import 'base/app_drawer.dart';
import '../models/error_model.dart';
import '../models/genre_model.dart';
import 'movie_detail.dart';

class TopTenMovie extends StatefulWidget {
  static var routeName = '/top_ten_movies';

  const TopTenMovie({super.key});

  @override
  State<TopTenMovie> createState() => _TopTenMovieState();
}

class _TopTenMovieState extends State<TopTenMovie> {
  late GenreModel genreModel = (ModalRoute.of(context)!.settings.arguments
      as Map)['genre'] as GenreModel;
  late MovieModel favoriteMovieModel =
      (ModalRoute.of(context)!.settings.arguments as Map)['favorite']
          as MovieModel;
  late Future<MovieModel> topTenMovieModel;
  int currentPage = 1;

  void initialization() async {
    try {
      topTenMovieModel = API().getTopTen();
    } catch (error) {
      if (error is ErrorModel) {
        print("error 3");
      }
    }
  }

  @override
  initState() {
    initialization();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  refreshTopTenMovie(String step) {
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
      refreshedData = API().getTopTen(count.toString());
    } catch (error) {
      if (error is ErrorModel) {
        print("error 1");
      }
    }

    setState(() {
      currentPage = count;
      topTenMovieModel = refreshedData;
    });
  }

  Widget topTenGridWidget(List<MovieData> englishMovieList,
      List<GenreChildModel> genreList, List<MovieData> favoriteMovieList) {
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

        if (movieItem.genreIds != null && movieItem.genreIds!.isNotEmpty) {
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
        var contain = favoriteMovieList.where((fav) => fav.id == movieItem.id!);

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
            isSavedFav,
            genreModel);
      },
    ));
  }

  Widget widgetPaginationWidget(MovieModel topTen, GenreModel genre) {
    return CommonWidget().paginationButtonWidget(currentPage, () {
      refreshTopTenMovie('back');
    }, () {
      refreshTopTenMovie('next');
    }, topTen.totalPages!);
  }

  Widget topTenWidget(
      MovieModel topTen,
      GenreModel genre,
      List<MovieData> englishMovieList,
      List<GenreChildModel> genreList,
      List<MovieData> favoriteMovieList) {
    return SafeArea(
        child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CommonWidget().headerWidget("Top Rating Movies"),
                  widgetPaginationWidget(topTen, genre),
                  topTenGridWidget(
                      englishMovieList, genreList, favoriteMovieList)
                ])));
  }

  @override
  Widget build(BuildContext build) {
    return FutureBuilder<MovieModel>(
        future: topTenMovieModel,
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
            return Scaffold(
                drawer: AppDrawer(genreModel: genreModel),
                backgroundColor: const Color(0xFF000000),
                appBar: appBar("My Favorite Movie", Colors.deepPurple, context),
                body: Center(
                  child: Text(
                    "Top Rating Movies",
                    style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    )),
                  ),
                ));
          }

          var topTen = snapshot.data!;
          // Filter all non-english movie, especially russian movies
          // Intended to do so
          var englishMovieList = topTen.results!.where((movie) {
            return movie.originalLanguage == 'en';
          }).toList();
          var genre = genreModel;
          var genreList = genre.genres!;

          var favoriteMovieList = <MovieData>[];
          if (favoriteMovieModel.results != null) {
            favoriteMovieList = favoriteMovieModel.results!;
          }

          return Scaffold(
              drawer: AppDrawer(
                genreModel: genreModel,
                favoriteMovieModel: favoriteMovieModel,
              ),
              backgroundColor: const Color(0xFF000000),
              appBar: appBarWithSearchButton("Top Rating Movies",
                  Colors.deepPurple, context, genreModel, favoriteMovieModel),
              body: topTenWidget(topTen, genre, englishMovieList, genreList,
                  favoriteMovieList));
        });
  }
}
