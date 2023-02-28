import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:home_assessment/models/movie_model.dart';
import 'package:home_assessment/utils/api.dart';
import 'package:home_assessment/utils/storage_manager.dart';
import 'package:home_assessment/views/favorite_movie.dart';
import 'package:home_assessment/views/home.dart';
import 'package:home_assessment/models/genre_model.dart';
import 'package:home_assessment/models/now_playing_model.dart';
import 'package:home_assessment/views/movie_detail.dart';
import 'package:home_assessment/utils/page_transition.dart';
import 'package:home_assessment/views/search_movie.dart';
import 'package:home_assessment/views/top_ten_movie.dart';

import 'models/error_model.dart';

Future main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: 'environments/local.env');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  late BuildContext context;
  late Future<GenreModel> genreModel;
  Future<MovieModel>? favoriteMovieModel;
  Map<String, Widget>? routes;

  void initialization() async {
    routes = {
      Home.routeName: Home(),
      MovieDetail.routeName: MovieDetail(),
      TopTenMovie.routeName: TopTenMovie(),
      FavoriteMovie.routeName: FavoriteMovie(),
      SearchMovie.routeName: SearchMovie(),
    };

    try {
      genreModel = API().getGenre();
      await API().login();
    } catch (error) {
      if (error is ErrorModel) {
        print("error 1");
      }
    }
  }

  Future<MovieModel> loadFavoriteMovieModel() async {
    var sessionValue = await StorageManager.readData('session_id');
    var accountValue = await StorageManager.readData('account_id');
    return API().getFavoriteMovie(accountValue, sessionValue);
  }

  @override
  Widget build(BuildContext context) {
    // Workaround to load favorite movie model
    favoriteMovieModel = loadFavoriteMovieModel();
    this.context = context;
    initialization();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF000000)),
      home: FutureBuilder(
        future: Future.wait([genreModel, favoriteMovieModel!]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.data != null) {
            FlutterNativeSplash.remove();
            print(snapshot.data);
            return Home(
                genreModel: snapshot.data![0],
                favoriteMovieModel: snapshot.data![1]);
          } else {
            return Container();
          }
        },
      ),
      onGenerateRoute: (RouteSettings route) {
        return PageTransition(child: routes![route.name]!, settings: route);
      },
    );
  }
}
