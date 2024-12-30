import 'package:flutter/material.dart';
import 'package:pokedex/models/pokemon_model.dart';

import 'package:pokedex/services/pokemon_service.dart';

class PokemonViewModel extends ChangeNotifier {
  final PokemonService _pokemonService = PokemonService();
  List<PokemonModel> _pokemons = [];
  bool _isLoading = false;
  int _offset = 0;
  final int _limit = 10;
  final int _maxItems = 151;

  List<PokemonModel> get pokemons => _pokemons;
  bool get isLoading => _isLoading;

  Future<void> fetchPokemons() async {
    if (_isLoading || _offset >= _maxItems) return;

    _isLoading = true;
    notifyListeners();

    try {
      List<PokemonModel> newPokemons =
          await _pokemonService.fetchPokemons(_offset, _limit);
      _pokemons.addAll(newPokemons);
      _offset += _limit;
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
