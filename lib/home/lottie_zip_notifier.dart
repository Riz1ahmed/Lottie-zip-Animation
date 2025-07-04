import 'package:flutter/foundation.dart';
import 'package:flutter/animation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie_zip_animation/home/lottie_animation_service.dart';
import 'util.dart';
import 'animation_action.dart';

class LottieZipNotifier with ChangeNotifier {
  bool isLoading = false;
  String? error;
  Map<String, dynamic>? animationData;
  Map<String, dynamic>? templateData;
  Map<String, Uint8List>? extractedImages;
  Uint8List? extractedAudio;
  String? audioFileName;
  String? zipFileName;
  String? mainFolderName;

  final AudioPlayer audioPlayer = AudioPlayer();
  AnimationController? animationController;

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

  void setAnimationController(AnimationController controller) {
    animationController = controller;
  }

  Future<void> pickZipFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        await _processZipFile(
          result.files.single.bytes!,
          result.files.single.name,
        );
      }
    } catch (e) {
      setError('Error picking file: $e');
    }
  }

  Future<void> _processZipFile(Uint8List zipFile, String fileName) async {
    setLoading(true);

    try {
      reset(); // Reset previous data if exists
      final lottieZip = await LottieZipHelper.processZipFile(zipFile, fileName);

      setZipData(
        animationData: lottieZip.animDataJson,
        templateData: lottieZip.templateJson,
        extractedImages: lottieZip.images,
        extractedAudio: lottieZip.audioData,
        audioFileName: lottieZip.audioFileName,
        zipFileName: lottieZip.zipFileName,
        mainFolderName: lottieZip.mainFolderName,
      );

      if (lottieZip.animDataJson != null) {
        animationController?.reset();
      }

      if (lottieZip.audioData != null) {
        await audioPlayer.setBytes(lottieZip.audioData!);
      }
    } catch (e) {
      setError('Error processing ZIP: $e');
    } finally {
      setLoading(false);
    }
  }

  void controlAnimation(PreviewAction action) {
    if (animationController == null) return;

    switch (action) {
      case PreviewAction.play:
        animationController!.forward();
        if (extractedAudio != null && !kIsWeb) {
          audioPlayer.play();
        }
        break;
      case PreviewAction.pause:
        animationController!.stop();
        audioPlayer.pause();
        break;
      case PreviewAction.stop:
        animationController!.reset();
        audioPlayer.stop();
        break;
      case PreviewAction.restart:
        animationController!.reset();
        animationController!.forward();
        if (extractedAudio != null && !kIsWeb) {
          audioPlayer.seek(Duration.zero);
          audioPlayer.play();
        }
        break;
    }
  }

  replaceImagesInAnimationData() =>
      LottieZipHelper.replaceImagesInAnimationData(
        animationData!,
        extractedImages,
      );

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
