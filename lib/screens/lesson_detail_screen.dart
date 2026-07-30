import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../data/isar_service.dart';
import '../data/models/lesson.dart';
class LessonDetailScreen extends StatefulWidget {
  final int lessonId;
  const LessonDetailScreen({super.key, required this.lessonId});
  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}
class _LessonDetailScreenState extends State<LessonDetailScreen> {
  late Future<Lesson?> _lessonFuture;
  @override
  void initState() {
    super.initState();
    _lessonFuture = _loadLesson();
  }
  Future<Lesson?> _loadLesson() async {
    final isar = await IsarService.getInstance();
    return isar.lessons.get(widget.lessonId);
  }
  Future<void> _markComplete(Lesson lesson) async {
    final isar = await IsarService.getInstance();
    await isar.writeTxn(() async {
      lesson.isCompleted = true;
      await isar.lessons.put(lesson);
    });
    setState(() {
      _lessonFuture = _loadLesson();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson marked as complete!')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson')),
      body: FutureBuilder<Lesson?>(
        future: _lessonFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final lesson = snapshot.data;
          if (lesson == null) {
            return const Center(child: Text('Lesson not found.'));
          }
          return Column(
            children: [
              Expanded(
                child: Markdown(
                  data: lesson.contentMarkdown,
                  padding: const EdgeInsets.all(16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: lesson.isCompleted
                      ? OutlinedButton.icon(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          label: const Text('Completed'),
                          onPressed: null,
                        )
                      : FilledButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('Mark as Complete'),
                          onPressed: () => _markComplete(lesson),
                        ),
                ),
              ),
              if (lesson.quizId != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.quiz),
                      label: const Text('Take Quiz'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Quiz engine coming soon (built by Faizan).',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

