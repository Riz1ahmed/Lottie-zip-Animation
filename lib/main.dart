import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home/lottie_zip_screen.dart';
import 'home/lottie_zip_notifier.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LottieZipNotifier(),
      child: const LottieZipDemoApp(),
    )
  );
}

class LottieZipDemoApp extends StatelessWidget {
  const LottieZipDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lottie ZIP Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LottieZipViewerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
