import 'package:flutter/material.dart';
import 'package:tflite_v2/tflite_v2.dart';


Future<bool> compareAndMatchImage(String imagePath) async {
  try {
    // 1. Load the TFLite model
    String? res = await Tflite.loadModel(
        model: "assets/tflite/model.tflite",
        labels: "assets/tflite/labels.txt",
        numThreads: 1,        // defaults to 1
        isAsset: true,        // set to false if you load model outside assets
        useGpuDelegate: false // set to true if you want to use GPU delegate
    );

    if (res == null) {
      print("Error loading TFLite model.");
      return false;
    } else {
      print("Model loaded: $res");
    }

    // 2. Run inference on the image
    final recognitions = await Tflite.runModelOnImage(
        path: imagePath,   // required
        imageMean: 0.0,    // defaults to 117.0
        imageStd: 255.0,   // defaults to 1.0
        numResults: 2,     // how many results to return
        threshold: 0.2,    // confidence threshold
        asynch: true       // whether inference runs asynchronously
    );

    // 3. Interpret the results
    if (recognitions != null && recognitions.isNotEmpty) {
      // Example: if the model returns a "confidence" field in each recognition
      final bestRecognition = recognitions.first;
      final double confidence = bestRecognition['confidence'];
      final String label = bestRecognition['label'];
      print("Recognition result: $bestRecognition");
      print("Detected label: $label with confidence: $confidence");

      // 4. Decide whether it's a match (using threshold 0.5, for example)
      await Tflite.close();  // unload the model
      return confidence > 0.5;
    } else {
      print("No recognitions found.");
      await Tflite.close();
      return false;
    }
  } catch (e) {
    print("Error during model inference: $e");
    await Tflite.close();
    return false;
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
