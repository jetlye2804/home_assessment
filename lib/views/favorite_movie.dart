import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_assessment/utils/api.dart';
import 'package:home_assessment/utils/storage_manager.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../models/error_model.dart';
import '../models/genre_model.dart';
import '../models/movie_model.dart';
import 'base/alert_dialog.dart';
import 'base/app_drawer.dart';
import 'base/common_widget.dart';
import 'base/customized_app_bar.dart';
import 'movie_detail.dart';

class FavoriteMovie extends StatefulWidget {
  static var routeName = '/favorite_movie';

  const FavoriteMovie({super.key});

  @override
  State<FavoriteMovie> createState() => _FavoriteMovieState();
}

class _FavoriteMovieState extends State<FavoriteMovie> {
  late GenreModel genreModel = (ModalRoute.of(context)!.settings.arguments
      as Map)['genre'] as GenreModel;
  Future<MovieModel>? favoriteMovieModel;
  int currentPage = 1;
  String? sessionId;
  int? accountId;

  void initialization() async {
    var sessionValue = await StorageManager.readData('session_id');
    var accountValue = await StorageManager.readData('account_id');

    setState(() {
      sessionId = sessionValue;
      accountId = accountValue;
    });

    if (accountId != null && sessionId != null) {
      try {
        favoriteMovieModel = API().getFavoriteMovie(accountId!, sessionId!);
      } catch (error) {
        if (error is ErrorModel) {
          print("error 4");
        }
      }
    } else {
      throw "Account ID and/or Session ID is/are missing";
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

  Widget favoriteGridWidget(
      List<MovieData> englishMovieList, List<GenreChildModel> genreList) {
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
            true,
            genreModel);
      },
    ));
  }

  Widget myFavoriteWidget(
      List<MovieData> englishMovieList, List<GenreChildModel> genreList) {
    return SafeArea(
        child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CommonWidget().headerWidget("My Favorite Movie"),
                  favoriteGridWidget(englishMovieList, genreList),
                ])));
  }

  @override
  Widget build(BuildContext build) {
    return FutureBuilder<MovieModel>(
        future: favoriteMovieModel,
        builder: (BuildContext context, AsyncSnapshot<MovieModel> snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
                drawer: AppDrawer(genreModel: genreModel),
                backgroundColor: const Color(0xFF000000),
                appBar: appBar("My Favorite Movie", Colors.deepPurple, context),
                body: Center(
                  child: Text(
                    "Loading List...",
                    style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    )),
                  ),
                ));
          }

          var favoriteMovie = snapshot.data!;
          // Filter all non-english movie, especially russian movies
          // Intended to do so
          var englishMovieList = favoriteMovie.results!.where((movie) {
            return movie.originalLanguage == 'en';
          }).toList();
          var genre = genreModel;
          var genreList = genre.genres!;

          return Scaffold(
              drawer: AppDrawer(
                  genreModel: genreModel, favoriteMovieModel: favoriteMovie),
              backgroundColor: const Color(0xFF000000),
              appBar: appBarWithSearchButton("My Favorite Movie",
                  Colors.deepPurple, context, genreModel, favoriteMovie),
              body: myFavoriteWidget(englishMovieList, genreList));
        });
  }
}
