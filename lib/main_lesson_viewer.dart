import 'package:flutter/material.dart';

import 'package:fellowship_project_1/data/sample_data.dart';
import 'package:fellowship_project_1/screens/lesson_list_screen.dart';

/// Standalone test entry point for the offline lesson viewer.
/// Run with: flutter run -t lib/main_lesson_viewer.dart
///
/// This exists so the lesson viewer can be built and tested in isolation
/// without touching the main app's Firebase/auth flow. It will be wired
/// into the real app during integration (Day 7-8).
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SampleData.seedIfEmpty();
  runApp(const LessonViewerTestApp());
}

class LessonViewerTestApp extends StatelessWidget {
  const LessonViewerTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lesson Viewer (Test)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LessonListScreen(),
    );
  }
}


