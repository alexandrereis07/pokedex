import 'package:flutter/material.dart';
import 'package:pokedex/views/camera_screen.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/viewmodels/pokemon_viewmodel.dart';
import 'package:pokedex/views/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PokemonViewModel()),
      ],
      child: MaterialApp(
        title: 'Pokedex',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
