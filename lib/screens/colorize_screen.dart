import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miniproject/services/tflite_service.dart';
import 'package:miniproject/utils/image_utils.dart';
import 'package:miniproject/screens/result_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';

class ColorizeScreen extends StatefulWidget {
  const ColorizeScreen({Key? key}) : super(key: key);

  @override
  _ColorizeScreenState createState() => _ColorizeScreenState();
}

class _ColorizeScreenState extends State<ColorizeScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  final TfliteService _tfliteService = TfliteService();

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _tfliteService.loadModel();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load model: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final permissionStatus = await _requestPermission(source);
      if (!permissionStatus) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied')),
        );
        return;
      }

      final pickedImage = await ImageUtils.pickImage(source);
      if (pickedImage != null) {
        // If needed, convert to grayscale
        final grayscaleImage = await ImageUtils.convertToGrayscale(pickedImage);
        setState(() {
          _selectedImage = grayscaleImage;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<bool> _requestPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    } else {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final colorizedImagePath = await _tfliteService.colorizeImage(_selectedImage!.path);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            originalImagePath: _selectedImage!.path,
            colorizedImagePath: colorizedImagePath,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing image: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Image'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: Center(
              child: _selectedImage == null
                  ? const Text('No image selected')
                  : Image.file(
                _selectedImage!,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ],
            ),
          ),
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _processImage,
                child: const Text('Colorize'),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tfliteService.dispose();
    super.dispose();
  }
}