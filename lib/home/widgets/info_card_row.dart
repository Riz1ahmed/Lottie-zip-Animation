import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../lottie_zip_notifier.dart';

class InfoCardRow extends StatelessWidget {
  const InfoCardRow({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<LottieZipNotifier>(context);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2,
      children: [
        ZipInfoCard(
          label: 'File Name',
          value: notifier.lottieZip?.zipFileName ?? 'None',
        ),
        ZipInfoCard(
          label: 'Main Folder',
          value: notifier.lottieZip?.mainFolderName ?? 'None',
        ),
        ZipInfoCard(
          label: 'Images Found',
          value: (notifier.lottieZip?.images?.length ?? 0).toString(),
        ),
        ZipInfoCard(
          label: 'Audio',
          value: notifier.lottieZip?.audioData != null ? 'Found' : 'Not Found',
        ),
        ZipInfoCard(
          label: 'Template',
          value: notifier.lottieZip?.templateJson != null
              ? 'Found'
              : 'Not Found',
        ),
        ZipInfoCard(
          label: 'Audio File',
          value: notifier.lottieZip?.audioFileName ?? 'None',
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withAlpha(51)), // 0.2 * 255 ≈ 51
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
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
