/// Module: academy / ac1_core
///
///*************************** FILE INFO ****************************///
/// File Name: academy_utils.dart
/// Purpose: Declares `DateKey` and `ExamGrader` — small pure helpers.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';

/// `yyyy-MM-dd` keys for attendance. Built by hand rather than with intl so
/// the digits are always Latin — an Arabic-locale DateFormat writes Eastern
/// Arabic numerals, and then the same day has two different keys.
abstract final class DateKey {
  const DateKey._();

  static String of(DateTime date) {
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  static String get today => of(DateTime.now());
}

/// Marks a set of answers against an exam's key. Pure and static so it can be
/// tested without widgets, and so the score shown on the result screen is the
/// same arithmetic that was saved.
abstract final class ExamGrader {
  const ExamGrader._();

  static double score(LearningContent exam, List<int> answers) {
    double total = 0;
    for (int i = 0; i < exam.questions.length; i++) {
      final Question q = exam.questions[i];
      if (i < answers.length && answers[i] == q.correctIndex) total += q.points;
    }
    return total;
  }

  static int correctCount(LearningContent exam, List<int> answers) {
    int count = 0;
    for (int i = 0; i < exam.questions.length; i++) {
      if (i < answers.length && answers[i] == exam.questions[i].correctIndex) {
        count++;
      }
    }
    return count;
  }
}
