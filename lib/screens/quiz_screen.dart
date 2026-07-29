import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

// Model structure representation for Quiz Questions
class QuizQuestion {
  final String id;
  final String title;
  final String type; // 'mcq', 'truefalse', 'fillblank'
  final List<String>? options;
  final String correctAnswer;

  QuizQuestion({
    required this.id,
    required this.title,
    required this.type,
    this.options,
    required this.correctAnswer,
  });
}

class QuizScreen extends StatefulWidget {
  final String lessonId;
  final List<QuizQuestion> questions;
  final Isar isar; // Passed Isar database instance

  const QuizScreen({
    Key? key,
    required this.lessonId,
    required this.questions,
    required this.isar,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  final Map<int, String> _userAnswers = {};
  final TextEditingController _fillBlankController = TextEditingController();

  bool _isSubmitted = false;
  int _score = 0;

  @override
  void dispose() {
    _fillBlankController.dispose();
    super.dispose();
  }

  void _onAnswerSelected(String answer) {
    setState(() {
      _userAnswers[_currentIndex] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _fillBlankController.text = _userAnswers[_currentIndex] ?? '';
      });
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _fillBlankController.text = _userAnswers[_currentIndex] ?? '';
      });
    }
  }

  // Calculate score locally and save to Isar DB
  Future<void> _submitQuiz() async {
    int totalScore = 0;

    for (int i = 0; i < widget.questions.length; i++) {
      String? userAnswer = _userAnswers[i]?.trim().toLowerCase();
      String correctAnswer = widget.questions[i].correctAnswer.trim().toLowerCase();

      if (userAnswer != null && userAnswer == correctAnswer) {
        totalScore++;
      }
    }

    setState(() {
      _score = totalScore;
      _isSubmitted = true;
    });

    // Save Result to Isar DB
    await _saveResultToIsar(totalScore, widget.questions.length);
  }

  Future<void> _saveResultToIsar(int score, int total) async {
    final timestamp = DateTime.now();
    
    // Example Isar write transaction
    // Ensure you have a QuizResult collection defined in your Isar models
    /*
    await widget.isar.writeTxn(() async {
      await widget.isar.quizResults.put(
        QuizResult()
          ..lessonId = widget.lessonId
          ..score = score
          ..totalQuestions = total
          ..completedAt = timestamp,
      );
    });
    */
    print("Saved Quiz Result to Isar: Lesson ${widget.lessonId}, Score: $score/$total at $timestamp");
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('No quiz questions available for this lesson.')),
      );
    }

    if (_isSubmitted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Result')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
                const SizedBox(height: 16),
                const Text(
                  'Quiz Completed!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your Score: $_score / ${widget.questions.length}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Lesson'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQuestion = widget.questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz - Question ${_currentIndex + 1}/${widget.questions.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Title
            Text(
              currentQuestion.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Dynamic Widget Rendering based on Question Type
            Expanded(
              child: SingleChildScrollView(
                child: _buildQuestionInput(currentQuestion),
              ),
            ),

            // Navigation Controls
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
                    onPressed: _submitQuiz,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Submit Quiz', style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Dynamic UI builder according to question type
  Widget _buildQuestionInput(QuizQuestion question) {
    switch (question.type.toLowerCase()) {
      case 'mcq':
        return Column(
          children: (question.options ?? []).map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _userAnswers[_currentIndex],
              onChanged: (val) {
                if (val != null) _onAnswerSelected(val);
              },
            );
          }).toList(),
        );

      case 'truefalse':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _userAnswers[_currentIndex] == 'True' ? Colors.blue : Colors.grey[300],
                foregroundColor: _userAnswers[_currentIndex] == 'True' ? Colors.white : Colors.black,
              ),
              onPressed: () => _onAnswerSelected('True'),
              child: const Text('True'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _userAnswers[_currentIndex] == 'False' ? Colors.blue : Colors.grey[300],
                foregroundColor: _userAnswers[_currentIndex] == 'False' ? Colors.white : Colors.black,
              ),
              onPressed: () => _onAnswerSelected('False'),
              child: const Text('False'),
            ),
          ],
        );

      case 'fillblank':
      default:
        return TextField(
          controller: _fillBlankController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Type your answer here...',
          ),
          onChanged: (val) => _onAnswerSelected(val),
        );
    }
  }
}