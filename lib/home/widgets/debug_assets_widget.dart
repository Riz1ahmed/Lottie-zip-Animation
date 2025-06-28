import 'dart:typed_data';

import 'package:flutter/material.dart';

class DebugAssetsWidget extends StatelessWidget {
  final List assets;
  final Map<String, Uint8List>? extractedImages;

  const DebugAssetsWidget({
    super.key,
    required this.assets,
    required this.extractedImages,
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
        ...assets.where((asset) => asset['p'] != null).map((asset) {
          final assetName = asset['p'] as String;
          final found = extractedImages?.containsKey(assetName) == true ||
              extractedImages?.keys.any(
                  (key) => key.contains(assetName.split('.').first)) ==
                  true;

          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: found ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: found ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  found ? Icons.check_circle : Icons.error,
                  size: 16,
                  color: found ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Expected: $assetName',
                    style: TextStyle(
                      fontSize: 12,
                      color: found ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
