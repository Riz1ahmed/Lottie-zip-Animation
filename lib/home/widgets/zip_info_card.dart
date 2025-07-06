import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../lottie_zip_notifier.dart';
import 'info_card_row.dart';
import 'images_preview.dart';
import 'audio_preview_widget.dart';

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
            color: Colors.black.withAlpha(26),
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
          const InfoCardRow(),

          // Images Preview
          if (notifier.lottieZip?.images?.isNotEmpty ?? false) ImagesPreview(),

          // Audio Preview
          if (notifier.lottieZip?.audioData != null)
            Column(
              children: [
                const SizedBox(height: 20),
                AudioPreviewWidget(
                  audioData: notifier.lottieZip!.audioData!,
                  audioFileName: notifier.lottieZip!.audioFileName,
                  audioPlayer: notifier.audioPlayer,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
