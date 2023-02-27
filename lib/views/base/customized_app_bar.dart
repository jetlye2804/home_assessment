import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_assessment/models/genre_model.dart';
import 'package:home_assessment/views/search_movie.dart';

AppBar appBarWithBackButton(
    String titleText, Color color, BuildContext context) {
  return AppBar(
    elevation: 0,
    backgroundColor: color,
    centerTitle: true,
    title: Text(titleText),
    leading: BackButton(
      color: Colors.white,
      onPressed: () {
        return Navigator.of(context).pop(true);
      },
    ),
  );
}

AppBar appBarWithSearchButton(String titleText, Color color,
    BuildContext context, GenreModel genreModel) {
  return AppBar(
    elevation: 0,
    backgroundColor: color,
    centerTitle: true,
    title: Text(titleText),
    actions: [
      IconButton(
          onPressed: () {
            Navigator.of(context)
                .pushNamed(SearchMovie.routeName, arguments: genreModel);
          },
          icon: Icon(Icons.search))
    ],
  );
}

AppBar appBar(String titleText, Color color, BuildContext context) {
  return AppBar(
    elevation: 0,
    backgroundColor: color,
    centerTitle: true,
    title: Text(titleText),
  );
}
