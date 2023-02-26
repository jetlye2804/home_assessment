import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_assessment/api.dart';
import 'package:home_assessment/customized_app_bar.dart';
import 'package:home_assessment/models/movie_detail_model.dart';

import 'models/error_model.dart';
import 'models/genre_model.dart';

class MovieDetail extends StatefulWidget {
  static var routeName = '/movie_detail';

  const MovieDetail({super.key});

  @override
  State<MovieDetail> createState() => _MovieDetail();
}

class _MovieDetail extends State<MovieDetail> {
  late int movieId = ModalRoute.of(context)!.settings.arguments as int;
  late Future<MovieDetailModel> movieDetailModel;
  bool isLoad = true;

  void initialization() async {
    try {
      movieDetailModel = API().getMovieDetail(movieId.toString());
    } catch (error) {
      print('catched');
      print(error);
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

          return Text(movieDetail.title!);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar:
            appBarWithBackButton("Movie details", Colors.deepPurple, context),
        body: SafeArea(
            minimum: const EdgeInsets.all(16.0), child: movieDetailWidget()));
  }
}
