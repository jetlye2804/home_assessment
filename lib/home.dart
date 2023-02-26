import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_assessment/api.dart';
import 'package:home_assessment/models/now_playing_model.dart';
import 'package:home_assessment/movie_detail.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'models/error_model.dart';
import 'models/genre_model.dart';

class Home extends StatefulWidget {
  static var routeName = '/home';
  final GenreModel? genreModel;

  const Home({super.key, this.genreModel});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPage = 1;
  late Future<NowPlayingModel> nowPlayingModel;

  void initialization() async {
    try {
      nowPlayingModel = API().getNowPlaying();
    } catch (error) {
      if (error is ErrorModel) {
        print("error 2");
      }
    }
  }

  @override
  void initState() {
    initialization();
    super.initState();
  }

  refreshNowShowingMovie(String step) {
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

    late Future<NowPlayingModel> refreshedData;
    try {
      refreshedData = API().getNowPlaying(count.toString());
    } catch (error) {
      if (error is ErrorModel) {
        print("error 1");
      }
    }

    setState(() {
      currentPage = count;
      nowPlayingModel = refreshedData;
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

  Widget nowPlayingWidget() {
    return FutureBuilder<NowPlayingModel>(
        future: nowPlayingModel,
        builder:
            (BuildContext context, AsyncSnapshot<NowPlayingModel> snapshot) {
          if (!snapshot.hasData) {
            print("No now playing data");
            return Container();
          }

          var nowPlaying = snapshot.data!;
          // Filter all non-english movie, especially russian movies
          // Intended to do so
          var englishMovieList = nowPlaying.results!.where((movie) {
            return movie.originalLanguage == 'en';
          }).toList();
          var genre = widget.genreModel;
          var genreList = genre!.genres!;

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

              var genre = genreList
                  .firstWhere((genre) => genre.id == movieItem.genreIds![0]);
              var genreTag = Container(
                  margin: const EdgeInsets.only(right: 8, bottom: 8),
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blueAccent),
                  child: Text(genre.name!.toUpperCase()));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: const Text("Jet's Movie App"),
        ),
        body: SafeArea(
            minimum: const EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
                        child: Text(
                          "Now Showing",
                          style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                          )),
                        ),
                      )),
                    ],
                  ),
                  Row(
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
                                      refreshNowShowingMovie('back');
                                    }
                                  : null,
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        currentPage > 1
                                            ? Colors.deepPurple
                                            : Colors.grey),
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        currentPage > 1
                                            ? Colors.white
                                            : Colors.black),
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
                                    MaterialStateProperty.all<Color>(
                                        Colors.deepPurple),
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                              ),
                              onPressed: () {
                                refreshNowShowingMovie('next');
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
                  ),
                  nowPlayingWidget(),
                ])));
  }
}
