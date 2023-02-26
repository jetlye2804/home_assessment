import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_assessment/customized_app_bar.dart';
import 'package:home_assessment/models/top_ten_movie_model.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'api.dart';
import 'app_drawer.dart';
import 'models/error_model.dart';
import 'models/genre_model.dart';
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

  Widget posterContainerWidget(posterPath) {
    return Image.network(
      "https://www.themoviedb.org/t/p/w440_and_h660_face/$posterPath",
      fit: BoxFit.cover,
      height: 300,
      width: 200,
      errorBuilder:
          (BuildContext context, Object exception, StackTrace? stackTrace) {
        return noPosterWidget();
      },
    );
  }

  Widget noPosterWidget() {
    return Container(
      color: Colors.blueGrey,
      height: 300,
      width: 200,
      child: const Center(
        child: Text("Image Not Found"),
      ),
    );
  }

  Widget topTenGridWidget() {
    return FutureBuilder<TopTenMovieModel>(
        future: topTenMovieModel,
        builder:
            (BuildContext context, AsyncSnapshot<TopTenMovieModel> snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          var nowPlaying = snapshot.data!;
          // Filter all non-english movie, especially russian movies
          // Intended to do so
          var englishMovieList = nowPlaying.results!.where((movie) {
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
                  Navigator.of(context).pushNamed(MovieDetail.routeName,
                      arguments: movieItem.id);
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
                                  ? posterContainerWidget(movieItem.posterPath)
                                  : noPosterWidget()),
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
                    )
                  ],
                ),
              );
            },
          ));
        });
  }

  Widget paginationButtonWidget() {
    return Row(
      children: [
        Expanded(
            child: Container(
          margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: currentPage > 1
                    ? () {
                        refreshTopTenMovie('back');
                      }
                    : null,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      currentPage > 1 ? Colors.deepPurple : Colors.grey),
                  foregroundColor: MaterialStateProperty.all<Color>(
                      currentPage > 1 ? Colors.white : Colors.black),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              Text("$currentPage"),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.deepPurple),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () {
                  refreshTopTenMovie('next');
                },
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 16.0),
                ),
              )
            ],
          ),
        )),
      ],
    );
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
                  paginationButtonWidget(),
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
