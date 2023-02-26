import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_assessment/api.dart';
import 'package:home_assessment/models/favorite_movie_model.dart';
import 'package:home_assessment/storage_manager.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../models/error_model.dart';
import '../models/genre_model.dart';
import 'alert_dialog.dart';
import 'app_drawer.dart';
import 'common_widget.dart';
import 'customized_app_bar.dart';
import 'movie_detail.dart';

class FavoriteMovie extends StatefulWidget {
  static var routeName = '/favorite_movie';

  const FavoriteMovie({super.key});

  @override
  State<FavoriteMovie> createState() => _FavoriteMovie();
}

class _FavoriteMovie extends State<FavoriteMovie> {
  late GenreModel genreModel =
      ModalRoute.of(context)!.settings.arguments as GenreModel;
  Future<FavoriteMovieModel>? favoriteMovieModel;
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

  void deleteFavorite(int movieId) async {
    print('heh');
    try {
      API().saveFavoriteMovie(accountId!, sessionId!, movieId, false);
      showDoneDialog(context, 'Successful',
          'This movie has been removed to your favorite list.');
    } catch (error) {
      showDoneDialog(
          context, 'Unsuccessful', 'Unable to remove from favorite list.');
    }
  }

  Widget favoriteGridWidget() {
    return FutureBuilder<FavoriteMovieModel>(
        future: favoriteMovieModel,
        builder:
            (BuildContext context, AsyncSnapshot<FavoriteMovieModel> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text(
                "Loading List...",
                style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                )),
              ),
            );
            ;
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
                childAspectRatio: 1 / 2.6,
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0),
            itemBuilder: (BuildContext context, int index) {
              var movieItem = englishMovieList[index];

              var adultTag = Container(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 0, 168, 31)),
                  child: const Text("Safe"));
              if (movieItem.adult! == true) {
                adultTag = Container(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(255, 168, 0, 0)),
                    child: const Text("Adult"));
              }
              var languageTag = Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.deepPurple),
                  child: Text(movieItem.originalLanguage!.toUpperCase()));

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

              var votingColor = Colors.green;
              if (movieItem.voteAverage! < 7.0) {
                votingColor = Colors.yellow;
              } else if (movieItem.voteAverage! < 5.0) {
                votingColor = Colors.red;
              }

              return GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(MovieDetail.routeName, arguments: {
                    'movie_id': movieItem.id,
                    'has_added': true,
                  });
                },
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color.fromARGB(255, 52, 52, 52)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20)),
                              child: movieItem.posterPath != null
                                  ? CommonWidget().posterContainerWidget(
                                      movieItem.posterPath)
                                  : CommonWidget().noPosterWidget()),
                          Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(movieItem.originalTitle!,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400)),
                                  Container(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 8.0),
                                    child: Text(movieItem.releaseDate!),
                                  ),
                                  Container(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        children: [adultTag, languageTag],
                                      )),
                                  genreTag
                                ],
                              )),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 16.0,
                      bottom: 16.0,
                      child: CircularPercentIndicator(
                        radius: 28.0,
                        lineWidth: 4.0,
                        animation: true,
                        percent: (movieItem.voteAverage! / 10),
                        center:
                            Text("${(movieItem.voteAverage! * 10).round()}%"),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: votingColor,
                      ),
                    ),
                    Positioned(
                        right: 0.0,
                        top: 0.0,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.red),
                            ),
                            onPressed: () {
                              showConfirmationDialog(context, 'Remove movie',
                                  'Are you sure to remove this movie from your favorite list?',
                                  () {
                                deleteFavorite(movieItem.id!);
                              });
                            },
                            child: Container(),
                          ),
                        )),
                  ],
                ),
              );
            },
          ));
        });
  }

  Widget myFavoriteWidget() {
    return SafeArea(
        child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
                        child: Text(
                          "My Favorite Movie",
                          style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                          )),
                        ),
                      )),
                    ],
                  ),
                  favoriteGridWidget(),
                ])));
  }

  @override
  Widget build(BuildContext build) {
    return Scaffold(
        drawer: AppDrawer(genreModel: genreModel),
        backgroundColor: const Color(0xFF000000),
        appBar: appBar("My Favorite Movie", Colors.deepPurple, context),
        body: myFavoriteWidget());
  }
}
