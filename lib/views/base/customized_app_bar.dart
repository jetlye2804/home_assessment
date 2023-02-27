import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

AppBar appBarWithSearchButton(
    String titleText, Color color, BuildContext context) {
  return AppBar(
    elevation: 0,
    backgroundColor: color,
    centerTitle: true,
    title: Text(titleText),
    actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
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
