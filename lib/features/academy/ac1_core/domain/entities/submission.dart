/// Module: academy / ac1_core
///
///*************************** FILE INFO ****************************///
/// File Name: submission.dart
/// Purpose: Declares `Submission` — a student's result on an exam or quiz.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:manger_plus/features/academy/ac1_core/domain/enums/content_type.dart';

/// One per student per assessment: the id is `{contentId}_{studentId}`, so a
/// second attempt is an overwrite the rules refuse, not a second row.
///
/// Also the GRADE record. The teacher can override [score] and add
/// [feedback]; a grade for work done on paper is a submission the teacher
/// creates with no [answers].
class Submission {
  final String id;
  final String contentId;
  final String contentTitle;
  final ContentType contentType;
  final String teacherId;
  final String studentId;
  final String studentName;
  final String sectionId;

  /// Chosen option index per question; -1 = left blank.
  final List<int> answers;
  final double score;
  final double total;

  /// 'auto' when the app marked it, 'teacher' once a teacher set the score.
  final String gradedBy;
  final String feedback;
  final bool demo;
  final DateTime? submittedAt;

  const Submission({
    required this.id,
    required this.contentId,
    required this.studentId,
    required this.score,
    required this.total,
    this.contentTitle = '',
    this.contentType = ContentType.exam,
    this.teacherId = '',
    this.studentName = '',
    this.sectionId = '',
    this.answers = const <int>[],
    this.gradedBy = 'auto',
    this.feedback = '',
    this.demo = false,
    this.submittedAt,
  });

  static String idFor(String contentId, String studentId) =>
      '${contentId}_$studentId';

  /// 0–100.
  double get percent => total <= 0 ? 0 : (score / total * 100).clamp(0.0, 100.0);

  bool get gradedByTeacher => gradedBy == 'teacher';

  Submission copyWith({double? score, String? feedback, String? gradedBy}) {
    return Submission(
      id: id,
      contentId: contentId,
      contentTitle: contentTitle,
      contentType: contentType,
      teacherId: teacherId,
      studentId: studentId,
      studentName: studentName,
      sectionId: sectionId,
      answers: answers,
      score: score ?? this.score,
      total: total,
      gradedBy: gradedBy ?? this.gradedBy,
      feedback: feedback ?? this.feedback,
      demo: demo,
      submittedAt: submittedAt,
    );
  }
}
