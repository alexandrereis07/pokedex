import 'package:flutter/material.dart';
import 'package:pokedex/widgets/painters/pokeloader_painter.dart';

class PokeballLoader extends StatefulWidget {
  final double size;

  const PokeballLoader({super.key, this.size = 50.0});

  @override
  State<PokeballLoader> createState() => _PokeballLoaderState();
}

class _PokeballLoaderState extends State<PokeballLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: PokeloaderPainter(),
      ),
    );
  }
}
