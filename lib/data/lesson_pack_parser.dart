import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

import 'isar_service.dart';
import 'models/lesson.dart';
import 'models/lesson_pack.dart';
import 'models/quiz.dart';

/// Parses a compressed lesson pack (.zip) and stores its contents in Isar.
///
/// Expected zip structure:
///   manifest.json
///   lessons/*.md
///   assets/*.png|jpg (optional, referenced from manifest "assets" list)
class LessonPackParser {
  /// Unpacks [zipBytes], parses manifest.json, copies any bundled assets
  /// to local app storage, and writes LessonPack/Lesson/Quiz records to
  /// Isar. Returns the new LessonPack's id.
  static Future<int> importFromZip(Uint8List zipBytes) async {
    final archive = ZipDecoder().decodeBytes(zipBytes);

    final manifestFile = archive.files.firstWhere(
      (f) => f.name == 'manifest.json',
      orElse: () => throw Exception('manifest.json not found in pack'),
    );
    final manifestJson = utf8.decode(manifestFile.content as List<int>);
    final manifest = jsonDecode(manifestJson) as Map<String, dynamic>;

    final appDir = await getApplicationDocumentsDirectory();
    final isar = await IsarService.getInstance();

    late int packId;

    await isar.writeTxn(() async {
      final pack = LessonPack()
        ..subject = manifest['subject'] as String
        ..title = manifest['title'] as String
        ..version = manifest['version'] as int
        ..sizeBytes = zipBytes.length
        ..isDownloaded = true;
      packId = await isar.lessonPacks.put(pack);

      final lessonIds = <int>[];
      final lessonsJson = manifest['lessons'] as List<dynamic>;

      for (final lessonJson in lessonsJson) {
        final lessonMap = lessonJson as Map<String, dynamic>;

        final contentPath = lessonMap['contentFile'] as String;
        final contentFile = archive.files.firstWhere(
          (f) => f.name == contentPath,
          orElse: () => throw Exception('Missing content file: $contentPath'),
        );
        final contentMarkdown = utf8.decode(contentFile.content as List<int>);

        final assetPaths = <String>[];
        final assets = (lessonMap['assets'] as List<dynamic>? ?? []);
        for (final assetPath in assets) {
          final assetFile = archive.files.firstWhere(
            (f) => f.name == assetPath as String,
            orElse: () => throw Exception('Missing asset: $assetPath'),
          );
          final outFile = File(
            '${appDir.path}/packs/$packId/${assetPath.split('/').last}',
          );
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(assetFile.content as List<int>);
          assetPaths.add(outFile.path);
        }

        final lesson = Lesson()
          ..packId = packId
          ..title = lessonMap['title'] as String
          ..order = lessonMap['order'] as int
          ..contentMarkdown = contentMarkdown
          ..assetPaths = assetPaths;
        final lessonId = await isar.lessons.put(lesson);
        lessonIds.add(lessonId);

        final quizJson = lessonMap['quiz'] as Map<String, dynamic>?;
        if (quizJson != null) {
          final questions = (quizJson['questions'] as List<dynamic>).map((q) {
            final qm = q as Map<String, dynamic>;
            return Question()
              ..text = qm['text'] as String
              ..type = QuestionType.values.byName(qm['type'] as String)
              ..options = (qm['options'] as List<dynamic>? ?? [])
                  .map((o) => o as String)
                  .toList()
              ..correctAnswer = qm['correctAnswer'] as String;
          }).toList();

          final quiz = Quiz()
            ..lessonId = lessonId
            ..questions = questions;
          final quizId = await isar.quizs.put(quiz);

          lesson.quizId = quizId;
          await isar.lessons.put(lesson);
        }
      }

      pack.lessonIds = lessonIds;
      await isar.lessonPacks.put(pack);
    });

    return packId;
  }
}
