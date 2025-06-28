import 'dart:typed_data';

class LottieZipData {
  final Map<String, dynamic>? animationData;
  final Map<String, dynamic>? templateData;
  final Map<String, Uint8List>? images;
  final Uint8List? audioData;
  final String? audioFileName;
  final String? zipFileName;
  final String? mainFolderName;

  LottieZipData({
    this.animationData,
    this.templateData,
    this.images,
    this.audioData,
    this.audioFileName,
    this.zipFileName,
    this.mainFolderName,
  });
}