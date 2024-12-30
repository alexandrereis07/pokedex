import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/models/pokemon_model.dart';
import 'package:pokedex/viewmodels/pokemon_details_viewmodel.dart';
import 'package:pokedex/widgets/pokemon_text.dart';
import 'package:pokedex/utils/utils.dart';

class DetailsScreen extends StatelessWidget {
  final PokemonModel pokemon;

  DetailsScreen({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PokemonDetailsViewModel()..fetchPokemonDetails(pokemon),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: PokemonText(
            text: pokemon.name.toUpperCase(),
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  'assets/images/masterball.png',
                  fit: BoxFit.cover,
                  colorBlendMode: BlendMode.dstATop,
                ),
              ),
            ),
            Consumer<PokemonDetailsViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                final pokemon = viewModel.pokemon;
                if (pokemon == null) {
                  return Center(child: Text('Failed to load details'));
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.network(
                      pokemon.imageUrl,
                      width: 100,
                    ),
                    SizedBox(height: 10),
                    PokemonText(
                      text: 'Types:',
                      fontSize: 18,
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: pokemon.types?.map((type) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: getTypeColor(type),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: PokemonText(
                                text: type.toUpperCase(),
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList() ??
                          [],
                    ),
                    SizedBox(height: 10),
                    PokemonText(
                      text: 'Moves:',
                      fontSize: 18,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: pokemon.moves
                                  ?.map((move) => Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            PokemonText(
                                              text: move.name,
                                              fontSize: 16,
                                            ),
                                            PokemonText(
                                              text: 'Level ${move.lvl}',
                                              fontSize: 16,
                                            ),
                                          ],
                                        ),
                                      ))
                                  .toList() ??
                              [],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
