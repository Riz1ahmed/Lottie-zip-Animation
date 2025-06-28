import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../models/lottie_zip_model.dart';

class LottiePreviewWidget extends StatelessWidget {
  final AnimationController controller;

  const LottiePreviewWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<LottieZipModel>(context);
    if (model.animationData == null) {
      return const Center(
        child: Text(
          'No animation data available',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    try {
      final modifiedAnimationData = _replaceImagesInAnimationData(
        model.animationData!,
        model.extractedImages
      );

      return Lottie.memory(
        Uint8List.fromList(utf8.encode(json.encode(modifiedAnimationData))),
        controller: controller,
        onLoaded: (composition) {
          controller.duration = composition.duration;
          controller.forward();
        },
        fit: BoxFit.contain,
        repeat: true,
        errorBuilder: (context, error, stackTrace) {
          print('Lottie error: $error');
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 8),
                Text(
                  'Error loading animation',
                  style: TextStyle(fontSize: 14, color: Colors.red),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print('Animation build error: $e');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(
              'Animation format error: $e',
              style: const TextStyle(fontSize: 12, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  // Replace image references in animation data with base64 encoded images
  Map<String, dynamic> _replaceImagesInAnimationData(
    Map<String, dynamic> animationData,
    Map<String, Uint8List>? extractedImages
  ) {
    final modifiedData = Map<String, dynamic>.from(animationData);

    if (modifiedData['assets'] != null && extractedImages != null) {
      final assets = modifiedData['assets'] as List;

      for (var asset in assets) {
        if (asset is Map<String, dynamic> && asset['p'] != null) {
          final imageName = asset['p'] as String;

          // Find matching image data
          Uint8List? imageData;
          for (var entry in extractedImages.entries) {
            if (entry.key == imageName || entry.key.contains(imageName)) {
              imageData = entry.value;
              break;
            }
          }

          if (imageData != null) {
            try {
              // Convert image to base64 data URL
              final base64Image = base64Encode(imageData);
              final mimeType = _getMimeType(imageName);
              final dataUrl = 'data:$mimeType;base64,$base64Image';

              // Replace the image path with data URL
              asset['p'] = dataUrl;
              asset['u'] = ''; // Clear the base URL
              asset['e'] = 1; // Mark as embedded
            } catch (e) {
              print('Error converting $imageName to base64: $e');
            }
          }
        }
      }
    }
    return modifiedData;
  }

  // Get MIME type based on file extension
  String _getMimeType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
