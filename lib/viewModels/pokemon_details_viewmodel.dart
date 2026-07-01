import 'package:flutter/foundation.dart';
import 'package:pokedex/models/pokemon_model.dart';
import 'package:pokedex/services/pokemon_service.dart';

class PokemonDetailsViewModel extends ChangeNotifier {
  final PokemonService _pokemonService = PokemonService();

  bool _isLoading = true;
  PokemonModel? _pokemon;
  String? _error;

  bool get isLoading => _isLoading;
  PokemonModel? get pokemon => _pokemon;
  String? get error => _error;

  Future<void> fetchPokemonDetails(PokemonModel pokemon) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pokemon = await _pokemonService.fetchPokemonDetails(pokemon);
    } catch (e) {
      _error = e.toString();
      debugPrint('PokemonDetailsViewModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
