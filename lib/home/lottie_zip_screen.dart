import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'util.dart';
import 'lottie_zip_notifier.dart';
import 'widgets/upload_section.dart';
import 'widgets/loading_section.dart';
import 'widgets/error_section.dart';
import 'widgets/file_info_section.dart';
import 'widgets/animation_section.dart';

class LottieZipViewerScreen extends StatefulWidget {
  const LottieZipViewerScreen({super.key});

  @override
  State<LottieZipViewerScreen> createState() => _LottieZipViewerScreenState();
}

class _LottieZipViewerScreenState extends State<LottieZipViewerScreen>
    with TickerProviderStateMixin {
  // Animation controller
  AnimationController? _lottieController;

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Service class for ZIP processing
  //final LottieZipHelper _zipService = LottieZipHelper();

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
        final notifier = Provider.of<LottieZipNotifier>(context, listen: false);
        notifier.setLoading(true);

        notifier.reset();
        await _processZipFile(
          result.files.single.bytes!,
          result.files.single.name,
        );
      }
    } catch (e) {
      final notifier = Provider.of<LottieZipNotifier>(context, listen: false);
      notifier.setError('Error picking file: $e');
      notifier.setLoading(false);
    }
  }

  // Process the ZIP file (delegated to service)
  Future<void> _processZipFile(Uint8List zipFile, String fileName) async {
    try {
      final notifier = Provider.of<LottieZipNotifier>(context, listen: false);
      final lottieZip = await LottieZipHelper.processZipFile(zipFile, fileName);

      notifier.setZipData(
        animationData: lottieZip.animationData,
        templateData: lottieZip.templateData,
        extractedImages: lottieZip.images,
        extractedAudio: lottieZip.audioData,
        audioFileName: lottieZip.audioFileName,
        zipFileName: lottieZip.zipFileName,
        mainFolderName: lottieZip.mainFolderName,
      );
      notifier.setLoading(false);

      if (lottieZip.animationData != null) {
        _lottieController?.reset();
      }

      if (lottieZip.audioData != null) {
        await _audioPlayer.setBytes(lottieZip.audioData!);
      }
    } catch (e) {
      final model = Provider.of<LottieZipNotifier>(context, listen: false);
      model.setError('Error processing ZIP: $e');
      model.setLoading(false);
    }
  }

  // Animation controls
  void _controlAnimation(String action) {
    if (_lottieController == null) return;
    final notifier = Provider.of<LottieZipNotifier>(context, listen: false);

    switch (action) {
      case 'play':
        _lottieController!.forward();
        // Play audio if available
        if (notifier.extractedAudio != null && !kIsWeb) {
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
        if (notifier.extractedAudio != null && !kIsWeb) {
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
        child: Consumer<LottieZipNotifier>(
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
                if (model.zipFileName != null)
                  FileInfoSection(audioPlayer: _audioPlayer),

                // Animation Preview Section
                if (model.animationData != null)
                  AnimationSection(
                    controller: _lottieController!,
                    onControlAction: _controlAnimation,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
