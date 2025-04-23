import 'dart:io';
import 'package:flutter/material.dart';
import 'package:miniproject/services/database_service.dart';
import 'package:miniproject/utils/image_utils.dart';
import 'package:miniproject/models/colorized_image.dart';
import 'package:provider/provider.dart';

class ResultScreen extends StatefulWidget {
  final String originalImagePath;
  final String colorizedImagePath;

  const ResultScreen({
    Key? key,
    required this.originalImagePath,
    required this.colorizedImagePath,
  }) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSaving = false;
  bool _isShared = false;
  bool _isSavedToHistory = false;

  @override
  void initState() {
    super.initState();
    _saveToHistory();
  }

  Future<void> _shareImage() async {
    if (_isShared) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // First save to downloads so we have a shareable path
      final sharePath = await ImageUtils.saveImageToDownloads(widget.colorizedImagePath);

      // Then share it
      await ImageUtils.shareImage(sharePath);

      setState(() {
        _isShared = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing image: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _saveToHistory() async {
    if (_isSavedToHistory) return;

    try {
      // Save images to app's permanent storage
      final savedOriginal = await ImageUtils.saveImageToAppDirectory(File(widget.originalImagePath));
      final savedColorized = await ImageUtils.saveImageToAppDirectory(File(widget.colorizedImagePath));

      // Create a new ColorizedImage object
      final colorizedImage = ColorizedImage(
        originalPath: savedOriginal.path,
        colorizedPath: savedColorized.path,
        createdAt: DateTime.now(),
      );

      // Save to database
      await Provider.of<DatabaseService>(context, listen: false)
          .insertColorizedImage(colorizedImage);

      setState(() {
        _isSavedToHistory = true;
      });
    } catch (e) {
      print('Error saving to history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colorized Result'),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Original Image:',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(widget.originalImagePath),
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Colorized Result:',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(widget.colorizedImagePath),
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _shareImage,
                icon: const Icon(Icons.share),
                label: const Text('Share Image'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}