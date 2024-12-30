class PokemonModel {
  final String name;
  final String url;
  final String imageUrl;
  List<String>? types;
  List<Moves>? moves;

  PokemonModel({
    required this.name,
    required this.url,
    required this.imageUrl,
    this.types,
    this.moves,
  });

  factory PokemonModel.fromJson(Map<String, dynamic> json) {
    final String url = json['url'];
    final int id = int.parse(url.split('/')[6]);
    final String imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

    return PokemonModel(
      name: json['name'],
      url: url,
      imageUrl: imageUrl,
    );
  }
}

class Moves {
  final int lvl;
  final String name;

  Moves({
    required this.lvl,
    required this.name,
  });
}
