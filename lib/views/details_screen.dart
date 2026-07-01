import 'package:flutter/material.dart';
import 'package:pokedex/widgets/pokeloader.dart';
import 'package:pokedex/widgets/pokemon_text.dart';
import 'package:pokedex/widgets/pokedex_ui.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/models/pokemon_model.dart';
import 'package:pokedex/viewModels/pokemon_details_viewmodel.dart';
import 'package:pokedex/utils/utils.dart';

class DetailsScreen extends StatelessWidget {
  final PokemonModel pokemon;

  const DetailsScreen({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          PokemonDetailsViewModel()..fetchPokemonDetails(pokemon),
      child: Scaffold(
        backgroundColor: const Color(0xFF111111),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: PokedexBody(
                  child: Column(
                    children: [
                      _buildTopBar(context),
                      const PokedexHinge(),
                      Expanded(
                        child: Consumer<PokemonDetailsViewModel>(
                          builder: (context, vm, _) {
                            if (vm.isLoading) {
                              return const Center(
                                  child: PokeballLoader(size: 60));
                            }
                            if (vm.error != null) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: kScreenGreen, size: 32),
                                    const SizedBox(height: 8),
                                    const PokemonText(
                                      text: 'LOAD ERROR',
                                      color: Colors.red,
                                      fontSize: 11,
                                    ),
                                  ],
                                ),
                              );
                            }
                            final details = vm.pokemon;
                            if (details == null) {
                              return const Center(
                                child: PokemonText(
                                  text: 'NO DATA',
                                  color: kScreenGreen,
                                  fontSize: 11,
                                ),
                              );
                            }
                            return _PokedexDetailsBody(pokemon: details);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PokedexLens(onTap: () => Navigator.pop(context)),
          const SizedBox(width: 12),
          const PokedexIndicatorLights(),
          const Spacer(),
          PokemonText(
            text: pokemon.name.toUpperCase(),
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}

// ── Details body ──────────────────────────────────────────────────────────────

class _PokedexDetailsBody extends StatelessWidget {
  final PokemonModel pokemon;
  const _PokedexDetailsBody({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(pokemon.url.split('/')[6]) ?? 1;
    final moves = (pokemon.moves.where((m) => m.lvl != 0).toList()
      ..sort((a, b) => a.lvl.compareTo(b.lvl)));

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        children: [
          // ── Main screen (image + types) ──────────────────────────────
          SizedBox(
            height: 210,
            child: PokedexScreen(
              child: Stack(
                children: [
                  // Masterball watermark
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.04,
                      child: Image.asset(
                        'assets/images/masterball.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      // ID badge
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 6, 10, 0),
                          child: PokemonText(
                            text: '#${id.toString().padLeft(3, '0')}',
                            fontSize: 9,
                            color: kScreenGreen.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      // Sprite
                      Expanded(
                        child: Center(
                          child: Image.network(
                            pokemon.imageUrl,
                            height: 130,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.catching_pokemon,
                              color: kScreenGreen,
                              size: 80,
                            ),
                          ),
                        ),
                      ),
                      // Type badges
                      if (pokemon.types.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: pokemon.types.map((type) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: getTypeColor(type),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.white24, width: 1),
                                ),
                                child: PokemonText(
                                  text: type.toUpperCase(),
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Moves label ──────────────────────────────────────────────
          const Align(
            alignment: Alignment.centerLeft,
            child: PokemonText(
              text: '▸ MOVES',
              fontSize: 10,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 6),

          // ── Moves list screen ────────────────────────────────────────
          Expanded(
            child: PokedexScreen(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 2),
                itemCount: moves.length,
                itemBuilder: (context, i) {
                  final move = moves[i];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: kScreenGreen.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.chevron_right,
                            color: kScreenGreen, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: PokemonText(
                            text: move.name.replaceAll('-', ' ').toUpperCase(),
                            fontSize: 9,
                            color: kScreenGreen,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0).withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: PokemonText(
                            text: 'LV${move.lvl}',
                            fontSize: 8,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
