import 'package:flutter/material.dart';

class InfoCardRow extends StatelessWidget {
  final String fileName;
  final String mainFolderName;
  final int imagesCount;
  final bool hasAudio;
  final bool hasTemplate;
  final String audioFileName;
  const InfoCardRow({
    super.key,
    required this.fileName,
    required this.mainFolderName,
    required this.imagesCount,
    required this.hasAudio,
    required this.hasTemplate,
    required this.audioFileName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoCard('File Name', fileName)),
            const SizedBox(width: 12),
            Expanded(child: _buildInfoCard('Main Folder', mainFolderName)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildInfoCard('Images Found', imagesCount.toString())),
            const SizedBox(width: 12),
            Expanded(child: _buildInfoCard('Audio', hasAudio ? 'Found' : 'Not Found')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildInfoCard('Template', hasTemplate ? 'Found' : 'Not Found')),
            const SizedBox(width: 12),
            Expanded(child: _buildInfoCard('Audio File', audioFileName)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value) {
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
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
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

