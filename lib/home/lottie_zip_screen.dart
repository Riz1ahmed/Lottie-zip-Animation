import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lottie_zip_notifier.dart';
import 'widgets/pickerCard.dart';
import 'widgets/loading_view.dart';
import 'widgets/error_view.dart';
import 'widgets/zip_info_card.dart';
import 'widgets/animation_preview.dart';

class LottieZipViewerScreen extends StatelessWidget {
  const LottieZipViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Lottie ZIP Demo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Consumer<LottieZipNotifier>(
          builder: (context, notifier, child) {
            return Column(
              children: [
                PickerCard(),
                if (notifier.isLoading) const LoadingView(),
                if (notifier.error != null) ErrorView(),
                if (notifier.lottieZip != null) ZipInfoCard(),
                if (notifier.lottieZip?.lottieJson != null) AnimationPreview(),
              ],
            );
          },
        ),
      ),
    );
  }
}
