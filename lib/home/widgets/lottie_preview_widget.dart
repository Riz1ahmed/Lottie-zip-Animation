import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../lottie_zip_notifier.dart';

class LottiePreviewWidget extends StatefulWidget {
  const LottiePreviewWidget({super.key});

  @override
  State<LottiePreviewWidget> createState() => _LottiePreviewWidgetState();
}

class _LottiePreviewWidgetState extends State<LottiePreviewWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);

    // Set the controller in the notifier
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = Provider.of<LottieZipNotifier>(context, listen: false);
      notifier.setAnimationController(_lottieController);
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<LottieZipNotifier>(context);
    if (notifier.lottieZip?.lottieJson == null) {
      return const AnimationError('No animation data available');
    }

    try {
      final modifiedAnimationData = notifier.replaceImagesInAnimationData();
      return Lottie.memory(
        Uint8List.fromList(utf8.encode(json.encode(modifiedAnimationData))),
        controller: _lottieController,
        onLoaded: (composition) {
          _lottieController.duration = composition.duration;
          _lottieController.forward();
        },
        fit: BoxFit.contain,
        repeat: true,
        errorBuilder: (context, error, stackTrace) {
          return AnimationError('Error loading animation');
        },
      );
    } catch (e) {
      return AnimationError('Animation format error: $e');
    }
  }
}

class AnimationError extends StatelessWidget {
  const AnimationError(this.msg, {super.key});

  final String msg;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 8),
          Text(msg, style: TextStyle(fontSize: 14, color: Colors.red)),
        ],
      ),
    );
  }
}
