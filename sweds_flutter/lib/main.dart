import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully for project: sweds26');
  } catch (e, st) {
    debugPrint('Firebase initialization failed: $e\n$st');
  }
  VisibilityDetectorController.instance.updateInterval =
      const Duration(milliseconds: 80);
  runApp(const ProviderScope(child: WeddingApp()));
}
