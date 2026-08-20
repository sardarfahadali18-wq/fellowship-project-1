import 'package:isar_community/isar.dart';

part 'quiz.g.dart';

enum QuestionType {
  mcq,
  trueFalse,
  fillBlank,
}

@embedded
class Question {
  String? text;

  @enumerated
  QuestionType type = QuestionType.mcq;

  List<String> options = [];

  String? correctAnswer;
}

@collection
class Quiz {
  Id id = Isar.autoIncrement;

  @Index()
  late int lessonId;

  List<Question> questions = [];
}
