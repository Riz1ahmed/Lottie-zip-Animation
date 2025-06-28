import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../services/lottie_zip_service.dart';
import '../models/lottie_zip_model.dart';
import 'widgets/upload_section.dart';
import 'widgets/loading_section.dart';
import 'widgets/error_section.dart';
import 'widgets/file_info_section.dart';
import 'widgets/animation_section.dart';

class LottieZipScreen extends StatefulWidget {
  const LottieZipScreen({super.key});

  @override
  State<LottieZipScreen> createState() => _LottieZipScreenState();
}

class _LottieZipScreenState extends State<LottieZipScreen>
    with TickerProviderStateMixin {

  // Animation controller
  AnimationController? _lottieController;

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Service class for ZIP processing
  final LottieZipService _zipService = LottieZipService();

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieController?.dispose();
    _audioPlayer.dispose();
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
        final model = Provider.of<LottieZipModel>(context, listen: false);
        model.setLoading(true);
        model.reset();

        await _processZipFile(
          result.files.single.bytes!,
          result.files.single.name,
        );
      }
    } catch (e) {
      final model = Provider.of<LottieZipModel>(context, listen: false);
      model.setError('Error picking file: $e');
      model.setLoading(false);
    }
  }

  // Process the ZIP file (delegated to service)
  Future<void> _processZipFile(Uint8List zipBytes, String fileName) async {
    try {
      final model = Provider.of<LottieZipModel>(context, listen: false);
      final result = await _zipService.processZipFile(zipBytes, fileName);

      model.setZipData(
        animationData: result.animationData,
        templateData: result.templateData,
        extractedImages: result.images,
        extractedAudio: result.audioData,
        audioFileName: result.audioFileName,
        zipFileName: result.zipFileName,
        mainFolderName: result.mainFolderName,
      );
      model.setLoading(false);

      if (result.animationData != null) {
        _lottieController?.reset();
      }

      if (result.audioData != null) {
        await _zipService.setupAudio(_audioPlayer, result.audioData!);
      }
    } catch (e) {
      final model = Provider.of<LottieZipModel>(context, listen: false);
      model.setError('Error processing ZIP: $e');
      model.setLoading(false);
    }
  }

  // Animation controls
  void _controlAnimation(String action) {
    if (_lottieController == null) return;
    final model = Provider.of<LottieZipModel>(context, listen: false);

    switch (action) {
      case 'play':
        _lottieController!.forward();
        // Play audio if available
        if (model.extractedAudio != null && !kIsWeb) {
          _audioPlayer.play();
        }
        break;
      case 'pause':
        _lottieController!.stop();
        _audioPlayer.pause();
        break;
      case 'stop':
        _lottieController!.reset();
        _audioPlayer.stop();
        break;
      case 'restart':
        _lottieController!.reset();
        _lottieController!.forward();
        // Restart audio if available
        if (model.extractedAudio != null && !kIsWeb) {
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.play();
        }
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
        child: Consumer<LottieZipModel>(
          builder: (context, model, child) {
            return Column(
              children: [
                // Upload Section
                UploadSection(onTap: _pickZipFile),
                const SizedBox(height: 20),

                // Loading and Error indicators
                if (model.isLoading) const LoadingSection(),
                if (model.error != null) ErrorSection(error: model.error!),

                // File Info Section
                if (model.zipFileName != null) FileInfoSection(
                  audioPlayer: _audioPlayer,
                ),

                // Animation Preview Section
                if (model.animationData != null) AnimationSection(
                  controller: _lottieController!,
                  onControlAction: _controlAnimation,
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}
