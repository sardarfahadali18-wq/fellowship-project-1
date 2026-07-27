import 'package:isar_community/isar.dart';

part 'lesson.g.dart';

@collection
class Lesson {
  Id id = Isar.autoIncrement;

  @Index()
  late int packId;

  late String title;

  late int order;

  late String contentMarkdown;

  List<String> assetPaths = [];

  int? quizId;
}
