import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/animation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie_zip_animation/home/lottie_zip_data.dart';
import 'util.dart';
import 'preview_action.dart';

class LottieZipNotifier with ChangeNotifier {
  LottieZipData? lottieZip;

  bool isLoading = false;
  String? error;

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

  void _setZipData(LottieZipData lottieZip) {
    this.lottieZip = lottieZip;
    notifyListeners();
  }

  void reset() {
    lottieZip = null;
    audioPlayer.stop();
    animationController?.reset();
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

      _setZipData(lottieZip);

      if (lottieZip.lottieJson != null) {
        animationController?.reset();
      }

      if (lottieZip.audioData != null) {
        try {
          await audioPlayer.setUrl('data:audio/mp3;base64,${base64Encode(lottieZip.audioData!)}');
        } catch (e) {
          print('Audio error: $e');
        }
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
        if (lottieZip?.audioData != null) {
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
        if (lottieZip?.audioData != null) {
          audioPlayer.seek(Duration.zero);
          audioPlayer.play();
        }
        break;
    }
  }

  Map<String, dynamic> getImageEncodedJson() {
    try {
      return LottieZipHelper.getImageEncodedJson(
        lottieZip!.lottieJson!,
        lottieZip!.images!,
      );
    } on Exception catch (e) {
      setError('Error replacing images: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  List<String> getAssetNames() => (lottieZip!.lottieJson!['assets'] as List)
      .where((asset) => asset['p'] != null)
      .map((e) => e['p'] as String)
      .toList();
}
