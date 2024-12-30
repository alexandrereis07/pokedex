import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokedex/models/pokemon_model.dart';

class PokemonService {
  Future<List<PokemonModel>> fetchPokemons(int offset, int limit) async {
    final response = await http.get(Uri.parse(
        'https://pokeapi.co/api/v2/pokemon?offset=$offset&limit=$limit'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['results'];
      return data.map((item) => PokemonModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<PokemonModel> fetchPokemonDetails(PokemonModel pokemon) async {
    final response = await http.get(Uri.parse(pokemon.url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<String> types = (data['types'] as List)
          .map((typeInfo) => typeInfo['type']['name'] as String)
          .toList();

      List<Moves> moves = (data['moves'] as List)
          .map((moveInfo) => Moves(
                lvl: (moveInfo['version_group_details'] as List)
                    .first['level_learned_at'],
                name: moveInfo['move']['name'],
              ))
          .toList();

      pokemon.types = types;
      pokemon.moves = moves;

      return pokemon;
    } else {
      throw Exception('Failed to load details');
    }
  }
}
