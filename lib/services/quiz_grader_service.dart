import 'dart:math';
import '../models/quiz_question.dart';
import '../models/quiz_result.dart';

class QuizGraderService {
  /// Calculates Levenshtein Distance for String similarity
  static int _levenshteinDistance(String s1, String s2) {
    int m = s1.length;
    int n = s2.length;
    List<List<int>> dp = List.generate(
      m + 1,
      (_) => List<int>.filled(n + 1, 0),
    );

    for (int i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= n; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (s1[i - 1] == s2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 +
              min(
                dp[i - 1][j],
                min(
                  dp[i][j - 1],
                  dp[i - 1][j - 1],
                ),
              );
        }
      }
    }
    return dp[m][n];
  }

  /// Evaluates fuzzy string similarity between 0.0 and 1.0
  static double _calculateSimilarity(String userAns, String correctAns) {
    final uStr = userAns.trim().toLowerCase();
    final cStr = correctAns.trim().toLowerCase();

    if (uStr.isEmpty && cStr.isEmpty) return 1.0;
    if (uStr.isEmpty || cStr.isEmpty) return 0.0;
    if (uStr == cStr) return 1.0;

    int distance = _levenshteinDistance(uStr, cStr);
    int maxLen = max(uStr.length, cStr.length);
    double similarity = 1.0 - (distance / maxLen);
    return max(0.0, similarity);
  }

  /// Grade single question according to type
  static QuizQuestionResult gradeQuestion(
    QuizQuestion question,
    dynamic userAnswer, {
    double fullMatchThreshold = 0.85,
    double partialMatchThreshold = 0.70,
  }) {
    if (userAnswer == null || userAnswer.toString().trim().isEmpty) {
      return QuizQuestionResult(
        questionId: question.id,
        questionText: question.questionText,
        userAnswer: userAnswer ?? 'Skipped',
        correctAnswer: question.correctAnswer,
        obtainedMarks: 0.0,
        maxMarks: question.maxMarks,
        feedbackMessage: 'Skipped or empty answer',
        isCorrect: false,
      );
    }

    final String userStr = userAnswer.toString().trim();
    final String correctStr = question.correctAnswer.trim();

    switch (question.type) {
      case QuestionType.mcq:
      case QuestionType.trueFalse:
        final bool isMatch = userStr.toLowerCase() == correctStr.toLowerCase();
        return QuizQuestionResult(
          questionId: question.id,
          questionText: question.questionText,
          userAnswer: userStr,
          correctAnswer: correctStr,
          obtainedMarks: isMatch ? question.maxMarks : 0.0,
          maxMarks: question.maxMarks,
          feedbackMessage: isMatch ? 'Exact match' : 'Incorrect',
          isCorrect: isMatch,
        );

      case QuestionType.fillInBlank:
        final double similarity = _calculateSimilarity(userStr, correctStr);

        if (similarity >= fullMatchThreshold) {
          return QuizQuestionResult(
            questionId: question.id,
            questionText: question.questionText,
            userAnswer: userStr,
            correctAnswer: correctStr,
            obtainedMarks: question.maxMarks,
            maxMarks: question.maxMarks,
            feedbackMessage:
                'Accepted (${(similarity * 100).toStringAsFixed(0)}% match)',
            isCorrect: true,
          );
        } else if (similarity >= partialMatchThreshold) {
          final double partialMarks = question.maxMarks * similarity;
          return QuizQuestionResult(
            questionId: question.id,
            questionText: question.questionText,
            userAnswer: userStr,
            correctAnswer: correctStr,
            obtainedMarks: double.parse(partialMarks.toStringAsFixed(2)),
            maxMarks: question.maxMarks,
            feedbackMessage:
                'Partial credit (${(similarity * 100).toStringAsFixed(0)}% match)',
            isCorrect: false,
          );
        } else {
          return QuizQuestionResult(
            questionId: question.id,
            questionText: question.questionText,
            userAnswer: userStr,
            correctAnswer: correctStr,
            obtainedMarks: 0.0,
            maxMarks: question.maxMarks,
            feedbackMessage: 'Incorrect answer',
            isCorrect: false,
          );
        }
    }
  }

  /// Grade entire quiz and produce complete result
  static QuizResult gradeQuiz({
    required String lessonId,
    required String quizId,
    required List<QuizQuestion> questions,
    required Map<String, dynamic> userAnswers,
    int attemptNumber = 1,
    double passThresholdPercentage = 60.0,
  }) {
    double totalMaxMarks = 0.0;
    double totalObtainedMarks = 0.0;
    List<QuizQuestionResult> results = [];

    for (var question in questions) {
      totalMaxMarks += question.maxMarks;
      final userAnswer = userAnswers[question.id];
      final qResult = gradeQuestion(question, userAnswer);
      results.add(qResult);
      totalObtainedMarks += qResult.obtainedMarks;
    }

    final double percentage = (totalMaxMarks > 0)
        ? (totalObtainedMarks / totalMaxMarks) * 100.0
        : 0.0;

    final double roundedPercentage =
        double.parse(percentage.toStringAsFixed(2));
    final double roundedObtained =
        double.parse(totalObtainedMarks.toStringAsFixed(2));

    return QuizResult(
      lessonId: lessonId,
      quizId: quizId,
      answers: userAnswers,
      obtainedScore: roundedObtained,
      totalScore: totalMaxMarks,
      percentage: roundedPercentage,
      isPassed: roundedPercentage >= passThresholdPercentage,
      completedTimestamp: DateTime.now(),
      attemptNumber: attemptNumber,
      synced: false,
      questionResults: results,
    );
  }
}