import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:home_assessment/models/error_model.dart';
import 'package:home_assessment/models/genre_model.dart';
import 'package:home_assessment/models/movie_detail_model.dart';
import 'package:home_assessment/models/now_playing_model.dart';
import 'package:http/http.dart' as http;

class API {
  final String? _apiKey = dotenv.env['MOVIE_API_KEY'];
  final String? _apiUrl = dotenv.env['MOVIE_API_URL'];

  void printWrapped(String text) {
    final pattern = RegExp('.{1,1019}');
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  Future<http.Response> getDataAPI(Uri url) async {
    printWrapped('GET --> $url');
    var response = await http.get(url);
    printWrapped('GET <-- ${response.statusCode}');
    // printWrapped('GET <-- ${response.body}');

    return response;
  }

  Future<NowPlayingModel> getNowPlaying([String? page]) async {
    var path = '/3/movie/now_playing';
    var requestUrl =
        Uri.https(_apiUrl!, path, {'api_key': _apiKey!, 'page': page ?? '1'});
    var response = await getDataAPI(requestUrl);
    var decodedResponse = json.decode(response.body);
    final nowPlayingModel = NowPlayingModel.fromJSON(decodedResponse);

    if (nowPlayingModel.toJson().isEmpty) {
      throw ErrorModel.fromJson(decodedResponse);
    }
    return nowPlayingModel;
  }

  Future<GenreModel> getGenre() async {
    var path = '/3/genre/movie/list';
    var requestUrl = Uri.https(_apiUrl!, path, {'api_key': _apiKey!});
    var response = await getDataAPI(requestUrl);
    var decodedResponse = json.decode(response.body);
    final genreModel = GenreModel.fromJSON(decodedResponse);

    if (genreModel.toJson().isEmpty) {
      throw ErrorModel.fromJson(decodedResponse);
    }
    return genreModel;
  }

  Future<MovieDetailModel> getMovieDetail(String movieId) async {
    var path = '/3/movie/$movieId';
    var requestUrl = Uri.https(_apiUrl!, path, {'api_key': _apiKey!});
    var response = await getDataAPI(requestUrl);
    var decodedResponse = json.decode(response.body);
    final movieDetailModel = MovieDetailModel.fromJson(decodedResponse);

    if (movieDetailModel.toJson().isEmpty) {
      throw ErrorModel.fromJson(decodedResponse);
    }
    return movieDetailModel;
  }
}
