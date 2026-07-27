import 'package:isar_community/isar.dart';

part 'student.g.dart';

@collection
class Student {
  Id id = Isar.autoIncrement;

  late String name;

  String? classCode;

  late String deviceId;

  late DateTime createdAt;
}
