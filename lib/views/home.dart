import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_assessment/utils/api.dart';
import 'package:home_assessment/models/now_playing_model.dart';
import 'package:home_assessment/views/base/common_widget.dart';
import 'package:home_assessment/views/base/customized_app_bar.dart';

import 'base/app_drawer.dart';
import '../models/error_model.dart';
import '../models/genre_model.dart';

class Home extends StatefulWidget {
  static var routeName = '/home';
  GenreModel? genreModel;

  Home({super.key, this.genreModel});

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
  void didChangeDependencies() {
    if (widget.genreModel == null) {
      var genre = ModalRoute.of(context)!.settings.arguments as GenreModel;
      widget.genreModel = genre;
    }

    super.didChangeDependencies();
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

  Widget nowPlayingWidget() {
    return FutureBuilder<NowPlayingModel>(
        future: nowPlayingModel,
        builder:
            (BuildContext context, AsyncSnapshot<NowPlayingModel> snapshot) {
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

  Widget homeWidget() {
    return Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
          CommonWidget().paginationButtonWidget(currentPage, () {
            refreshNowShowingMovie('back');
          }, () {
            refreshNowShowingMovie('next');
          }),
          nowPlayingWidget(),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: AppDrawer(
          genreModel: widget.genreModel,
        ),
        appBar: appBarWithSearchButton(
            "Jet's Movie App", Colors.deepPurple, context, widget.genreModel!),
        body: homeWidget());
  }
}
