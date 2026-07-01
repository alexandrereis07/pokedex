import 'package:flutter/material.dart';
import 'package:pokedex/models/pokemon_model.dart';
import 'package:pokedex/views/details_screen.dart';
import 'package:pokedex/views/camera_screen.dart';
import 'package:pokedex/widgets/pokeloader.dart';
import 'package:pokedex/widgets/pokemon_text.dart';
import 'package:pokedex/widgets/pokedex_ui.dart';
import 'package:provider/provider.dart';
import '../viewModels/pokemon_home_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PokemonHomeViewModel>().fetchPokemons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PokemonHomeViewModel>();

    return Scaffold(
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
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                        child: PokedexScreen(
                          label: 'POKEMON LIST',
                          child: _buildListContent(viewModel),
                        ),
                      ),
                    ),
                    const PokedexHinge(),
                    _buildControls(),
                  ],
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
          PokedexLens(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CameraScreen()),
            ),
          ),
          const SizedBox(width: 12),
          const PokedexIndicatorLights(),
          const Spacer(),
          const PokemonText(
            text: 'POKEDEX',
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(PokemonHomeViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: PokeballLoader(size: 50.0));
    }
    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: kScreenGreen, size: 28),
            const SizedBox(height: 8),
            const PokemonText(
              text: 'ERROR LOADING',
              color: Colors.red,
              fontSize: 10,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => context.read<PokemonHomeViewModel>().fetchPokemons(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: kScreenGreen),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const PokemonText(
                  text: '[ RETRY ]',
                  color: kScreenGreen,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: viewModel.pokemons.length,
      itemBuilder: (context, index) => _PokemonListTile(
        index: index,
        pokemon: viewModel.pokemons[index],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const PokedexSpeaker(),
          const Spacer(),
          const PokedexDPad(),
          const Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const PokedexActionButton(
                color: Color(0xFF1565C0),
                label: 'A',
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  PokedexPillButton(label: 'SEL'),
                  SizedBox(width: 6),
                  PokedexPillButton(label: 'STA'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Pokemon list tile ─────────────────────────────────────────────────────────

class _PokemonListTile extends StatelessWidget {
  final int index;
  final PokemonModel pokemon;

  const _PokemonListTile({required this.index, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailsScreen(pokemon: pokemon)),
      ),
      splashColor: kScreenGreen.withValues(alpha: 0.1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
            // Number
            SizedBox(
              width: 38,
              child: PokemonText(
                text: '#${(index + 1).toString().padLeft(3, '0')}',
                fontSize: 9,
                color: kScreenGreen.withValues(alpha: 0.55),
              ),
            ),
            // Sprite
            Image.network(
              pokemon.imageUrl,
              width: 36,
              height: 36,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.catching_pokemon,
                color: kScreenGreen,
                size: 30,
              ),
            ),
            const SizedBox(width: 10),
            // Name
            Expanded(
              child: PokemonText(
                text: pokemon.name.toUpperCase(),
                fontSize: 11,
                color: kScreenGreen,
              ),
            ),
            const Icon(Icons.chevron_right, color: kScreenGreen, size: 16),
          ],
        ),
      ),
    );
  }
}
