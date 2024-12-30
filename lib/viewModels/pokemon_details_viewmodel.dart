import 'package:flutter/material.dart';
import 'package:pokedex/models/pokemon_model.dart';
import 'package:pokedex/services/pokemon_service.dart';

class PokemonDetailsViewModel extends ChangeNotifier {
  final PokemonService _pokemonService = PokemonService();
  bool _isLoading = true;
  PokemonModel? _pokemon;

  bool get isLoading => _isLoading;
  PokemonModel? get pokemon => _pokemon;

  Future<void> fetchPokemonDetails(PokemonModel pokemon) async {
    _isLoading = true;
    notifyListeners();

    try {
      _pokemon = await _pokemonService.fetchPokemonDetails(pokemon);
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
