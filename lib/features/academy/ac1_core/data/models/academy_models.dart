/// Module: academy / ac1_core
///
///*************************** FILE INFO ****************************///
/// File Name: academy_models.dart
/// Purpose: Declares `SectionModel`, `ContentModel`, `SubmissionModel` and
///          `AttendanceModel` — Firestore <-> entity mapping.
/// Author: Manger Plus team
/// Created: 18/9/2026
///
/// Field names here MUST match `onlyKeys` / field checks in firestore.rules.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:manger_plus/core/constants/firebase_collections.dart';
import 'package:manger_plus/core/helper/main_helper/firestore_mapper.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/attendance_record.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/section.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/submission.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/attendance_status.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/content_type.dart';

// ── Sections ────────────────────────────────────────────────────────────────

abstract final class SectionModel {
  const SectionModel._();

  static Section fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.safeData;
    return Section(
      id: doc.id,
      name: data.str('name'),
      level: data.str('level'),
      description: data.str('description'),
      demo: data.boolean(FirebaseCollections.demoField),
      createdAt: data.date(FirebaseCollections.createdAtField),
    );
  }

  static Map<String, dynamic> toMap(Section section, {bool isCreate = false}) =>
      <String, dynamic>{
        'name': section.name.trim(),
        'level': section.level.trim(),
        'description': section.description.trim(),
        FirebaseCollections.demoField: section.demo,
        if (isCreate)
          FirebaseCollections.createdAtField: FieldValue.serverTimestamp(),
        FirebaseCollections.updatedAtField: FieldValue.serverTimestamp(),
      };
}

// ── Content ─────────────────────────────────────────────────────────────────

abstract final class ContentModel {
  const ContentModel._();

  static LearningContent fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.safeData;
    final List<dynamic> rawQuestions =
        (data['questions'] as List<dynamic>?) ?? const <dynamic>[];

    return LearningContent(
      id: doc.id,
      type: ContentType.fromKey(data.str(FirebaseCollections.typeField)),
      title: data.str('title'),
      description: data.str('description'),
      subject: data.str('subject'),
      teacherId: data.str(FirebaseCollections.teacherIdField),
      teacherName: data.str('teacher_name'),
      fileUrl: data.str('file_url'),
      storagePath: data.str('storage_path'),
      fileName: data.str('file_name'),
      questions: rawQuestions
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> m) =>
              _questionFrom(Map<String, dynamic>.from(m)))
          .toList(),
      durationMinutes: data.integer('duration_minutes'),
      sectionIds: data.stringList(FirebaseCollections.sectionIdsField),
      studentIds: data.stringList(FirebaseCollections.studentIdsField),
      dueAt: data.date('due_at'),
      published: data.boolean('published', true),
      demo: data.boolean(FirebaseCollections.demoField),
      createdAt: data.date(FirebaseCollections.createdAtField),
      updatedAt: data.date(FirebaseCollections.updatedAtField),
    );
  }

  static Map<String, dynamic> toMap(LearningContent c, {bool isCreate = false}) =>
      <String, dynamic>{
        FirebaseCollections.typeField: c.type.key,
        'title': c.title.trim(),
        'description': c.description.trim(),
        'subject': c.subject.trim(),
        FirebaseCollections.teacherIdField: c.teacherId,
        'teacher_name': c.teacherName,
        'file_url': c.fileUrl,
        'storage_path': c.storagePath,
        'file_name': c.fileName,
        'questions': c.questions.map(_questionTo).toList(),
        'duration_minutes': c.durationMinutes,
        FirebaseCollections.sectionIdsField: c.sectionIds,
        FirebaseCollections.studentIdsField: c.studentIds,
        'due_at': c.dueAt == null ? null : Timestamp.fromDate(c.dueAt!),
        'published': c.published,
        FirebaseCollections.demoField: c.demo,
        if (isCreate)
          FirebaseCollections.createdAtField: FieldValue.serverTimestamp(),
        FirebaseCollections.updatedAtField: FieldValue.serverTimestamp(),
      };

  static Question _questionFrom(Map<String, dynamic> m) => Question(
        text: m.str('text'),
        options: m.stringList('options'),
        correctIndex: m.integer('correct_index'),
        points: m.decimal('points', 1),
      );

  static Map<String, dynamic> _questionTo(Question q) => <String, dynamic>{
        'text': q.text.trim(),
        'options': q.options.map((String o) => o.trim()).toList(),
        'correct_index': q.correctIndex,
        'points': q.points,
      };
}

// ── Submissions ─────────────────────────────────────────────────────────────

abstract final class SubmissionModel {
  const SubmissionModel._();

  static Submission fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.safeData;
    final List<dynamic> raw = (data['answers'] as List<dynamic>?) ?? const <dynamic>[];
    return Submission(
      id: doc.id,
      contentId: data.str(FirebaseCollections.contentIdField),
      contentTitle: data.str('content_title'),
      contentType: ContentType.fromKey(data.str('content_type')),
      teacherId: data.str(FirebaseCollections.teacherIdField),
      studentId: data.str(FirebaseCollections.studentIdField),
      studentName: data.str('student_name'),
      sectionId: data.str(FirebaseCollections.sectionIdField),
      answers: raw.map((dynamic e) => e is num ? e.toInt() : -1).toList(),
      score: data.decimal('score'),
      total: data.decimal('total'),
      gradedBy: data.str('graded_by', 'auto'),
      feedback: data.str('feedback'),
      demo: data.boolean(FirebaseCollections.demoField),
      submittedAt: data.date('submitted_at'),
    );
  }

  static Map<String, dynamic> toMap(Submission s) => <String, dynamic>{
        FirebaseCollections.contentIdField: s.contentId,
        'content_title': s.contentTitle,
        'content_type': s.contentType.key,
        FirebaseCollections.teacherIdField: s.teacherId,
        FirebaseCollections.studentIdField: s.studentId,
        'student_name': s.studentName,
        FirebaseCollections.sectionIdField: s.sectionId,
        'answers': s.answers,
        'score': s.score,
        'total': s.total,
        'graded_by': s.gradedBy,
        'feedback': s.feedback,
        FirebaseCollections.demoField: s.demo,
        'submitted_at': s.submittedAt == null
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(s.submittedAt!),
      };

  /// What a teacher changes when grading — nothing else moves.
  static Map<String, dynamic> toGradeMap(double score, String feedback) =>
      <String, dynamic>{
        'score': score,
        'feedback': feedback.trim(),
        'graded_by': 'teacher',
        FirebaseCollections.updatedAtField: FieldValue.serverTimestamp(),
      };
}

// ── Attendance ──────────────────────────────────────────────────────────────

abstract final class AttendanceModel {
  const AttendanceModel._();

  static AttendanceRecord fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.safeData;
    return AttendanceRecord(
      id: doc.id,
      studentId: data.str(FirebaseCollections.studentIdField),
      studentName: data.str('student_name'),
      sectionId: data.str(FirebaseCollections.sectionIdField),
      date: data.str(FirebaseCollections.dateField),
      status: AttendanceStatus.fromKey(data.str('status')),
      teacherId: data.str(FirebaseCollections.teacherIdField),
      note: data.str('note'),
      demo: data.boolean(FirebaseCollections.demoField),
    );
  }

  static Map<String, dynamic> toMap(AttendanceRecord r) => <String, dynamic>{
        FirebaseCollections.studentIdField: r.studentId,
        'student_name': r.studentName,
        FirebaseCollections.sectionIdField: r.sectionId,
        FirebaseCollections.dateField: r.date,
        'status': r.status.key,
        FirebaseCollections.teacherIdField: r.teacherId,
        'note': r.note,
        FirebaseCollections.demoField: r.demo,
        FirebaseCollections.updatedAtField: FieldValue.serverTimestamp(),
      };
}
