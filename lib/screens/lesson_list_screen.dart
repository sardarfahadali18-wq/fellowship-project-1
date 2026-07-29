import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';

import '../data/isar_service.dart';
import '../data/models/lesson.dart';
import '../data/models/lesson_pack.dart';
import 'lesson_detail_screen.dart';

class LessonListScreen extends StatefulWidget {
  const LessonListScreen({super.key});

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  late Future<List<_PackWithLessons>> _packsFuture;

  @override
  void initState() {
    super.initState();
    _packsFuture = _loadPacks();
  }

  Future<List<_PackWithLessons>> _loadPacks() async {
    final isar = await IsarService.getInstance();
    final packs = await isar.lessonPacks.where().findAll();

    final result = <_PackWithLessons>[];
    for (final pack in packs) {
      final lessons = await isar.lessons
          .filter()
          .packIdEqualTo(pack.id)
          .sortByOrder()
          .findAll();
      result.add(_PackWithLessons(pack: pack, lessons: lessons));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Courses')),
      body: FutureBuilder<List<_PackWithLessons>>(
        future: _packsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final packs = snapshot.data ?? [];
          if (packs.isEmpty) {
            return const Center(child: Text('No courses downloaded yet.'));
          }

          return ListView.builder(
            itemCount: packs.length,
            itemBuilder: (context, index) {
              final packWithLessons = packs[index];
              final pack = packWithLessons.pack;
              final lessons = packWithLessons.lessons;

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ExpansionTile(
                  leading: Icon(
                    pack.isDownloaded
                        ? Icons.offline_pin
                        : Icons.cloud_download,
                    color: pack.isDownloaded ? Colors.green : Colors.grey,
                  ),
                  title: Text(pack.title),
                  subtitle: Text(
                    '${pack.subject} • ${lessons.length} lessons • '
                    '${pack.isDownloaded ? "Available offline" : "Not downloaded"}',
                  ),
                  children: lessons.map((lesson) {
                    return ListTile(
                      leading: CircleAvatar(child: Text('${lesson.order}')),
                      title: Text(lesson.title),
                      trailing: lesson.quizId != null
                        ? const Icon(Icons.quiz, size: 18)
                        : null,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                LessonDetailScreen(lessonId: lesson.id),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PackWithLessons {
  final LessonPack pack;
  final List<Lesson> lessons;

  _PackWithLessons({required this.pack, required this.lessons});
}

