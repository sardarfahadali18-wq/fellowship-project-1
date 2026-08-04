import 'package:flutter/material.dart';
import '../models/quiz_result.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizResult result;
  final VoidCallback? onRetake;

  const QuizResultScreen({
    Key? key,
    required this.result,
    this.onRetake,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: result.isPassed ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      result.isPassed ? Icons.check_circle : Icons.cancel,
                      size: 64,
                      color: result.isPassed ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      result.isPassed ? 'PASSED' : 'FAILED',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: result.isPassed ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${result.percentage.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Score: ${result.obtainedScore} / ${result.totalScore} (Attempt #${result.attemptNumber})',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.sync, color: Colors.blue),
                title: const Text('Offline Sync Status'),
                subtitle: const Text('Saved locally & queued in Sync Outbox'),
              ),
            ),
            const SizedBox(height: 16),
            Text('Question Breakdown', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...result.questionResults.map((qRes) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  title: Text(qRes.questionText),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Your Answer: ${qRes.userAnswer}'),
                      Text('Correct Answer: ${qRes.correctAnswer}'),
                      Text('Feedback: ${qRes.feedbackMessage}'),
                    ],
                  ),
                  trailing: Text(
                    '${qRes.obtainedMarks} / ${qRes.maxMarks}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: qRes.obtainedMarks > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
            Row(
              children: [
                if (onRetake != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onRetake,
                      child: const Text('Retake Quiz'),
                    ),
                  ),
                if (onRetake != null) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Lesson'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}