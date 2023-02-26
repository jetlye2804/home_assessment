import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_assessment/api.dart';
import 'package:home_assessment/models/favorite_movie_model.dart';
import 'package:home_assessment/storage_manager.dart';

import '../models/error_model.dart';
import '../models/genre_model.dart';
import 'app_drawer.dart';
import 'customized_app_bar.dart';

class FavoriteMovie extends StatefulWidget {
  static var routeName = '/favorite_movie';

  const FavoriteMovie({super.key});

  @override
  State<FavoriteMovie> createState() => _FavoriteMovie();
}

class _FavoriteMovie extends State<FavoriteMovie> {
  late GenreModel genreModel =
      ModalRoute.of(context)!.settings.arguments as GenreModel;
  late Future<FavoriteMovieModel> favoriteMovieModel;
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
