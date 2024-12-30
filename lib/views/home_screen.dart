import 'package:flutter/material.dart';
import 'package:pokedex/views/datails_screen.dart';
import 'package:pokedex/views/camera_screen.dart'; // Import the CameraScreen
import 'package:provider/provider.dart';
import 'package:pokedex/viewmodels/pokemon_viewmodel.dart';
import 'package:pokedex/widgets/pokemon_text.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PokemonViewModel>(context, listen: false).fetchPokemons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pokemonViewModel = Provider.of<PokemonViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.fill,
              colorBlendMode: BlendMode.dstATop,
            ),
          ),
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                  !pokemonViewModel.isLoading) {
                pokemonViewModel.fetchPokemons();
              }
              return false;
            },
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
                margin: EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: pokemonViewModel.pokemons.length +
                      (pokemonViewModel.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == pokemonViewModel.pokemons.length) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return ListTile(
                      leading: Image.network(
                          pokemonViewModel.pokemons[index].imageUrl),
                      title: PokemonText(
                        text: pokemonViewModel.pokemons[index].name.toUpperCase(),
                        fontSize: 18,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(
                                pokemon: pokemonViewModel.pokemons[index]),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CameraScreen(), // Navigate to CameraScreen
            ),
          );
        },
        child: Icon(Icons.camera),
      ),
    );
  }
}
