/// Module: academy / ac1_core
///
///*************************** FILE INFO ****************************///
/// File Name: learning_content.dart
/// Purpose: Declares `LearningContent` and `Question`.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:manger_plus/features/academy/ac1_core/domain/enums/content_type.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';

/// One multiple-choice question on an exam or quiz.
class Question {
  final String text;
  final List<String> options;

  /// Index into [options].
  final int correctIndex;
  final double points;

  const Question({
    required this.text,
    required this.options,
    required this.correctIndex,
    this.points = 1,
  });

  bool get isValid =>
      text.trim().isNotEmpty &&
      options.where((o) => o.trim().isNotEmpty).length >= 2 &&
      correctIndex >= 0 &&
      correctIndex < options.length &&
      options[correctIndex].trim().isNotEmpty;

  Question copyWith({
    String? text,
    List<String>? options,
    int? correctIndex,
    double? points,
  }) {
    return Question(
      text: text ?? this.text,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
      points: points ?? this.points,
    );
  }

  static const Question blank = Question(
    text: '',
    options: <String>['', '', '', ''],
    correctIndex: 0,
  );
}

/// A video, PDF, image, exam or quiz, and who it is assigned to.
///
/// ASSIGNMENT is two lists: whole [sectionIds] and single [studentIds]. A
/// student sees an item when either list names them. Both are arrays on the
/// document so the student's two queries are plain `array-contains` lookups.
class LearningContent {
  final String id;
  final ContentType type;
  final String title;
  final String description;
  final String subject;

  // ── Who made it ──────────────────────────────────────────────────────────
  final String teacherId;
  final String teacherName;

  // ── File (video / pdf / image) ───────────────────────────────────────────
  /// Download URL — from Firebase Storage, or an external link.
  final String fileUrl;

  /// Where the file sits in Storage, so deleting the item deletes the file.
  /// Empty for external links.
  final String storagePath;
  final String fileName;

  // ── Assessment (exam / quiz) ─────────────────────────────────────────────
  final List<Question> questions;

  /// Time limit. 0 = untimed.
  final int durationMinutes;

  // ── Assignment ───────────────────────────────────────────────────────────
  final List<String> sectionIds;
  final List<String> studentIds;
  final DateTime? dueAt;

  /// Draft (false) items are only visible in the console.
  final bool published;

  final bool demo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LearningContent({
    required this.id,
    required this.type,
    required this.title,
    required this.teacherId,
    this.description = '',
    this.subject = '',
    this.teacherName = '',
    this.fileUrl = '',
    this.storagePath = '',
    this.fileName = '',
    this.questions = const <Question>[],
    this.durationMinutes = 0,
    this.sectionIds = const <String>[],
    this.studentIds = const <String>[],
    this.dueAt,
    this.published = true,
    this.demo = false,
    this.createdAt,
    this.updatedAt,
  });

  double get totalPoints =>
      questions.fold<double>(0, (double sum, Question q) => sum + q.points);

  bool get isAssigned => sectionIds.isNotEmpty || studentIds.isNotEmpty;

  bool isAssignedTo(AppUser student) =>
      studentIds.contains(student.uid) ||
      (student.sectionId.isNotEmpty && sectionIds.contains(student.sectionId));

  bool get isOverdue =>
      dueAt != null && DateTime.now().isAfter(dueAt!);

  LearningContent copyWith({
    String? id,
    ContentType? type,
    String? title,
    String? description,
    String? subject,
    String? teacherId,
    String? teacherName,
    String? fileUrl,
    String? storagePath,
    String? fileName,
    List<Question>? questions,
    int? durationMinutes,
    List<String>? sectionIds,
    List<String>? studentIds,
    DateTime? dueAt,
    bool clearDueAt = false,
    bool? published,
  }) {
    return LearningContent(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      fileUrl: fileUrl ?? this.fileUrl,
      storagePath: storagePath ?? this.storagePath,
      fileName: fileName ?? this.fileName,
      questions: questions ?? this.questions,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      sectionIds: sectionIds ?? this.sectionIds,
      studentIds: studentIds ?? this.studentIds,
      dueAt: clearDueAt ? null : (dueAt ?? this.dueAt),
      published: published ?? this.published,
      demo: demo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
