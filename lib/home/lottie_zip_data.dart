import 'dart:typed_data';

class LottieZipData {
  final Map<String, dynamic>? animDataJson;
  final Map<String, dynamic>? templateJson;
  final Map<String, Uint8List>? images;
  final Uint8List? audioData;
  final String? audioFileName;
  final String? zipFileName;
  final String? mainFolderName;

  LottieZipData({
    this.animDataJson,
    this.templateJson,
    this.images,
    this.audioData,
    this.audioFileName,
    this.zipFileName,
    this.mainFolderName,
  });
}
