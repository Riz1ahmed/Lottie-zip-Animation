import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../lottie_zip_notifier.dart';
import 'control_button.dart';
import 'lottie_preview_widget.dart';

class AnimationSection extends StatelessWidget {
  final AnimationController controller;
  final Function(String) onControlAction;

  const AnimationSection({
    super.key,
    required this.controller,
    required this.onControlAction,
  });

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<LottieZipNotifier>(context);

    return Container(
      width: double.infinity,
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
              Icon(Icons.play_circle_fill, color: Colors.green, size: 24),
              SizedBox(width: 8),
              Text(
                'Animation Preview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Animation Container
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LottiePreviewWidget(
                controller: controller,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Animation Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ControlButton(
                icon: Icons.play_arrow,
                label: 'Play',
                onTap: () => onControlAction('play'),
                color: Colors.green,
              ),
              ControlButton(
                icon: Icons.pause,
                label: 'Pause',
                onTap: () => onControlAction('pause'),
                color: Colors.orange,
              ),
              ControlButton(
                icon: Icons.stop,
                label: 'Stop',
                onTap: () => onControlAction('stop'),
                color: Colors.red,
              ),
              ControlButton(
                icon: Icons.refresh,
                label: 'Restart',
                onTap: () => onControlAction('restart'),
                color: Colors.blue,
              ),
            ],
          ),

          // Audio Info
          if (model.extractedAudio != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.music_note, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    kIsWeb
                        ? 'Audio found but playback limited on web'
                        : 'Audio will sync with animation',
                    style: TextStyle(
                      color: Colors.amber[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
