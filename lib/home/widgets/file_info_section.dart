import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../../models/lottie_zip_model.dart';
import 'info_card_row.dart';
import 'images_preview.dart';
import 'audio_preview_widget.dart';
import 'debug_assets_widget.dart';

class FileInfoSection extends StatelessWidget {
  final AudioPlayer audioPlayer;

  const FileInfoSection({
    super.key,
    required this.audioPlayer,
  });

  @override
  Widget build(BuildContext context) {
    // Access the model through Provider
    final model = Provider.of<LottieZipModel>(context);

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
          InfoCardRow(
            fileName: model.zipFileName!,
            mainFolderName: model.mainFolderName!,
            imagesCount: model.extractedImages?.length ?? 0,
            hasAudio: model.extractedAudio != null,
            hasTemplate: model.templateData != null,
            audioFileName: model.audioFileName ?? 'None',
          ),

          // Images Preview
          if (model.extractedImages != null && model.extractedImages!.isNotEmpty)
            ImagesPreview(images: model.extractedImages!),

          // Audio Preview
          if (model.extractedAudio != null)
            Column(
              children: [
                const SizedBox(height: 20),
                AudioPreviewWidget(
                  audioData: model.extractedAudio!,
                  audioFileName: model.audioFileName,
                  audioPlayer: audioPlayer,
                ),
              ],
            ),

          // Debug: Show expected vs found assets
          if (model.animationData != null && model.animationData!['assets'] != null)
            DebugAssetsWidget(
              assets: model.animationData!['assets'] as List,
              extractedImages: model.extractedImages,
            ),
        ],
      ),
    );
  }
}
