import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_assessment/api.dart';
import 'package:home_assessment/views/customized_app_bar.dart';
import 'package:home_assessment/models/movie_detail_model.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:countup/countup.dart';

import '../models/error_model.dart';
import '../models/genre_model.dart';

import 'package:intl/intl.dart';

import '../storage_manager.dart';
import 'alert_dialog.dart';

class MovieDetail extends StatefulWidget {
  static var routeName = '/movie_detail';

  const MovieDetail({super.key});

  @override
  State<MovieDetail> createState() => _MovieDetail();
}

class _MovieDetail extends State<MovieDetail> {
  late int movieId = ModalRoute.of(context)!.settings.arguments as int;
  Future<MovieDetailModel>? movieDetailModel;
  bool isLoad = true;
  String? sessionId;
  int? accountId;

  void initialization() async {
    var sessionValue = await StorageManager.readData('session_id');
    var accountValue = await StorageManager.readData('account_id');

    setState(() {
      sessionId = sessionValue;
      accountId = accountValue;
    });

    try {
      movieDetailModel = API().getMovieDetail(movieId.toString());
    } catch (error) {
      if (error is ErrorModel) {
        print("error 3");
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initialization();
  }

  @override
  void initState() {
    super.initState();
  }

  Widget bannerWidget(String bannerPath) {
    return Container(
        color: Colors.blueGrey,
        height: 200,
        child: Image.network(
          'https://image.tmdb.org/t/p/original/$bannerPath',
          fit: BoxFit.cover,
          errorBuilder:
              (BuildContext context, Object exception, StackTrace? stackTrace) {
            return noBannerWidget();
          },
        ));
  }

  Widget noBannerWidget() {
    return Container(
      color: Colors.blueGrey,
      height: 200,
      child: const Center(
        child: Text("Banner Not Found"),
      ),
    );
  }

  Widget titleWidget(String title, String? tagline) {
    return Expanded(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 4.0),
          child: Text(
            title,
            style: GoogleFonts.poppins(
                textStyle: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
            )),
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
          child: Text(
            tagline ?? "",
            style: GoogleFonts.poppins(
                textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            )),
          ),
        ),
      ],
    ));
  }

  String dateFormatter(String date) {
    var parsedDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('MMMM dd, yyyy');
    final String formattedDate = formatter.format(parsedDate);

    return formattedDate;
  }

  Widget adultTag(bool isAdult) {
    if (isAdult == true) {
      return Container(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 168, 0, 0)),
          child: Text("Adult Content".toUpperCase()));
    } else {
      return Container(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 0, 168, 31)),
          child: Text("No Adult Content".toUpperCase()));
    }
  }

  Widget overviewWidget(String? overview) {
    var text = "This movie does not have any overview.";

    if (overview != null && overview != "") {
      text = overview;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          height: 1.5,
          fontSize: 16,
        ),
      ),
    );
  }

  List<Widget> genreList(List<GenreChildModel> genreList) {
    var genreTagList = <Widget>[];

    for (var genre in genreList) {
      var genreTag = Container(
          margin: const EdgeInsets.only(right: 8, bottom: 8),
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.blueAccent),
          child: Text(genre.name!.toUpperCase()));
      genreTagList.add(genreTag);
    }

    return genreTagList;
  }

  Widget voteWidget(double voteAverage, int voteCount) {
    var votingColor = Colors.green;
    if (voteAverage < 7.0) {
      votingColor = Colors.yellow;
    } else if (voteAverage < 5.0) {
      votingColor = Colors.red;
    }

    return Row(
      children: [
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: const Text("This movie obtained the user score:",
                  style: TextStyle(
                    fontSize: 16,
                  )),
            ),
            LinearPercentIndicator(
              barRadius: const Radius.circular(20),
              center: Text("${(voteAverage * 10).round()}%",
                  style: const TextStyle(
                    letterSpacing: -1,
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  )),
              lineHeight: 36,
              percent: (voteAverage / 10),
              backgroundColor: Color.fromARGB(255, 48, 48, 48),
              progressColor: votingColor,
              animation: true,
              animationDuration: 1000,
            ),
            Container(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text("$voteCount votings",
                  style: const TextStyle(
                    fontSize: 16,
                  )),
            ),
          ],
        ))
      ],
    );
  }

  Widget sectionTitleWidget(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
          textStyle: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
      )),
    );
  }

  Widget otherInfoWidget(MovieDetailModel movieDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Production Companies",
          style: GoogleFonts.poppins(
              textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          )),
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var company in movieDetail.productionCompanies!)
                Text(
                  "\u2022 ${company.name!}",
                  style: const TextStyle(fontSize: 16),
                )
            ],
          ),
        ),
        Text(
          "Spoken Language",
          style: GoogleFonts.poppins(
              textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          )),
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var language in movieDetail.spokenLanguages!)
                Text(
                  "\u2022 ${language.englishName!}",
                  style: const TextStyle(fontSize: 16),
                )
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                sectionTitleWidget("Budget"),
                Countup(
                    begin: 0,
                    end: movieDetail.budget! > 0
                        ? movieDetail.budget!.toDouble()
                        : 0,
                    duration: const Duration(seconds: 3),
                    separator: ',',
                    prefix: '\$',
                    style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ))),
              ],
            ),
            Column(
              children: [
                sectionTitleWidget("Revenue"),
                Countup(
                    begin: 0,
                    end: movieDetail.revenue!.toDouble(),
                    duration: const Duration(seconds: 3),
                    separator: ',',
                    prefix: '\$',
                    style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ))),
              ],
            ),
          ],
        )
      ],
    );
  }

  Widget homepageWidget(Uri? homepage) {
    if (homepage == null) {
      return Container();
    }

    return Column(
      children: [
        const Divider(
          color: Colors.white,
          thickness: 2.0,
        ),
        Column(
          children: [
            ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.deepPurple),
                ),
                onPressed: () async {
                  if (await canLaunchUrl(homepage)) {
                    await launchUrl(homepage);
                  } else {
                    print("Launched failed");
                  }
                },
                child: const Text("Homepage"))
          ],
        )
      ],
    );
  }

  void saveFavorite(int movieId) async {
    try {
      API().saveFavoriteMovie(accountId!, sessionId!, movieId, true);
      showDoneDialog(context, 'Successful',
          'This movie has been saved to your favorite list.');
    } catch (error) {
      showDoneDialog(
          context, 'Unsuccessful', 'Unable to save to favorite list.');
    }
  }

  Widget movieDetailWidget() {
    return FutureBuilder<MovieDetailModel>(
        future: movieDetailModel,
        builder:
            (BuildContext context, AsyncSnapshot<MovieDetailModel> snapshot) {
          if (!snapshot.hasData) {
            print("No detail data");
            return Center(
              child: Text(
                "Loading Data...",
                style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                )),
              ),
            );
          }

          var movieDetail = snapshot.data!;

          var favSaveButtonStyle = ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
          );

          if (accountId == null || sessionId == null) {
            favSaveButtonStyle = ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: bannerWidget(movieDetail.backdropPath!),
                      ),
                    ),
                  ],
                ),
                Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            titleWidget(movieDetail.title!, movieDetail.tagline)
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            children: genreList(movieDetail.genres!),
                          ),
                        ),
                        Container(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                            child: Text.rich(
                              TextSpan(
                                text: 'Released on ',
                                style: TextStyle(fontSize: 16),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: dateFormatter(
                                          movieDetail.releaseDate!),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.underline,
                                      )),
                                  // can add more TextSpans here...
                                ],
                              ),
                            )),
                        Container(
                            margin:
                                const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    movieDetail.runtime != null
                                        ? '${movieDetail.runtime} minutes'
                                        : "TBA",
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                ),
                                adultTag(movieDetail.adult!)
                              ],
                            )),
                        ElevatedButton(
                          style: favSaveButtonStyle,
                          onPressed: () {
                            if (accountId != null && sessionId != null) {
                              saveFavorite(movieDetail.id!);
                            }
                          },
                          child: Text("Save to Favorite List"),
                        ),
                        const Divider(
                          color: Colors.white,
                          thickness: 2.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitleWidget("Overview"),
                            overviewWidget(movieDetail.overview),
                          ],
                        ),
                        const Divider(
                          color: Colors.white,
                          thickness: 2.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitleWidget("Votings"),
                            voteWidget(movieDetail.voteAverage!,
                                movieDetail.voteCount!)
                          ],
                        ),
                        const Divider(
                          color: Colors.white,
                          thickness: 2.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitleWidget("Other information"),
                            otherInfoWidget(movieDetail)
                          ],
                        ),
                        homepageWidget(movieDetail.homepage)
                      ],
                    )),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar:
            appBarWithBackButton("Movie details", Colors.deepPurple, context),
        body: SafeArea(child: movieDetailWidget()));
  }
}
