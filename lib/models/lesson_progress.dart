class LessonProgress {
  final String lessonId;
  final bool isCompleted;
  final double progressPercentage;
  final List<String> completedQuizzes;
  final DateTime lastUpdated;

  const LessonProgress({
    required this.lessonId,
    required this.isCompleted,
    required this.progressPercentage,
    required this.completedQuizzes,
    required this.lastUpdated,
  });

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    try {
      return LessonProgress(
        lessonId: json['lessonId']?.toString() ?? '',
        isCompleted: json['isCompleted'] == true,
        progressPercentage: (json['progressPercentage'] is num)
            ? (json['progressPercentage'] as num).toDouble()
            : 0.0,
        completedQuizzes: json['completedQuizzes'] is List
            ? List<String>.from(json['completedQuizzes'].map((e) => e.toString()))
            : [],
        lastUpdated: json['lastUpdated'] != null
            ? DateTime.tryParse(json['lastUpdated'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
    } catch (_) {
      return LessonProgress(
        lessonId: json['lessonId']?.toString() ?? '',
        isCompleted: false,
        progressPercentage: 0.0,
        completedQuizzes: const [],
        lastUpdated: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'isCompleted': isCompleted,
      'progressPercentage': progressPercentage,
      'completedQuizzes': completedQuizzes,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}