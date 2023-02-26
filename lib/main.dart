import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:home_assessment/api.dart';
import 'package:home_assessment/home.dart';
import 'package:home_assessment/models/genre_model.dart';
import 'package:home_assessment/models/now_playing_model.dart';
import 'package:home_assessment/movie_detail.dart';
import 'package:home_assessment/page_transition.dart';
import 'package:home_assessment/singleton_util.dart';

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
  Map<String, Widget>? routes;

  Future<void> initialization() async {
    routes = {
      Home.routeName: Home(),
      MovieDetail.routeName: MovieDetail(),
    };

    try {
      genreModel = API().getGenre();
    } catch (error) {
      if (error is ErrorModel) {
        print("error 2");
      }
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    this.context = context;
    initialization();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF000000)),
      home: FutureBuilder(
        future: Future.wait([genreModel]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.data != null) {
            FlutterNativeSplash.remove();
            print(snapshot.data);
            return Home(genreModel: snapshot.data![0]);
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
