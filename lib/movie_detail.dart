import 'package:flutter/material.dart';
import 'package:home_assessment/customized_app_bar.dart';

import 'models/genre_model.dart';

class MovieDetail extends StatefulWidget {
  static var routeName = '/movie_detail';

  const MovieDetail({super.key});

  @override
  State<MovieDetail> createState() => _MovieDetail();
}

class _MovieDetail extends State<MovieDetail> {
  @override
  void initState() {
    super.initState();
  }

  @override
  build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar:
            appBarWithBackButton("Movie details", Colors.deepPurple, context),
        body: SafeArea(
            minimum: const EdgeInsets.all(16.0),
            child: Container(child: Text("Test"))));
  }
}
