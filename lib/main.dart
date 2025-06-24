// pubspec.yaml for the demo project
/*
name: lottie_zip_demo
description: A simple demo app to test Lottie ZIP file upload and preview

version: 1.0.0+1

environment:
  sdk: '>=2.19.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  lottie: ^2.7.0
  file_picker: ^6.1.1
  archive: ^3.4.9
  path_provider: ^2.1.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
*/

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const LottieZipDemoApp());
}

class LottieZipDemoApp extends StatelessWidget {
  const LottieZipDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lottie ZIP Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LottieZipScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LottieZipScreen extends StatefulWidget {
  const LottieZipScreen({Key? key}) : super(key: key);

  @override
  State<LottieZipScreen> createState() => _LottieZipScreenState();
}

class _LottieZipScreenState extends State<LottieZipScreen>
    with TickerProviderStateMixin {

  // State variables
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _animationData;
  Map<String, dynamic>? _templateData;
  Map<String, Uint8List>? _extractedImages; // Changed for web compatibility
  String? _zipFileName;
  String? _mainFolderName;

  // Animation controller
  AnimationController? _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieController?.dispose();
    super.dispose();
  }

  // Pick and process ZIP file
  Future<void> _pickZipFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _isLoading = true;
          _error = null;
          _animationData = null;
          _templateData = null;
          _extractedImages = null;
        });

        await _processZipFile(
          result.files.single.bytes!,
          result.files.single.name,
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Error picking file: $e';
        _isLoading = false;
      });
    }
  }

  // Process the ZIP file
  Future<void> _processZipFile(Uint8List zipBytes, String fileName) async {
    try {
      print('Processing ZIP file: $fileName');

      // Extract ZIP
      final archive = ZipDecoder().decodeBytes(zipBytes);
      print('ZIP extracted, ${archive.length} files found');

      // Find main folder (Frame16 or similar)
      String? mainFolder;
      for (final file in archive) {
        if (file.isFile) continue;
        final pathParts = file.name.split('/');
        if (pathParts.length == 2 && pathParts[1].isEmpty) {
          mainFolder = pathParts[0];
          break;
        }
      }

      if (mainFolder == null) {
        throw Exception('No valid animation folder found in ZIP');
      }

      print('Main folder found: $mainFolder');

      Map<String, Uint8List> images = {};
      Map<String, dynamic>? animationData;
      Map<String, dynamic>? templateData;

      // Extract files directly from ZIP (no temporary files for web)
      for (final file in archive) {
        if (!file.isFile) continue;

        print('Processing file: ${file.name}');

        // Check file type
        if (file.name.endsWith('data.json') && file.name.contains(mainFolder)) {
          print('Found data.json');
          final content = String.fromCharCodes(file.content);
          animationData = json.decode(content);

          // Debug: Print asset information
          if (animationData?['assets'] != null) {
            print('Animation assets found:');
            for (var asset in animationData!['assets']) {
              if (asset['p'] != null) {
                print('  - Asset: ${asset['p']} (id: ${asset['id']})');
              }
            }
          }

        } else if (file.name.endsWith('template.json') && file.name.contains(mainFolder)) {
          print('Found template.json');
          final content = String.fromCharCodes(file.content);
          templateData = json.decode(content);
        } else if (file.name.contains('images/')) {
          // More flexible image detection
          final fileName = file.name.split('/').last;
          final extension = fileName.toLowerCase().split('.').last;

          if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
            images[fileName] = Uint8List.fromList(file.content);
            print('Found image: $fileName (size: ${file.content.length} bytes)');
          }
        }
      }

      print('Processing complete:');
      print('- Animation data: ${animationData != null ? 'Found' : 'Not found'}');
      print('- Template data: ${templateData != null ? 'Found' : 'Not found'}');
      print('- Images: ${images.length} found');

      // Update state
      setState(() {
        _animationData = animationData;
        _templateData = templateData;
        _extractedImages = images;
        _zipFileName = fileName;
        _mainFolderName = mainFolder;
        _isLoading = false;
      });

      // Initialize animation
      if (animationData != null) {
        _initializeAnimation();
      }

    } catch (e) {
      print('Error processing ZIP: $e');
      setState(() {
        _error = 'Error processing ZIP: $e';
        _isLoading = false;
      });
    }
  }

  // Initialize Lottie animation
  void _initializeAnimation() {
    if (_animationData != null && _lottieController != null) {
      _lottieController!.reset();
    }
  }

  // Animation controls
  void _controlAnimation(String action) {
    if (_lottieController == null) return;

    switch (action) {
      case 'play':
        _lottieController!.forward();
        break;
      case 'pause':
        _lottieController!.stop();
        break;
      case 'stop':
        _lottieController!.reset();
        break;
      case 'restart':
        _lottieController!.reset();
        _lottieController!.forward();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Lottie ZIP Demo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Upload Section
            _buildUploadSection(),

            const SizedBox(height: 20),

            if (_isLoading) _buildLoadingSection(),

            if (_error != null) _buildErrorSection(),

            // File Info Section
            if (_zipFileName != null) _buildFileInfoSection(),

            // Animation Preview Section
            if (_animationData != null) _buildAnimationSection(),
          ],
        ),
      ),
    );
  }

  // Upload Section Widget
  Widget _buildUploadSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _pickZipFile,
          child: Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.archive,
                    size: 60,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Upload Lottie ZIP File',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to select Lottie/BodyMovin zip file containing Frame16 folder with animation data',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    'Choose ZIP File',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Loading Section Widget
  Widget _buildLoadingSection() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            'Processing ZIP file...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // Error Section Widget
  Widget _buildErrorSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // File Info Section Widget
  Widget _buildFileInfoSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.folder, color: Colors.amber, size: 24),
              SizedBox(width: 8),
              Text(
                'ZIP File Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Info Cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard('File Name', _zipFileName!),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard('Main Folder', _mainFolderName!),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard('Images Found',
                    _extractedImages?.length.toString() ?? '0'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard('Template',
                    _templateData != null ? 'Found' : 'Not Found'),
              ),
            ],
          ),

          // Images Preview
          if (_extractedImages != null && _extractedImages!.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Row(
              children: [
                Icon(Icons.image, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Extracted Images',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _extractedImages!.length,
                itemBuilder: (context, index) {
                  final entry = _extractedImages!.entries.elementAt(index);
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            entry.value,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 60,
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],

          // Debug: Show expected vs found assets
          if (_animationData != null && _animationData!['assets'] != null) ...[
            const SizedBox(height: 20),
            const Row(
              children: [
                Icon(Icons.bug_report, color: Colors.purple, size: 20),
                SizedBox(width: 8),
                Text(
                  'Debug: Expected Assets',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...(_animationData!['assets'] as List).where((asset) => asset['p'] != null).map((asset) {
              final assetName = asset['p'] as String;
              final found = _extractedImages?.containsKey(assetName) == true ||
                  _extractedImages?.keys.any((key) => key.contains(assetName.split('.').first)) == true;

              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: found ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: found ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      found ? Icons.check_circle : Icons.error,
                      size: 16,
                      color: found ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Expected: $assetName',
                        style: TextStyle(
                          fontSize: 12,
                          color: found ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  // Info Card Widget
  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Animation Section Widget
  Widget _buildAnimationSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.play_circle_fill, color: Colors.green, size: 24),
              SizedBox(width: 8),
              Text(
                'Animation Preview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Animation Container
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildLottieAnimation(),
            ),
          ),

          const SizedBox(height: 16),

          // Animation Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.play_arrow,
                label: 'Play',
                onTap: () => _controlAnimation('play'),
                color: Colors.green,
              ),
              _buildControlButton(
                icon: Icons.pause,
                label: 'Pause',
                onTap: () => _controlAnimation('pause'),
                color: Colors.orange,
              ),
              _buildControlButton(
                icon: Icons.stop,
                label: 'Stop',
                onTap: () => _controlAnimation('stop'),
                color: Colors.red,
              ),
              _buildControlButton(
                icon: Icons.refresh,
                label: 'Restart',
                onTap: () => _controlAnimation('restart'),
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build Lottie Animation Widget
  Widget _buildLottieAnimation() {
    if (_animationData == null) {
      return const Center(
        child: Text(
          'No animation data available',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    try {
      // Create modified animation data with image replacements
      final modifiedAnimationData = _replaceImagesInAnimationData();

      return Lottie.memory(
        Uint8List.fromList(utf8.encode(json.encode(modifiedAnimationData))),
        controller: _lottieController,
        onLoaded: (composition) {
          _lottieController?.duration = composition.duration;
          _lottieController?.forward();
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
  Map<String, dynamic> _replaceImagesInAnimationData() {
    final modifiedData = Map<String, dynamic>.from(_animationData!);

    if (modifiedData['assets'] != null && _extractedImages != null) {
      final assets = modifiedData['assets'] as List;

      for (var asset in assets) {
        if (asset is Map<String, dynamic> && asset['p'] != null) {
          final imageName = asset['p'] as String;
          print('Processing asset: $imageName');

          // Find matching image data
          Uint8List? imageData;
          for (var entry in _extractedImages!.entries) {
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

              print('Replaced $imageName with data URL (${imageData.length} bytes)');
            } catch (e) {
              print('Error converting $imageName to base64: $e');
            }
          } else {
            print('Image data not found for: $imageName');
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

  // Control Button Widget
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}