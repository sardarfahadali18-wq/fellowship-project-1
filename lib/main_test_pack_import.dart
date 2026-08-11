import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';

import 'data/isar_service.dart';
import 'data/lesson_pack_parser.dart';
import 'data/models/lesson.dart';
import 'data/models/lesson_pack.dart';

/// Standalone test entry point for the lesson pack zip parser.
/// Builds a small pack in memory (no real zip file needed) and runs it
/// through LessonPackParser, then prints what landed in Isar.
///
/// Run with: flutter run -t lib/main_test_pack_import.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _TestApp());
}

class _TestApp extends StatefulWidget {
  const _TestApp();

  @override
  State<_TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<_TestApp> {
  String _log = 'Running test...';

  @override
  void initState() {
    super.initState();
    _runTest();
  }

  Future<void> _runTest() async {
    final buffer = StringBuffer();

    final manifest = {
      'subject': 'Science',
      'title': 'Grade 6 Water Cycle',
      'version': 1,
      'lessons': [
        {
          'title': 'The Water Cycle',
          'order': 1,
          'contentFile': 'lessons/lesson1.md',
          'assets': <String>[],
          'quiz': {
            'questions': [
              {
                'text': 'Water vapor rises and cools to form ___.',
                'type': 'fillBlank',
                'options': <String>[],
                'correctAnswer': 'clouds',
              }
            ],
          },
        },
      ],
    };

    final manifestBytes = utf8.encode(jsonEncode(manifest));
    final mdContent =
        '# The Water Cycle\n\nWater evaporates, condenses, and falls as rain.';
    final mdBytes = utf8.encode(mdContent);

    final archive = Archive();
    archive.addFile(
      ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
    );
    archive.addFile(
      ArchiveFile('lessons/lesson1.md', mdBytes.length, mdBytes),
    );

    final zipBytes = Uint8List.fromList(ZipEncoder().encode(archive));
    buffer.writeln('Built in-memory test zip (${zipBytes.length} bytes)');

    try {
      final packId = await LessonPackParser.importFromZip(zipBytes);
      buffer.writeln('Imported pack with id: $packId');

      final isar = await IsarService.getInstance();
      final pack = await isar.lessonPacks.get(packId);
      buffer.writeln('Pack title: ${pack?.title}, subject: ${pack?.subject}');

      final lessons =
          await isar.lessons.filter().packIdEqualTo(packId).findAll();
      for (final l in lessons) {
        buffer.writeln('Lesson: ${l.title}, quizId: ${l.quizId}');
        buffer.writeln('Content: ${l.contentMarkdown}');
      }
      buffer.writeln('TEST PASSED');
    } catch (e, st) {
      buffer.writeln('TEST FAILED: $e');
      buffer.writeln(st.toString());
    }

    setState(() => _log = buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Pack Import Test')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(_log),
        ),
      ),
    );
  }
}



