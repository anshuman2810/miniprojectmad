import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:miniproject/services/database_service.dart';
import 'package:miniproject/models/colorized_image.dart';
import 'package:miniproject/utils/image_utils.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ColorizedImage> _images = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final images = await Provider.of<DatabaseService>(context, listen: false).getColorizedImages();
      setState(() {
        _images = images;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading history: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _shareImage(String imagePath) async {
    try {
      await ImageUtils.shareImage(imagePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing image: $e')),
      );
    }
  }

  Future<void> _deleteImage(int id) async {
    try {
      await Provider.of<DatabaseService>(context, listen: false).deleteColorizedImage(id);
      _loadImages(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _images.isEmpty
          ? const Center(child: Text('No images in history'))
          : ListView.builder(
        itemCount: _images.length,
        itemBuilder: (context, index) {
          final image = _images[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Created on ${DateFormat('MMM d, yyyy hh:mm a').format(image.createdAt)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.file(
                            File(image.originalPath),
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.file(
                            File(image.colorizedPath),
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      onPressed: () => _shareImage(image.colorizedPath),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                      onPressed: () => _deleteImage(image.id!),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}