import 'dart:typed_data';

import 'package:flutter/material.dart';

class DebugAssetsWidget extends StatelessWidget {
  final List<String> assetNames;
  final Map<String, Uint8List>? images;

  const DebugAssetsWidget({
    super.key,
    required this.assetNames,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Row(
          children: [
            Icon(Icons.bug_report, color: Colors.purple, size: 20),
            SizedBox(width: 8),
            Text(
              'Debug: Expected Assets',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...assetNames.map(
          (assetName) => ImageNames(
            assetName: assetName,
            isFound:
                images?.containsKey(assetName) == true ||
                images?.keys.any(
                      (key) => key.contains(assetName.split('.').first),
                    ) ==
                    true,
          ),
        ),
      ],
    );
  }
}

class ImageNames extends StatelessWidget {
  const ImageNames({super.key, required this.assetName, required this.isFound});

  final String assetName;
  final bool isFound;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isFound
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isFound
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isFound ? Icons.check_circle : Icons.error,
            size: 16,
            color: isFound ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Expected: $assetName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isFound ? Colors.green[700] : Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
