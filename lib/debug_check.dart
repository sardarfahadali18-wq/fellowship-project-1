import 'package:fellowship_project_1/data/isar_service.dart';

void main() async {
  final isar = await IsarService.getInstance();
  final lessons = await isar.lessons.where().findAll();
  for (final l in lessons) {
    print('Lesson: ${l.title}, order: ${l.order}, quizId: ${l.quizId}');
  }
  final quizzes = await isar.quizs.where().findAll();
  print('Total quizzes in DB: ${quizzes.length}');
}
