import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPreviewWidget extends StatelessWidget {
  final Uint8List audioData;
  final String? audioFileName;
  final AudioPlayer audioPlayer;

  const AudioPreviewWidget({
    super.key,
    required this.audioData,
    required this.audioFileName,
    required this.audioPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(25), // 0.1 * 255 ≈ 25
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withAlpha(77)), // 0.3 * 255 ≈ 77
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(51), // 0.2 * 255 ≈ 51
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.audiotrack,
              color: Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Audio File Found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  audioFileName ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Size: ${(audioData.length / 1024).toStringAsFixed(1)} KB',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
          StreamBuilder<PlayerState>(
            stream: audioPlayer.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final isPlaying = playerState?.playing ?? false;

              return IconButton(
                onPressed: () {
                  if (isPlaying) {
                    audioPlayer.stop();
                  } else {
                    audioPlayer.seek(Duration.zero);
                    audioPlayer.play();
                  }
                },
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.green,
                  size: 28,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
