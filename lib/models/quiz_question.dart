enum QuestionType {
  mcq,
  trueFalse,
  fillInBlank,
}

class QuizQuestion {
  final String id;
  final String questionText;
  final QuestionType type;
  final String correctAnswer;
  final List<String> options;
  final double maxMarks;
  final String? explanation;

  const QuizQuestion({
    required this.id,
    required this.questionText,
    required this.type,
    required this.correctAnswer,
    this.options = const [],
    this.maxMarks = 10.0,
    this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    try {
      QuestionType parseType(String? val) {
        switch (val?.toLowerCase()) {
          case 'mcq':
            return QuestionType.mcq;
          case 'true_false':
          case 'truefalse':
            return QuestionType.trueFalse;
          case 'fill_in_blank':
          case 'fillinblank':
            return QuestionType.fillInBlank;
          default:
            return QuestionType.mcq;
        }
      }

      return QuizQuestion(
        id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        questionText: json['questionText']?.toString() ?? 'Question text unavailable',
        type: parseType(json['type']?.toString()),
        correctAnswer: json['correctAnswer']?.toString() ?? '',
        options: json['options'] != null
            ? List<String>.from(json['options'].map((e) => e.toString()))
            : const [],
        maxMarks: (json['maxMarks'] is num)
            ? (json['maxMarks'] as num).toDouble()
            : 10.0,
        explanation: json['explanation']?.toString(),
      );
    } catch (_) {
      return QuizQuestion(
        id: 'fallback_${DateTime.now().millisecondsSinceEpoch}',
        questionText: 'Question data unreadable',
        type: QuestionType.mcq,
        correctAnswer: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'type': type.name,
      'correctAnswer': correctAnswer,
      'options': options,
      'maxMarks': maxMarks,
      'explanation': explanation,
    };
  }
}
