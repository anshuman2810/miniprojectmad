import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class TfliteService {
  static Interpreter? _interpreter;

  Future<void> loadModel() async {
    try {
      // Load the TFLite model
      final interpreterOptions = InterpreterOptions();

      // Load model from assets
      final modelBuffer = await rootBundle.load('assets/models/colorization_model.tflite');
      _interpreter = await Interpreter.fromBuffer(
        modelBuffer.buffer.asUint8List(),
        options: interpreterOptions,
      );

      print('TFLite model loaded successfully');
    } catch (e) {
      print('Error loading TFLite model: $e');
      rethrow;
    }
  }

  Future<String> colorizeImage(String imagePath) async {
    if (_interpreter == null) {
      await loadModel();
    }

    // Read the image file
    final imageFile = File(imagePath);
    final imageData = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(imageData);

    if (decodedImage == null) {
      throw Exception('Failed to decode image');
    }

    // Convert to grayscale if not already
    final grayscaleImage = img.grayscale(decodedImage);

    // Resize to 224x224 for input to the model
    final resizedImage = img.copyResize(grayscaleImage, width: 224, height: 224);

    // Extract the L channel and prepare input tensor
    final inputTensor = _prepareInputTensor(resizedImage);

    // Prepare output tensor
    final outputTensor = _createOutputTensor();

    // Run inference
    _interpreter!.run(inputTensor, outputTensor);

    // Process the output and create colorized image
    final colorizedImage = _processOutput(outputTensor, grayscaleImage);

    // Save the output image
    final outputPath = await _saveImage(colorizedImage);

    return outputPath;
  }

  List<List<List<List<double>>>> _prepareInputTensor(img.Image image) {
    // Create a 4D tensor [1, 224, 224, 1]
    final inputTensor = List.generate(
      1,
          (_) => List.generate(
        224,
            (y) => List.generate(
          224,
              (x) => [image.getPixel(x, y).r / 255.0],
        ),
      ),
    );

    return inputTensor;
  }

  List<List<List<List<double>>>> _createOutputTensor() {
    // Create output tensor of shape [1, 56, 56, 2] for a,b channels
    return List.generate(
      1,
          (_) => List.generate(
        896,
            (_) => List.generate(
          896,
              (_) => List.generate(2, (_) => 0.0),
        ),
      ),
    );
  }

  img.Image _processOutput(
      List<List<List<List<double>>>> outputTensor,
      img.Image originalImage,
      ) {
    // Here we'd need to implement the LAB color space conversion and apply the predicted a,b channels
    // This is a simplified version - real implementation would need proper LAB<->RGB conversion

    // Create a new image with the same dimensions as the original
    final outputImage = img.Image(
      width: originalImage.width,
      height: originalImage.height,
    );

    // For demonstration, we'll just apply some color tint to the grayscale image
    // In a real implementation, you'd need to:
    // 1. Resize the output a,b channels to match the original image
    // 2. Combine with the L channel from the original image
    // 3. Convert from LAB to RGB

    // Fake colorization for demo purposes
    for (int y = 0; y < originalImage.height; y++) {
      for (int x = 0; x < originalImage.width; x++) {
        final grayValue = originalImage.getPixel(x, y).r;

        // Apply a sepia-like tint
        final r = grayValue;
        final g = (grayValue * 0.85).round();
        final b = (grayValue * 0.7).round();

        outputImage.setPixelRgb(x, y, r, g, b);
      }
    }

    return outputImage;
  }

  Future<String> _saveImage(img.Image image) async {
    final directory = await getTemporaryDirectory();
    final filename = 'colorized_${DateTime.now().millisecondsSinceEpoch}.png';
    final filePath = join(directory.path, filename);

    final file = File(filePath);
    await file.writeAsBytes(img.encodePng(image));

    return filePath;
  }

  void dispose() {
    _interpreter?.close();
  }
}