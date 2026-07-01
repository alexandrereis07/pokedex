import 'package:flutter/foundation.dart';
import 'package:pokedex/models/pokemon_model.dart';
import 'package:pokedex/services/pokemon_service.dart';

class PokemonHomeViewModel extends ChangeNotifier {
  final PokemonService _pokemonService = PokemonService();

  List<PokemonModel> _pokemons = [];
  String? _error;
  bool _isLoading = false;

  List<PokemonModel> get pokemons => _pokemons;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> fetchPokemons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pokemons = await _pokemonService.fetchPokemons();
    } catch (e) {
      _error = e.toString();
      debugPrint('PokemonHomeViewModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
