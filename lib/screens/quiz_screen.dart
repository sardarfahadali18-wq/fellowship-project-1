import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../models/quiz_result.dart';
import '../services/quiz_grader_service.dart';
import '../services/quiz_storage_service.dart';
import '../services/progress_tracking_service.dart';
import '../services/sync_outbox_service.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String lessonId;
  final String quizId;
  final String quizTitle;
  final List<QuizQuestion> questions;
  final int totalLessonQuizzes;

  const QuizScreen({
    Key? key,
    required this.lessonId,
    required this.quizId,
    this.quizTitle = 'Lesson Quiz',
    required this.questions,
    this.totalLessonQuizzes = 1,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  final Map<String, dynamic> _userAnswers = {};
  final TextEditingController _textController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onAnswerSelected(dynamic value) {
    final q = widget.questions[_currentIndex];
    setState(() {
      _userAnswers[q.id] = value;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _syncTextField();
      });
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _syncTextField();
      });
    }
  }

  void _syncTextField() {
    final q = widget.questions[_currentIndex];
    if (q.type == QuestionType.fillInBlank) {
      _textController.text = _userAnswers[q.id]?.toString() ?? '';
    }
  }

  Future<void> _submitQuiz() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    try {
      final currentAttempt = await QuizStorageService.getAttemptCount(
        widget.lessonId,
        widget.quizId,
      );
      final nextAttempt = currentAttempt + 1;

      // 1. Grade quiz
      final QuizResult result = QuizGraderService.gradeQuiz(
        lessonId: widget.lessonId,
        quizId: widget.quizId,
        questions: widget.questions,
        userAnswers: _userAnswers,
        attemptNumber: nextAttempt,
      );

      // 2. Save result locally
      await QuizStorageService.saveResult(result);

      // 3. Connect to progress tracking
      await ProgressTrackingService.updateProgressForQuizCompleted(
        lessonId: widget.lessonId,
        quizId: widget.quizId,
        totalQuizzesInLesson: widget.totalLessonQuizzes,
      );

      // 4. Offline sync outbox entry
      await SyncOutboxService.enqueueQuizResult(result);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            result: result,
            onRetake: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizScreen(
                    lessonId: widget.lessonId,
                    quizId: widget.quizId,
                    quizTitle: widget.quizTitle,
                    questions: widget.questions,
                    totalLessonQuizzes: widget.totalLessonQuizzes,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing quiz: $e')),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quizTitle)),
        body: const Center(child: Text('No questions available in this quiz.')),
      );
    }

    final QuizQuestion q = widget.questions[_currentIndex];
    final double progress = (_currentIndex + 1) / widget.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(value: progress),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${_currentIndex + 1} of ${widget.questions.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              q.questionText,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildQuestionInput(q)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentIndex > 0)
                  OutlinedButton(
                    onPressed: _previousQuestion,
                    child: const Text('Previous'),
                  )
                else
                  const SizedBox.shrink(),
                if (_currentIndex < widget.questions.length - 1)
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    child: const Text('Next'),
                  )
                else
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitQuiz,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Quiz'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionInput(QuizQuestion q) {
    switch (q.type) {
      case QuestionType.mcq:
        return ListView.builder(
          itemCount: q.options.length,
          itemBuilder: (context, idx) {
            final opt = q.options[idx];
            final selected = _userAnswers[q.id] == opt;
            return Card(
              color: selected ? Colors.blue.shade50 : null,
              child: RadioListTile<String>(
                title: Text(opt),
                value: opt,
                groupValue: _userAnswers[q.id]?.toString(),
                onChanged: _onAnswerSelected,
              ),
            );
          },
        );

      case QuestionType.trueFalse:
        return Column(
          children: ['True', 'False'].map((opt) {
            final selected =
                _userAnswers[q.id]?.toString().toLowerCase() == opt.toLowerCase();
            return Card(
              color: selected ? Colors.blue.shade50 : null,
              child: RadioListTile<String>(
                title: Text(opt),
                value: opt,
                groupValue: _userAnswers[q.id]?.toString(),
                onChanged: _onAnswerSelected,
              ),
            );
          }).toList(),
        );

      case QuestionType.fillInBlank:
        return Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Type your answer here...',
              ),
              onChanged: (val) => _onAnswerSelected(val),
            ),
          ],
        );
    }
  }
}