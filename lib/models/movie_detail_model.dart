import 'package:home_assessment/models/genre_model.dart';

class MovieDetailModel {
  bool? adult;
  String? backdropPath;
  BelongsCollectionModel? belongsToCollection;
  int? budget;
  List<GenreChildModel>? genres;
  Uri? homepage;
  int? id;
  String? imdbId;
  String? originalLanguage;
  String? originalTitle;
  String? overview;
  double? popularity;
  String? posterPath;
  List<ProductionCompanyModel>? productionCompanies;
  List<ProductionCountryModel>? productionCountries;
  String? releaseDate;
  int? revenue;
  int? runtime; // The duration of the movie
  List<SpokenLanguageModel>? spokenLanguages;
  String? status;
  String? tagline;
  String? title;
  bool? video;
  double? voteAverage;
  int? voteCount;

  MovieDetailModel(
      {this.adult,
      this.backdropPath,
      this.belongsToCollection,
      this.budget,
      this.genres,
      this.homepage,
      this.id,
      this.imdbId,
      this.originalLanguage,
      this.originalTitle,
      this.overview,
      this.popularity,
      this.posterPath,
      this.productionCompanies,
      this.productionCountries,
      this.releaseDate,
      this.revenue,
      this.runtime,
      this.spokenLanguages,
      this.status,
      this.tagline,
      this.title,
      this.video,
      this.voteAverage,
      this.voteCount});

  MovieDetailModel.fromJson(Map<String, dynamic> json) {
    adult = json['adult'];
    backdropPath = json['backdrop_path'];
    if (json['belongs_to_collection'] != null) {
      belongsToCollection =
          BelongsCollectionModel.fromJson(json['belongs_to_collection']);
    }
    budget = json['budget'];
    if (json['genres'] != null) {
      genres = <GenreChildModel>[];
      json['genres']
          .forEach((item) => {genres!.add(GenreChildModel.fromJSON(item))});
    }
    homepage = Uri.parse(json['homepage']);
    id = json['id'];
    imdbId = json['imdb_id'];
    originalLanguage = json['original_language'];
    originalTitle = json['original_title'];
    overview = json['overview'];
    popularity = json['popularity'];
    posterPath = json['poster_path'];

    if (json['production_companies'] != null) {
      productionCompanies = <ProductionCompanyModel>[];
      json['production_companies'].forEach((item) =>
          {productionCompanies!.add(ProductionCompanyModel.fromJson(item))});
    }

    if (json['production_countries'] != null) {
      productionCountries = <ProductionCountryModel>[];
      json['production_countries'].forEach((item) =>
          {productionCountries!.add(ProductionCountryModel.fromJson(item))});
    }

    releaseDate = json['release_date'];
    revenue = json['revenue'];
    runtime = json['runtime'];
    if (json['spoken_languages'] != null) {
      spokenLanguages = <SpokenLanguageModel>[];
      json['spoken_languages'].forEach(
          (item) => {spokenLanguages!.add(SpokenLanguageModel.fromJson(item))});
    }

    status = json['status'];
    tagline = json['tagline'];
    title = json['title'];
    video = json['video'];
    if (json['vote_average'] is int) {
      voteAverage = json['vote_average'].toDouble();
    } else {
      voteAverage = json['vote_average'];
    }

    voteCount = json['vote_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['adult'] = adult;
    data['backdrop_path'] = backdropPath;
    if (belongsToCollection != null) {
      data['belongs_to_collection'] = belongsToCollection!.toJson();
    }
    data['budget'] = budget;
    if (genres != null) {
      data['genres'] = genres!.map((item) => item.toJson()).toList();
    }
    data['homepage'] = homepage.toString();
    data['id'] = id;
    data['imdb_id'] = imdbId;
    data['original_language'] = originalLanguage;
    data['original_title'] = originalTitle;
    data['overview'] = overview;
    data['popularity'] = popularity;
    data['poster_path'] = posterPath;
    if (productionCompanies != null) {
      data['production_companies'] =
          productionCompanies!.map((item) => item.toJson()).toList();
    }
    if (productionCountries != null) {
      data['production_countries'] =
          productionCountries!.map((item) => item.toJson()).toList();
    }
    data['release_date'] = releaseDate;
    data['revenue'] = revenue;
    data['runtime'] = runtime;
    if (spokenLanguages != null) {
      data['spoken_languages'] =
          spokenLanguages!.map((item) => item.toJson()).toList();
    }
    data['status'] = status;
    data['tagline'] = tagline;
    data['title'] = title;
    data['video'] = video;
    data['vote_average'] = voteAverage;
    data['vote_count'] = voteCount;
    return data;
  }
}

class BelongsCollectionModel {
  int? id;
  String? name;
  String? posterPath;
  String? backdropPath;

  BelongsCollectionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    posterPath = json['poster_path'];
    backdropPath = json['backdrop_path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['poster_path'] = posterPath;
    data['backdrop_path'] = backdropPath;
    return data;
  }
}

class ProductionCompanyModel {
  int? id;
  String? logoPath;
  String? name;
  String? originCountry;

  ProductionCompanyModel(
      {this.id, this.logoPath, this.name, this.originCountry});

  ProductionCompanyModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    logoPath = json['logo_path'];
    name = json['name'];
    originCountry = json['origin_country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['logo_path'] = logoPath;
    data['name'] = name;
    data['origin_country'] = originCountry;
    return data;
  }
}

class ProductionCountryModel {
  String? iso31661;
  String? name;

  ProductionCountryModel({this.iso31661, this.name});

  ProductionCountryModel.fromJson(Map<String, dynamic> json) {
    iso31661 = json['iso_3166_1'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['iso_3166_1'] = iso31661;
    data['name'] = name;
    return data;
  }
}

class SpokenLanguageModel {
  String? englishName;
  String? iso6391;
  String? name;

  SpokenLanguageModel({this.englishName, this.iso6391, this.name});

  SpokenLanguageModel.fromJson(Map<String, dynamic> json) {
    englishName = json['english_name'];
    iso6391 = json['iso_639_1'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['english_name'] = englishName;
    data['iso_639_1'] = iso6391;
    data['name'] = name;
    return data;
  }
}
