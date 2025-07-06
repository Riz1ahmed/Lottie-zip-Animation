import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../lottie_zip_notifier.dart';

class InfoCardRow extends StatelessWidget {
  const InfoCardRow({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<LottieZipNotifier>(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ZipInfoCard(
                label: 'File Name',
                value: notifier.lottieZip?.zipFileName ?? 'None',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ZipInfoCard(
                label: 'Main Folder',
                value: notifier.lottieZip?.mainFolderName ?? 'None',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ZipInfoCard(
                label: 'Images Found',
                value: (notifier.lottieZip?.images?.length ?? 0).toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ZipInfoCard(
                value: 'Audio',
                label: notifier.lottieZip?.audioData != null
                    ? 'Found'
                    : 'Not Found',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ZipInfoCard(
                label: 'Template',
                value: notifier.lottieZip?.templateJson != null
                    ? 'Found'
                    : 'Not Found',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ZipInfoCard(
                label: 'Audio File',
                value: notifier.lottieZip?.audioFileName ?? 'None',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ZipInfoCard extends StatelessWidget {
  const ZipInfoCard({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
