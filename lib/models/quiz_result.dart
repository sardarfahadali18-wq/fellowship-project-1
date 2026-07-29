import 'package:isar/isar.dart';

part 'quiz_result.g.dart';

@collection
class QuizResult {
  Id id = Isar.autoIncrement;

  @Index()
  late String lessonId;

  late int score;
  late int totalQuestions;
  late DateTime completedAt;
}