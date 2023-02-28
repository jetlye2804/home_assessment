import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../movie_detail.dart';

class CommonWidget {
  Widget posterContainerWidget(String posterPath, BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation;
    var aspectRatio = 2 / 3;
    if (isPortrait == Orientation.landscape) {
      aspectRatio = 1 / 1;
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Image.network(
        "https://www.themoviedb.org/t/p/w440_and_h660_face/$posterPath",
        fit: BoxFit.cover,
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
          return noPosterWidget(context);
        },
      ),
    );
  }

  Widget noPosterWidget(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation;
    var aspectRatio = 2 / 3;
    if (isPortrait == Orientation.landscape) {
      aspectRatio = 1 / 1;
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        color: Colors.blueGrey,
        height: 300,
        width: 200,
        child: const Center(
          child: Text("Image Not Found"),
        ),
      ),
    );
  }

  Widget movieGridCellWidget(
      BuildContext context,
      int movieId,
      String? posterPath,
      String movieTitle,
      String releaseDate,
      bool isAdult,
      String movieLanguage,
      Container genreTag,
      double voteAverage,
      bool hasAddedFav) {
    var adultTag = adultTagWidget(isAdult);
    var languageTag = languageTagWidget(movieLanguage!);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(MovieDetail.routeName, arguments: {
          'movie_id': movieId,
          'has_added': hasAddedFav,
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
                    child: posterPath != null
                        ? CommonWidget()
                            .posterContainerWidget(posterPath, context)
                        : CommonWidget().noPosterWidget(context)),
                Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(movieTitle,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400)),
                        Container(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Text(releaseDate),
                        ),
                        Container(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [adultTag, languageTag],
                            )),
                        genreTag
                      ],
                    )),
              ],
            ),
          ),
          savedFavTag(hasAddedFav),
          bottomRightVoteRingWidget(voteAverage),
        ],
      ),
    );
  }

  Widget savedFavTag(bool isSaved) {
    if (isSaved == true) {
      return Positioned(
          left: 16.0,
          bottom: 16.0,
          child: Container(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: Colors.green),
              child: Text("Saved".toUpperCase())));
    } else {
      return Container();
    }
  }

  Widget bottomRightVoteRingWidget(double voteAverage) {
    var votingColor = Colors.green;
    if (voteAverage! < 7.0) {
      votingColor = Colors.yellow;
    } else if (voteAverage! < 5.0) {
      votingColor = Colors.red;
    }

    return Positioned(
      right: 16.0,
      bottom: 16.0,
      child: CircularPercentIndicator(
        radius: 28.0,
        lineWidth: 4.0,
        animation: true,
        percent: (voteAverage! / 10),
        center: Text("${(voteAverage * 10).round()}%"),
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: votingColor,
      ),
    );
  }

  Widget adultTagWidget(bool isAdult) {
    if (isAdult == true) {
      return Container(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 168, 0, 0)),
          child: Text("NSFW".toUpperCase()));
    } else {
      return Container(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 0, 168, 31)),
          child: Text("SFW".toUpperCase()));
    }
  }

  Widget languageTagWidget(String text) {
    return Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.deepPurple),
        child: Text(text.toUpperCase()));
  }

  Widget paginationButtonWidget(int currentPage, VoidCallback backFunc,
      VoidCallback nextFunc, int? totalPage) {
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
                        backFunc();
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
              Text(
                "$currentPage / $totalPage",
                style: const TextStyle(fontSize: 24),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      currentPage < totalPage!
                          ? Colors.deepPurple
                          : Colors.grey),
                  foregroundColor: MaterialStateProperty.all<Color>(
                      currentPage < totalPage ? Colors.white : Colors.black),
                ),
                onPressed: currentPage < totalPage
                    ? () {
                        nextFunc();
                      }
                    : null,
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

  Widget headerWidget(String header) {
    return Row(
      children: [
        Expanded(
            child: Container(
          margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
          child: Text(
            header,
            style: GoogleFonts.poppins(
                textStyle: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
            )),
          ),
        )),
      ],
    );
  }
}
