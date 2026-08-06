import 'package:isar_community/isar.dart';

part 'lesson_pack.g.dart';

@collection
class LessonPack {
  Id id = Isar.autoIncrement;

  late String subject;

  late String title;

  late int version;

  late int sizeBytes;

  List<int> lessonIds = [];

  bool isDownloaded = false;
}
