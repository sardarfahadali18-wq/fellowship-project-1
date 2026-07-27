import 'isar_service.dart';
import 'models/lesson.dart';
import 'models/lesson_pack.dart';
import 'models/quiz.dart';

class SampleData {
  static Future<void> seedIfEmpty() async {
    final isar = await IsarService.getInstance();

    final existingCount = await isar.lessonPacks.count();
    if (existingCount > 0) {
      return;
    }

    await isar.writeTxn(() async {
      final pack = LessonPack()
        ..subject = 'Mathematics'
        ..title = 'Grade 7 Basic Algebra'
        ..version = 1
        ..sizeBytes = 1024 * 200
        ..isDownloaded = true;

      final packId = await isar.lessonPacks.put(pack);

      final lesson1 = Lesson()
        ..packId = packId
        ..title = 'What is a Variable?'
        ..order = 1
        ..contentMarkdown = '''
# What is a Variable?

A **variable** is a letter that stands in for a number we do not
know yet, like `x` or `y`.

For example, in the expression:

    x + 3

`x` could be any number. If `x` is 2, the expression equals 5.

## Why do we use variables?

Variables let us write general rules instead of one example at a
time. Instead of saying "2 plus 3 equals 5" and "7 plus 3 equals
10" separately, we can just say:

    x + 3

and plug in any number for `x`.
'''
        ..assetPaths = [];

      final lesson1Id = await isar.lessons.put(lesson1);

      final lesson2 = Lesson()
        ..packId = packId
        ..title = 'Solving Simple Equations'
        ..order = 2
        ..contentMarkdown = '''
# Solving Simple Equations

An equation says two things are equal, like:

    x + 4 = 9

To solve it, find the value of `x` that makes both sides equal.

## Steps

1. Look at what is being added or subtracted from `x`.
2. Do the opposite operation to both sides.

For `x + 4 = 9`, subtract 4 from both sides:

    x + 4 - 4 = 9 - 4
    x = 5

So `x = 5`.
'''
        ..assetPaths = [];

      final lesson2Id = await isar.lessons.put(lesson2);

      final lesson3 = Lesson()
        ..packId = packId
        ..title = 'Practice: Word Problems'
        ..order = 3
        ..contentMarkdown = '''
# Practice: Word Problems

Word problems describe a situation using words instead of just
numbers and symbols.

## Example

"Ali has some marbles. After his friend gives him 6 more, he has
14 marbles in total. How many did he start with?"

We can write this as an equation:

    x + 6 = 14

Solving it the same way as before:

    x + 6 - 6 = 14 - 6
    x = 8

Ali started with 8 marbles.
'''
        ..assetPaths = [];

      final lesson3Id = await isar.lessons.put(lesson3);

      final quiz = Quiz()
        ..lessonId = lesson3Id
        ..questions = [
          Question()
            ..text = 'If x + 5 = 12, what is x?'
            ..type = QuestionType.mcq
            ..options = ['5', '6', '7', '17']
            ..correctAnswer = '7',
          Question()
            ..text = 'A variable can only ever represent the number zero.'
            ..type = QuestionType.trueFalse
            ..options = ['True', 'False']
            ..correctAnswer = 'False',
          Question()
            ..text = 'Fill in the blank: x + 3 = 10, so x = ___'
            ..type = QuestionType.fillBlank
            ..options = []
            ..correctAnswer = '7',
        ];

      final quizId = await isar.quizs.put(quiz);

      lesson3.quizId = quizId;
      await isar.lessons.put(lesson3);

      pack.lessonIds = [lesson1Id, lesson2Id, lesson3Id];
      await isar.lessonPacks.put(pack);
    });
  }
}
