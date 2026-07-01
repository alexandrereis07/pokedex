import 'package:flutter/material.dart';
import 'package:tflite_v2/tflite_v2.dart';

/// Maps TFLite label names to PokeAPI-compatible names.
String _toPokeApiName(String label) {
  const overrides = {
    'MrMime': 'mr-mime',
    'Farfetchd': 'farfetchd',
    'NidoranF': 'nidoran-f',
    'NidoranM': 'nidoran-m',
  };
  return overrides[label] ?? label.toLowerCase();
}

/// Returns the detected Pokémon PokeAPI name if confidence > 0.35, otherwise null.
Future<String?> compareAndMatchImage(String imagePath) async {
  try {
    final res = await Tflite.loadModel(
      model: 'assets/tflite/model.tflite',
      labels: 'assets/tflite/labels.txt',
      numThreads: 2,
      isAsset: true,
      useGpuDelegate: false,
    );

    if (res == null) {
      debugPrint('Error loading TFLite model.');
      return null;
    }

    final recognitions = await Tflite.runModelOnImage(
      path: imagePath,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 3,
      threshold: 0.05,
      asynch: true,
    );

    await Tflite.close();

    if (recognitions != null && recognitions.isNotEmpty) {
      for (final r in recognitions) {
        debugPrint('  >> ${r['label']} : ${(r['confidence'] as double).toStringAsFixed(3)}');
      }
      final best = recognitions.first;
      final double confidence = best['confidence'] as double;
      final String label = best['label'] as String;
      debugPrint('Best: $label ($confidence)');
      if (confidence > 0.30) {
        return _toPokeApiName(label);
      }
      debugPrint('Confidence too low: $confidence');
    } else {
      debugPrint('Recognitions list empty or null');
    }

    return null;
  } catch (e) {
    debugPrint('TFLite inference error: $e');
    await Tflite.close();
    return null;
  }
}

Color getTypeColor(String type) {
  switch (type.toLowerCase()) {
    case 'water':
      return Colors.blue;
    case 'fire':
      return Colors.red;
    case 'grass':
      return Colors.green;
    case 'electric':
      return Colors.yellow;
    case 'ice':
      return Colors.lightBlueAccent;
    case 'fighting':
      return Colors.orange;
    case 'poison':
      return Colors.purple;
    case 'ground':
      return Colors.brown;
    case 'flying':
      return Colors.lightBlue;
    case 'psychic':
      return Colors.pink;
    case 'bug':
      return Colors.lightGreen;
    case 'rock':
      return Colors.grey;
    case 'ghost':
      return Colors.deepPurple;
    case 'dragon':
      return Colors.indigo;
    case 'dark':
      return Colors.black;
    case 'steel':
      return Colors.blueGrey;
    case 'fairy':
      return Colors.pinkAccent;
    default:
      return Colors.grey;
  }
}
