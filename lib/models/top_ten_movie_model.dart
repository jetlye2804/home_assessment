class TopTenMovieModel {
  int? page;
  List<NowPlayingMovieData>? results;
  int? totalPages;
  int? totalResults;

  // Constructor
  TopTenMovieModel(
      {this.page, this.results, this.totalPages, this.totalResults});

  // Convert JSON into model data
  TopTenMovieModel.fromJSON(Map<String, dynamic> json) {
    page = json['page'];
    if (json['results'] != null) {
      results = <NowPlayingMovieData>[];
      json['results'].forEach(
          (item) => {results!.add(NowPlayingMovieData.fromJson(item))});
    }
    totalPages = json['total_pages'];
    totalResults = json['total_results'];
  }

  // Convert model data to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    if (results != null) {
      data['results'] = results!.map((item) => item.toJson()).toList();
    }
    data['total_pages'] = totalPages;
    data['total_results'] = totalResults;
    return data;
  }
}

class NowPlayingMovieData {
  bool? adult;
  String? backdropPath;
  List<int>? genreIds;
  int? id;
  String? originalLanguage;
  String? originalTitle;
  String? overview;
  double? popularity;
  String? posterPath;
  String? releaseDate;
  String? title;
  bool? video;
  double? voteAverage;
  int? voteCount;

  // Constructor
  NowPlayingMovieData(
      {this.adult,
      this.backdropPath,
      this.genreIds,
      this.id,
      this.originalLanguage,
      this.originalTitle,
      this.overview,
      this.popularity,
      this.posterPath,
      this.releaseDate,
      this.title,
      this.video,
      this.voteAverage,
      this.voteCount});

  // Convert JSON into model data
  NowPlayingMovieData.fromJson(Map<String, dynamic> json) {
    adult = json['adult'];
    backdropPath = json['backdrop_path'];

    var genreIdsFromJson = json['genre_ids'];
    List<int> genreIdsList = List<int>.from(genreIdsFromJson);
    genreIds = genreIdsList;

    id = json['id'];
    originalLanguage = json['original_language'];
    originalTitle = json['original_title'];
    overview = json['overview'];
    popularity = json['popularity'];
    posterPath = json['poster_path'];
    releaseDate = json['release_date'];
    title = json['title'];
    video = json['video'];

    if (json['vote_average'] is int) {
      voteAverage = json['vote_average'].toDouble();
    } else {
      voteAverage = json['vote_average'];
    }

    voteCount = json['vote_count'];
  }

  // Convert model data to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['adult'] = adult;
    data['backdrop_path'] = backdropPath;
    data['genre_ids'] = genreIds;
    data['id'] = id;
    data['original_language'] = originalLanguage;
    data['original_title'] = originalTitle;
    data['overview'] = overview;
    data['popularity'] = popularity;
    data['poster_path'] = posterPath;
    data['release_date'] = releaseDate;
    data['title'] = title;
    data['video'] = video;
    data['vote_average'] = voteAverage;
    data['vote_count'] = voteCount;
    return data;
  }
}
