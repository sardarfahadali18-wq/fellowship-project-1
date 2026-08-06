class QuizQuestionResult {
  final String questionId;
  final String questionText;
  final dynamic userAnswer;
  final String correctAnswer;
  final double obtainedMarks;
  final double maxMarks;
  final String feedbackMessage;
  final bool isCorrect;

  const QuizQuestionResult({
    required this.questionId,
    required this.questionText,
    required this.userAnswer,
    required this.correctAnswer,
    required this.obtainedMarks,
    required this.maxMarks,
    required this.feedbackMessage,
    required this.isCorrect,
  });

  factory QuizQuestionResult.fromJson(Map<String, dynamic> json) {
    return QuizQuestionResult(
      questionId: json['questionId']?.toString() ?? '',
      questionText: json['questionText']?.toString() ?? '',
      userAnswer: json['userAnswer'],
      correctAnswer: json['correctAnswer']?.toString() ?? '',
      obtainedMarks: (json['obtainedMarks'] is num)
          ? (json['obtainedMarks'] as num).toDouble()
          : 0.0,
      maxMarks: (json['maxMarks'] is num)
          ? (json['maxMarks'] as num).toDouble()
          : 0.0,
      feedbackMessage: json['feedbackMessage']?.toString() ?? '',
      isCorrect: json['isCorrect'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'obtainedMarks': obtainedMarks,
      'maxMarks': maxMarks,
      'feedbackMessage': feedbackMessage,
      'isCorrect': isCorrect,
    };
  }
}

class QuizResult {
  final String lessonId;
  final String quizId;
  final Map<String, dynamic> answers;
  final double obtainedScore;
  final double totalScore;
  final double percentage;
  final bool isPassed;
  final DateTime completedTimestamp;
  final int attemptNumber;
  final bool synced;
  final List<QuizQuestionResult> questionResults;

  const QuizResult({
    required this.lessonId,
    required this.quizId,
    required this.answers,
    required this.obtainedScore,
    required this.totalScore,
    required this.percentage,
    required this.isPassed,
    required this.completedTimestamp,
    required this.attemptNumber,
    required this.synced,
    required this.questionResults,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    try {
      return QuizResult(
        lessonId: json['lessonId']?.toString() ?? '',
        quizId: json['quizId']?.toString() ?? '',
        answers: json['answers'] is Map
            ? Map<String, dynamic>.from(json['answers'])
            : {},
        obtainedScore: (json['obtainedScore'] is num)
            ? (json['obtainedScore'] as num).toDouble()
            : 0.0,
        totalScore: (json['totalScore'] is num)
            ? (json['totalScore'] as num).toDouble()
            : 0.0,
        percentage: (json['percentage'] is num)
            ? (json['percentage'] as num).toDouble()
            : 0.0,
        isPassed: json['isPassed'] == true,
        completedTimestamp: json['completedTimestamp'] != null
            ? DateTime.tryParse(json['completedTimestamp'].toString()) ?? DateTime.now()
            : DateTime.now(),
        attemptNumber: (json['attemptNumber'] is int) ? json['attemptNumber'] : 1,
        synced: json['synced'] == true,
        questionResults: json['questionResults'] is List
            ? (json['questionResults'] as List)
                .map((e) => QuizQuestionResult.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : [],
      );
    } catch (_) {
      return QuizResult(
        lessonId: json['lessonId']?.toString() ?? 'unknown',
        quizId: json['quizId']?.toString() ?? 'unknown',
        answers: {},
        obtainedScore: 0.0,
        totalScore: 0.0,
        percentage: 0.0,
        isPassed: false,
        completedTimestamp: DateTime.now(),
        attemptNumber: 1,
        synced: false,
        questionResults: [],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'quizId': quizId,
      'answers': answers,
      'obtainedScore': obtainedScore,
      'totalScore': totalScore,
      'percentage': percentage,
      'isPassed': isPassed,
      'completedTimestamp': completedTimestamp.toIso8601String(),
      'attemptNumber': attemptNumber,
      'synced': synced,
      'questionResults': questionResults.map((e) => e.toJson()).toList(),
    };
  }

  QuizResult copyWith({
    String? lessonId,
    String? quizId,
    Map<String, dynamic>? answers,
    double? obtainedScore,
    double? totalScore,
    double? percentage,
    bool? isPassed,
    DateTime? completedTimestamp,
    int? attemptNumber,
    bool? synced,
    List<QuizQuestionResult>? questionResults,
  }) {
    return QuizResult(
      lessonId: lessonId ?? this.lessonId,
      quizId: quizId ?? this.quizId,
      answers: answers ?? this.answers,
      obtainedScore: obtainedScore ?? this.obtainedScore,
      totalScore: totalScore ?? this.totalScore,
      percentage: percentage ?? this.percentage,
      isPassed: isPassed ?? this.isPassed,
      completedTimestamp: completedTimestamp ?? this.completedTimestamp,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      synced: synced ?? this.synced,
      questionResults: questionResults ?? this.questionResults,
    );
  }
}