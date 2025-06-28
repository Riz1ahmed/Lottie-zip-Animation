import 'package:flutter/foundation.dart';

class LottieZipModel with ChangeNotifier {
  bool isLoading = false;
  String? error;
  Map<String, dynamic>? animationData;
  Map<String, dynamic>? templateData;
  Map<String, Uint8List>? extractedImages;
  Uint8List? extractedAudio;
  String? audioFileName;
  String? zipFileName;
  String? mainFolderName;

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  void setError(String? errorMsg) {
    error = errorMsg;
    notifyListeners();
  }

  void setZipData({
    required Map<String, dynamic>? animationData,
    required Map<String, dynamic>? templateData,
    required Map<String, Uint8List>? extractedImages,
    required Uint8List? extractedAudio,
    required String? audioFileName,
    required String? zipFileName,
    required String? mainFolderName,
  }) {
    this.animationData = animationData;
    this.templateData = templateData;
    this.extractedImages = extractedImages;
    this.extractedAudio = extractedAudio;
    this.audioFileName = audioFileName;
    this.zipFileName = zipFileName;
    this.mainFolderName = mainFolderName;
    notifyListeners();
  }

  void reset() {
    animationData = null;
    templateData = null;
    extractedImages = null;
    extractedAudio = null;
    audioFileName = null;
    zipFileName = null;
    mainFolderName = null;
    error = null;
    notifyListeners();
  }
}
