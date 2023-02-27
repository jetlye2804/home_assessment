import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_assessment/views/base/common_widget.dart';
import 'package:home_assessment/views/base/customized_app_bar.dart';
import 'package:home_assessment/models/top_ten_movie_model.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

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
  late GenreModel genreModel =
      ModalRoute.of(context)!.settings.arguments as GenreModel;
  late Future<TopTenMovieModel> topTenMovieModel;
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

    late Future<TopTenMovieModel> refreshedData;
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

  Widget topTenGridWidget() {
    return FutureBuilder<TopTenMovieModel>(
        future: topTenMovieModel,
        builder:
            (BuildContext context, AsyncSnapshot<TopTenMovieModel> snapshot) {
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
          }

          var topTen = snapshot.data!;
          // Filter all non-english movie, especially russian movies
          // Intended to do so
          var englishMovieList = topTen.results!.where((movie) {
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

  Widget topTenWidget() {
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
                          "Top 10 Movies",
                          style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                          )),
                        ),
                      )),
                    ],
                  ),
                  CommonWidget().paginationButtonWidget(currentPage, () {
                    refreshTopTenMovie('back');
                  }, () {
                    refreshTopTenMovie('next');
                  }),
                  topTenGridWidget()
                ])));
  }

  @override
  Widget build(BuildContext build) {
    return Scaffold(
        drawer: AppDrawer(genreModel: genreModel),
        backgroundColor: const Color(0xFF000000),
        appBar: appBar("Top 10 Movies", Colors.deepPurple, context),
        body: topTenWidget());
  }
}
