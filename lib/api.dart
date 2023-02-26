import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:home_assessment/models/error_model.dart';
import 'package:home_assessment/models/genre_model.dart';
import 'package:home_assessment/models/movie_detail_model.dart';
import 'package:home_assessment/models/now_playing_model.dart';
import 'package:home_assessment/models/top_ten_movie_model.dart';
import 'package:home_assessment/storage_manager.dart';
import 'package:http/http.dart' as http;

class API {
  final String? _apiKey = dotenv.env['MOVIE_API_KEY'];
  final String? _apiUrl = dotenv.env['MOVIE_API_URL'];

  void printWrapped(String text) {
    final pattern = RegExp('.{1,1019}');
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  Future<http.Response> postDataAPI(Uri url, Object? body) async {
    printWrapped('POST --> $url');
    printWrapped('POST --> $body');
    var response = await http.post(url, body: body);
    printWrapped('GET <-- ${response.statusCode}');

    return response;
  }

  Future<http.Response> getDataAPI(Uri url) async {
    printWrapped('GET --> $url');
    var response = await http.get(url);
    printWrapped('GET <-- ${response.statusCode}');
    // printWrapped('GET <-- ${response.body}');

    return response;
  }

  login() async {
    await StorageManager.readData('session_id').then((value) async {
      if (value != null) {
        StorageManager.deleteData('session_id');
        print("Deleted old session ID");
      }
    });

    var requestTokenPath = '/3/authentication/token/new';
    var requestTokenUrl =
        Uri.https(_apiUrl!, requestTokenPath, {'api_key': _apiKey!});
    var requestTokenResponse = await getDataAPI(requestTokenUrl);
    var decodedRequestTokenResponse = json.decode(requestTokenResponse.body);

    bool requestTokenSuccess = decodedRequestTokenResponse['success'];

    if (requestTokenSuccess == false) {
      throw decodedRequestTokenResponse['status_message'];
    } else {
      var requestToken = decodedRequestTokenResponse['request_token'];
      var validateLoginPath = '/3/authentication/token/validate_with_login';
      var validateLoginUrl =
          Uri.https(_apiUrl!, validateLoginPath, {'api_key': _apiKey!});
      Map<String, dynamic> loginData = <String, dynamic>{};
      loginData['username'] = 'jetlye';
      loginData['password'] = 'iamklpeople990428';
      loginData['request_token'] = requestToken;
      var validateLoginResponse =
          await postDataAPI(validateLoginUrl, loginData);
      var decodedValidateLoginResponse =
          json.decode(validateLoginResponse.body);

      bool validateLoginSuccess = decodedValidateLoginResponse['success'];

      if (validateLoginSuccess == false) {
        throw decodedValidateLoginResponse['status_message'];
      } else {
        var successRequestToken = decodedValidateLoginResponse['request_token'];
        var sessionPath = '/3/authentication/session/new';
        var sessionUrl =
            Uri.https(_apiUrl!, sessionPath, {'api_key': _apiKey!});
        Map<String, dynamic> sessionData = <String, dynamic>{};
        sessionData['request_token'] = successRequestToken;
        var sessionResponse = await postDataAPI(sessionUrl, sessionData);
        var decodedSessionResponse = json.decode(sessionResponse.body);

        bool sessionSuccess = decodedSessionResponse['success'];

        if (sessionSuccess == false) {
          throw decodedSessionResponse['status_message'];
        } else {
          var sessionId = decodedSessionResponse['session_id'];
          StorageManager.saveData('session_id', sessionId);
          print("Saved new session ID");
        }
      }
    }
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

  Future<TopTenMovieModel> getTopTen([String? page]) async {
    var path = '/3/movie/popular';
    var requestUrl =
        Uri.https(_apiUrl!, path, {'api_key': _apiKey!, 'page': page ?? '1'});
    var response = await getDataAPI(requestUrl);
    var decodedResponse = json.decode(response.body);
    final topTenMovieModel = TopTenMovieModel.fromJSON(decodedResponse);

    if (topTenMovieModel.toJson().isEmpty) {
      throw ErrorModel.fromJson(decodedResponse);
    }
    return topTenMovieModel;
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
