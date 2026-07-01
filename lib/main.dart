import 'package:flutter/material.dart';
import 'package:pokedex/viewModels/pokemon_home_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/views/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PokemonHomeViewModel()),
      ],
      child: MaterialApp(
        title: 'Pokedex',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
