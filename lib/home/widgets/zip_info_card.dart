import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../lottie_zip_notifier.dart';
import 'info_card_row.dart';
import 'images_preview.dart';
import 'audio_preview_widget.dart';
import 'debug_assets_widget.dart';

class ZipInfoCard extends StatelessWidget {
  const ZipInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<LottieZipNotifier>(context);

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
            fileName: notifier.zipFileName!,
            mainFolderName: notifier.mainFolderName!,
            imagesCount: notifier.extractedImages?.length ?? 0,
            hasAudio: notifier.extractedAudio != null,
            hasTemplate: notifier.templateData != null,
            audioFileName: notifier.audioFileName ?? 'None',
          ),

          // Images Preview
          if (notifier.extractedImages != null &&
              notifier.extractedImages!.isNotEmpty)
            ImagesPreview(images: notifier.extractedImages!),

          // Audio Preview
          if (notifier.extractedAudio != null)
            Column(
              children: [
                const SizedBox(height: 20),
                AudioPreviewWidget(
                  audioData: notifier.extractedAudio!,
                  audioFileName: notifier.audioFileName,
                  audioPlayer: notifier.audioPlayer,
                ),
              ],
            ),

          // Debug: Show expected vs found assets
          if (notifier.animationData != null &&
              notifier.animationData!['assets'] != null)
            DebugAssetsWidget(
              assets: notifier.animationData!['assets'] as List,
              extractedImages: notifier.extractedImages,
            ),
        ],
      ),
    );
  }
}
