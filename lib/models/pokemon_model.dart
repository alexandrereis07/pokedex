class PokemonModel {
  final String name;
  final String url;
  final String imageUrl;
  final List<String> types;
  final List<PokemonMove> moves;

  const PokemonModel({
    required this.name,
    required this.url,
    required this.imageUrl,
    this.types = const [],
    this.moves = const [],
  });

  factory PokemonModel.fromJson(Map<String, dynamic> json) {
    final String url = json['url'] as String;
    final int id = int.parse(url.split('/')[6]);
    return PokemonModel(
      name: json['name'] as String,
      url: url,
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
    );
  }

  PokemonModel copyWith({
    String? name,
    String? url,
    String? imageUrl,
    List<String>? types,
    List<PokemonMove>? moves,
  }) {
    return PokemonModel(
      name: name ?? this.name,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      types: types ?? this.types,
      moves: moves ?? this.moves,
    );
  }
}

class PokemonMove {
  final int lvl;
  final String name;

  const PokemonMove({required this.lvl, required this.name});
}
