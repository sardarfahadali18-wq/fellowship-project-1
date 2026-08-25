import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../data/isar_service.dart';
import '../data/models/lesson.dart';
import '../data/models/quiz.dart' as isar_quiz;
import '../models/quiz_question.dart';
import 'quiz_screen.dart';
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
  // Converts an Isar Question.type into Faizan's QuizQuestion QuestionType.
  QuestionType _mapQuestionType(isar_quiz.QuestionType type) {
    switch (type) {
      case isar_quiz.QuestionType.mcq:
        return QuestionType.mcq;
      case isar_quiz.QuestionType.trueFalse:
        return QuestionType.trueFalse;
      case isar_quiz.QuestionType.fillBlank:
        return QuestionType.fillInBlank;
    }
  }

  // Converts the Isar Quiz/Question model into the List<QuizQuestion>
  // format that Faizan's QuizScreen expects.
  List<QuizQuestion> _convertQuestions(isar_quiz.Quiz quiz) {
    final List<QuizQuestion> result = [];
    for (var i = 0; i < quiz.questions.length; i++) {
      final q = quiz.questions[i];
      result.add(
        QuizQuestion(
          id: '${quiz.id}_$i',
          questionText: q.text ?? 'Question text unavailable',
          type: _mapQuestionType(q.type),
          correctAnswer: q.correctAnswer ?? '',
          options: q.options,
        ),
      );
    }
    return result;
  }

  Future<void> _openQuiz(Lesson lesson) async {
    if (lesson.quizId == null) return;
    final isar = await IsarService.getInstance();
    final quiz = await isar.quizs.get(lesson.quizId!);

    if (quiz == null || quiz.questions.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No quiz available for this lesson yet.')),
        );
      }
      return;
    }

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          lessonId: lesson.id.toString(),
          quizId: quiz.id.toString(),
          quizTitle: '${lesson.title} Quiz',
          questions: _convertQuestions(quiz),
        ),
      ),
    );
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
                      onPressed: () => _openQuiz(lesson),
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
