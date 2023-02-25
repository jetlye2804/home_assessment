class GenreModel {
  List<GenreChildModel>? genres;

  // Constructor
  GenreModel({this.genres});

  // Convert JSON into model data
  GenreModel.fromJSON(Map<String, dynamic> json) {
    if (json['genres'] != null) {
      genres = <GenreChildModel>[];
      json['genres']
          .forEach((item) => {genres!.add(GenreChildModel.fromJSON(item))});
    }
  }

  // Convert model data to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (genres != null) {
      data['genres'] = genres!.map((item) => item.toJson()).toList();
    }
    return data;
  }
}

class GenreChildModel {
  int? id;
  String? name;

  // Constructor
  GenreChildModel({this.id, this.name});

  // Convert JSON into model data
  GenreChildModel.fromJSON(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  // Convert model data to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
