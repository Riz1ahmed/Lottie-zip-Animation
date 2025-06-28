import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'home/lottie_zip_screen.dart';
import 'models/lottie_zip_model.dart';
import 'services/lottie_zip_service.dart';
import 'home/widgets/upload_section.dart';
import 'home/widgets/loading_section.dart';
import 'home/widgets/error_section.dart';
import 'home/widgets/images_preview.dart';
import 'home/widgets/info_card_row.dart';
import 'home/widgets/control_button.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LottieZipModel(),
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
      home: const LottieZipScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
