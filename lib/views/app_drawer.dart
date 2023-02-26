import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_assessment/views/favorite_movie.dart';
import 'package:home_assessment/views/top_ten_movie.dart';

import 'home.dart';
import '../models/genre_model.dart';

class AppDrawer extends StatefulWidget {
  final GenreModel? genreModel;
  const AppDrawer({Key? key, this.genreModel}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Drawer(
            child: SafeArea(
          minimum: const EdgeInsets.only(left: 8, right: 8),
          child: Column(
            children: [
              ListTile(
                title: const Text("Now Playing"),
                onTap: () {
                  if (ModalRoute.of(context)!.settings.name != '/' &&
                      ModalRoute.of(context)!.settings.name != Home.routeName) {
                    Navigator.of(context).pushNamed(Home.routeName,
                        arguments: widget.genreModel);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
              ListTile(
                onTap: () {
                  if (ModalRoute.of(context)!.settings.name !=
                      TopTenMovie.routeName) {
                    Navigator.of(context).pushNamed(TopTenMovie.routeName,
                        arguments: widget.genreModel);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                title: const Text("Top 10 Movies"),
              ),
              ListTile(
                onTap: () {
                  if (ModalRoute.of(context)!.settings.name !=
                      FavoriteMovie.routeName) {
                    Navigator.of(context).pushNamed(FavoriteMovie.routeName,
                        arguments: widget.genreModel);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                title: const Text("My Favorite Movie"),
              )
            ],
          ),
        )));
  }
}
