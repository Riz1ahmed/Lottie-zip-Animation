import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie_zip_animation/home/preview_action.dart';
import 'package:provider/provider.dart';
import '../lottie_zip_notifier.dart';
import 'control_button.dart';
import 'lottie_preview_widget.dart';

class AnimationPreview extends StatefulWidget {
  const AnimationPreview({super.key});

  @override
  State<AnimationPreview> createState() => _AnimationPreviewState();
}

class _AnimationPreviewState extends State<AnimationPreview> {
  @override
  Widget build(BuildContext context) {
    final LottieZipNotifier notifier = Provider.of(context);

    return Container(
      width: double.infinity,
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
              border: Border.all(color: Colors.grey.withAlpha(77)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LottiePreviewWidget(),
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
                onTap: () => notifier.controlAnimation(PreviewAction.play),
                color: Colors.green,
              ),
              ControlButton(
                icon: Icons.pause,
                label: 'Pause',
                onTap: () => notifier.controlAnimation(PreviewAction.pause),
                color: Colors.orange,
              ),
              ControlButton(
                icon: Icons.stop,
                label: 'Stop',
                onTap: () => notifier.controlAnimation(PreviewAction.stop),
                color: Colors.red,
              ),
              ControlButton(
                icon: Icons.refresh,
                label: 'Restart',
                onTap: () => notifier.controlAnimation(PreviewAction.restart),
                color: Colors.blue,
              ),
            ],
          ),

          // Audio Info
          if (notifier.lottieZip?.audioData != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withAlpha(77)),
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
