import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models/lesson.dart';
import 'models/lesson_pack.dart';
import 'models/quiz.dart';
import 'models/student.dart';
import 'models/sync_event.dart';

class IsarService {
  static Isar? _isar;

  static Future<Isar> getInstance() async {
    if (_isar != null) {
      return _isar!;
    }

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [
        StudentSchema,
        LessonPackSchema,
        LessonSchema,
        QuizSchema,
        SyncEventSchema,
      ],
      directory: dir.path,
    );

    return _isar!;
  }
}
