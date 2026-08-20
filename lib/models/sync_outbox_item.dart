enum SyncStatus { pending, failed, synced }

class SyncOutboxItem {
  final String id;
  final String quizId;
  final String lessonId;
  final Map<String, dynamic> answers;
  final double obtainedScore;
  final double totalScore;
  final double percentage;
  final DateTime timestamp;
  final int retryCount;
  final SyncStatus status;
  final String? errorMessage;

  const SyncOutboxItem({
    required this.id,
    required this.quizId,
    required this.lessonId,
    required this.answers,
    required this.obtainedScore,
    required this.totalScore,
    required this.percentage,
    required this.timestamp,
    this.retryCount = 0,
    this.status = SyncStatus.pending,
    this.errorMessage,
  });

  factory SyncOutboxItem.fromJson(Map<String, dynamic> json) {
    try {
      SyncStatus parseStatus(String? val) {
        switch (val?.toLowerCase()) {
          case 'synced':
            return SyncStatus.synced;
          case 'failed':
            return SyncStatus.failed;
          default:
            return SyncStatus.pending;
        }
      }

      return SyncOutboxItem(
        id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        quizId: json['quizId']?.toString() ?? '',
        lessonId: json['lessonId']?.toString() ?? '',
        answers: json['answers'] is Map ? Map<String, dynamic>.from(json['answers']) : {},
        obtainedScore: (json['obtainedScore'] is num) ? (json['obtainedScore'] as num).toDouble() : 0.0,
        totalScore: (json['totalScore'] is num) ? (json['totalScore'] as num).toDouble() : 0.0,
        percentage: (json['percentage'] is num) ? (json['percentage'] as num).toDouble() : 0.0,
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
            : DateTime.now(),
        retryCount: (json['retryCount'] is int) ? json['retryCount'] : 0,
        status: parseStatus(json['status']?.toString()),
        errorMessage: json['errorMessage']?.toString(),
      );
    } catch (_) {
      return SyncOutboxItem(
        id: 'corrupt_${DateTime.now().millisecondsSinceEpoch}',
        quizId: '',
        lessonId: '',
        answers: {},
        obtainedScore: 0.0,
        totalScore: 0.0,
        percentage: 0.0,
        timestamp: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'lessonId': lessonId,
      'answers': answers,
      'obtainedScore': obtainedScore,
      'totalScore': totalScore,
      'percentage': percentage,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
      'status': status.name,
      'errorMessage': errorMessage,
    };
  }

  Map<String, dynamic> toApiPayload() {
    return {
      'outbox_id': id,
      'quiz_id': quizId,
      'lesson_id': lessonId,
      'answers': answers,
      'score': {
        'obtained': obtainedScore,
        'total': totalScore,
        'percentage': percentage,
      },
      'completed_at': timestamp.toIso8601String(),
    };
  }

  SyncOutboxItem copyWith({
    int? retryCount,
    SyncStatus? status,
    String? errorMessage,
  }) {
    return SyncOutboxItem(
      id: id,
      quizId: quizId,
      lessonId: lessonId,
      answers: answers,
      obtainedScore: obtainedScore,
      totalScore: totalScore,
      percentage: percentage,
      timestamp: timestamp,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}