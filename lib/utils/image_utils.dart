import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:image/image.dart' as img;
import 'package:share_plus/share_plus.dart';

class ImageUtils {
  static Future<File?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  static Future<File> saveImageToAppDirectory(File image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final filename = basename(image.path);
    final savedImage = await image.copy('${appDir.path}/$filename');
    return savedImage;
  }

  static Future<void> shareImage(String imagePath) async {
    try {
      await Share.shareXFiles([XFile(imagePath)], text: 'Colorized image from B&W to Color App');
    } catch (e) {
      print('Error sharing image: $e');
    }
  }

  static Future<String> saveImageToDownloads(String imagePath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filename = 'colorized_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final targetPath = '${tempDir.path}/$filename';

      // Copy the file to a shareable location
      await File(imagePath).copy(targetPath);

      return targetPath;
    } catch (e) {
      print('Error saving image: $e');
      return imagePath;
    }
  }

  static Future<File> convertToGrayscale(File imageFile) async {
    try {
      // Read the file
      final bytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      // Convert to grayscale using the image package
      final grayscaleImage = img.grayscale(originalImage);

      // Save the processed image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/grayscale_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final outputFile = File(outputPath);

      // Write the grayscale image to file
      await outputFile.writeAsBytes(img.encodeJpg(grayscaleImage));

      return outputFile;
    } catch (e) {
      print('Error converting to grayscale: $e');
      return imageFile; // Return original if conversion fails
    }
  }
}