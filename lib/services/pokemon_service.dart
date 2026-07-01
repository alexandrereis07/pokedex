import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokedex/models/pokemon_model.dart';

class PokemonService {
  static const _baseUrl = 'https://pokeapi.co/api/v2';

  Future<List<PokemonModel>> fetchPokemons({int limit = 151}) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/pokemon?limit=$limit'));

    if (response.statusCode == 200) {
      final List<dynamic> data =
          json.decode(response.body)['results'] as List;
      return data
          .map((item) =>
              PokemonModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception(
        'Failed to load Pokémon list (${response.statusCode})');
  }

  Future<PokemonModel> fetchPokemonByName(String name) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/pokemon/${name.toLowerCase()}'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final int id = data['id'] as int;
      return PokemonModel(
        name: name.toLowerCase(),
        url: '$_baseUrl/pokemon/$id/',
        imageUrl:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
      );
    }
    throw Exception('Pokémon "$name" not found (${response.statusCode})');
  }

  Future<PokemonModel> fetchPokemonDetails(PokemonModel pokemon) async {
    final response = await http.get(Uri.parse(pokemon.url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;

      final types = (data['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList();

      final moves = (data['moves'] as List)
          .map((m) => PokemonMove(
                lvl: (m['version_group_details'] as List)
                    .first['level_learned_at'] as int,
                name: m['move']['name'] as String,
              ))
          .toList();

      return pokemon.copyWith(types: types, moves: moves);
    }
    throw Exception(
        'Failed to load details for ${pokemon.name} (${response.statusCode})');
  }
}
