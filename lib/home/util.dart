import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:lottie_zip_animation/home/lottie_zip_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';

class LottieZipHelper {
  ///
  ///Extract the lottie contents from ZIP.
  ///Contents are:
  ///- data.json: The main animation data
  ///- template.json: Optional template data
  ///- images/: Folder containing all images used in the animation
  ///- audio files: Optional audio files used in the animation
  static Future<LottieZipData> processZipFile(
    Uint8List zipBytes,
    String fileName,
  ) async {
    try {
      print('Processing ZIP file: $fileName');
      final Archive archive = ZipDecoder().decodeBytes(zipBytes);
      print('ZIP extracted, ${archive.length} files found');

      String? mainFolder;
      Map<String, Uint8List> images = {};
      Map<String, dynamic>? animDataJson;
      Map<String, dynamic>? templateJson;
      Uint8List? audioData;
      String? audioFileName;

      // Check if we have files directly in the root of ZIP
      bool hasDataJsonInRoot = archive.files.any(
        (file) => file.isFile && file.name == 'data.json',
      );
      bool hasImagesInRoot = archive.files.any(
        (file) => file.isFile && file.name.startsWith('images/'),
      );

      // If both data.json and images/ are in root
      if (hasDataJsonInRoot && hasImagesInRoot) {
        print('Found Lottie files directly in ZIP root');
        mainFolder = '';
      }
      // If files are not in root, look for a folder containing them
      else {
        print('Looking for folder containing Lottie files...');
        for (final file in archive) {
          if (file.isFile) continue;

          // Get folder name
          final folderName = file.name.split('/')[0];

          // Check if this folder has data.json and images/
          bool hasFolderDataJson = archive.files.any(
            (f) => f.isFile && f.name == '$folderName/data.json',
          );
          bool hasFolderImages = archive.files.any(
            (f) => f.isFile && f.name.startsWith('$folderName/images/'),
          );

          if (hasFolderDataJson && hasFolderImages) {
            mainFolder = folderName;
            print('Found Lottie files in folder: $folderName');
            break;
          }
        }
      }

      // If we didn't find valid files anywhere
      if (mainFolder == null) {
        throw Exception('Could not find data.json and images/ folder in ZIP');
      }

      // Extract files
      for (final ArchiveFile file in archive) {
        if (!file.isFile) continue;
        String fileName = file.name;

        // If files are in a folder, strip the folder name for processing
        if (mainFolder.isNotEmpty && fileName.startsWith(mainFolder)) {
          fileName = fileName.substring(mainFolder.length + 1);
        }

        print('Processing file: $fileName');

        ///
        ///The animation data.json
        if (fileName == 'data.json') {
          print('Found data.json');
          final String content = String.fromCharCodes(file.content);
          animDataJson = json.decode(content);

          if (animDataJson?['assets'] != null) {
            print('Animation assets found:');
            for (var asset in animDataJson!['assets']) {
              if (asset['p'] != null) {
                print('  - Asset: ${asset['p']} (id: ${asset['id']})');
              }
            }
          }
        }
        ///
        ///Template data
        else if (fileName == 'template.json') {
          print('Found template.json');
          final content = String.fromCharCodes(file.content);
          templateJson = json.decode(content);
        }
        ///
        ///Images
        else if (fileName.startsWith('images/')) {
          final imageName = fileName.split('/').last;
          final extension = imageName.toLowerCase().split('.').last;

          if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
            images[imageName] = Uint8List.fromList(file.content);
            print(
              'Found image: $imageName (size: ${file.content.length} bytes)',
            );
          }
        }
        ///
        /// Audio files
        else {
          // Check for audio files
          final extension = fileName.toLowerCase().split('.').last;
          if (['mp3', 'wav', 'aac', 'm4a', 'ogg'].contains(extension)) {
            audioData = Uint8List.fromList(file.content);
            audioFileName = fileName.split('/').last;
            print(
              'Found audio: $audioFileName (size: ${file.content.length} bytes)',
            );
          }
        }
      }

      print('Processing complete:');
      print(
        '- Animation data: ${animDataJson != null ? 'Found' : 'Not found'}',
      );
      print('- Template data: ${templateJson != null ? 'Found' : 'Not found'}');
      print('- Images: ${images.length} found');
      print(
        '- Audio: ${audioData != null ? 'Found ($audioFileName)' : 'Not found'}',
      );

      return LottieZipData(
        lottieJson: animDataJson,
        templateJson: templateJson,
        images: images,
        audioData: audioData,
        audioFileName: audioFileName,
        zipFileName: fileName,
        mainFolderName: mainFolder,
      );
    } catch (e) {
      print('Error processing ZIP: $e');
      rethrow;
    }
  }

  /// Add the images to the Lottie JSON as base64 and return the json.
  static Map<String, dynamic> getImageEncodedJson(
    Map<String, dynamic> lottieJson,
    Map<String, Uint8List> images,
  ) {
    final modifiedJson = Map<String, dynamic>.from(lottieJson);

    if (modifiedJson['assets'] != null) {
      final assets = modifiedJson['assets'] as List;

      for (var asset in assets) {
        if (asset is Map<String, dynamic> && asset['p'] != null) {
          final imageName = asset['p'] as String;
          final imageData = images[imageName];

          if (imageData != null) {
            _encodeImageInAsset(asset, imageName, imageData);
          }
        }
      }
    }

    return modifiedJson;
  }

  /// Encode the image data to base64
  /// and replace the path in assetJson.
  static void _encodeImageInAsset(
    Map<String, dynamic> assetJson,
    String imageName,
    Uint8List imageData,
  ) {
    try {
      final base64Image = base64Encode(imageData);
      final mimeType = _getMimeType(imageName);

      assetJson['p'] = 'data:$mimeType;base64,$base64Image';
      assetJson['u'] = ''; // Clear the base URL
      assetJson['e'] = 1; // Mark as embedded
    } catch (e) {
      print('Error converting $imageName to base64: $e');
    }
  }

  static String _getMimeType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    return switch (extension) {
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'gif' => 'image/gif',
      'svg' => 'image/svg+xml',
      _ => 'image/png',
    };
  }
}

extension AudioPlayerExtension on AudioPlayer {
  ///Load audio into the AudioPlayer.
  Future<void> setBytes(Uint8List audioData) async {
    if (kIsWeb) return;

    final tempDir = await getTemporaryDirectory();
    final audioFile = File(
      '${tempDir.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.mp3',
    );
    await audioFile.writeAsBytes(audioData);
    await setFilePath(audioFile.path);
  }
}
