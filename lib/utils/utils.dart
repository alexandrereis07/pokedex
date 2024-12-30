import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

Future<bool> compareAndMatchImage(String imagePath) async {
  try {
    // 1. Load the TFLite model
    final interpreter = await Interpreter.fromAsset('assets/tflite/model.tflite');

    // 2. Load & decode the image
    final imageFile = File(imagePath);
    final rawImage = imageFile.readAsBytesSync();
    final decodedImage = img.decodeImage(rawImage);
    if (decodedImage == null) {
      print('Error: Unable to decode image.');
      return false;
    }

    // 3. Model input size
    const int inputSize = 224; // Adjust if your model expects a different size
    final resizedImage = img.copyResize(decodedImage, width: inputSize, height: inputSize);

    // 4. Build a 3D array: shape = [224][224][3]
    final image3D = List.generate(
      inputSize,
          (y) => List.generate(
        inputSize,
            (x) {
          final pixel = resizedImage.getPixel(x, y);
          return [
            img.getRed(pixel) / 255.0,
            img.getGreen(pixel) / 255.0,
            img.getBlue(pixel) / 255.0,
          ];
        },
      ),
    );

    // 5. Wrap it to make a 4D array: shape = [1][224][224][3]
    final input4D = [image3D];

    // 6. Prepare output buffer
    //    For example, if your model has 2 output classes
    final output = List.filled(2, 0).reshape([1, 2]);

    // 7. Run inference (pass the 4D input)
    interpreter.run(input4D, output);
    interpreter.close();

    print('Model Output: $output');

    // 8. Assuming your model’s first output index is the "match" probability
    final matchProbability = output[0][0];
    print('matchProbability: $matchProbability');

    return matchProbability > 0.5; // Adjust threshold to your needs
  } catch (e) {
    print('Error during model inference: $e');
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
