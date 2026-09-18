/// Module: academy / ac1_core
///
///*************************** FILE INFO ****************************///
/// File Name: progress_remote_data_source.dart
/// Purpose: Declares `SubmissionsRemoteDataSource` and
///          `AttendanceRemoteDataSource` — a student's progress records.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:manger_plus/core/constants/firebase_collections.dart';
import 'package:manger_plus/core/network/app_firebase.dart';
import 'package:manger_plus/features/academy/ac1_core/data/models/academy_models.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/attendance_record.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/submission.dart';

class SubmissionsRemoteDataSource {
  CollectionReference<Map<String, dynamic>> get _subs =>
      AppFirebase.db.collection(FirebaseCollections.submissions);

  Stream<List<Submission>> watchForContent(String contentId) => _subs
      .where(FirebaseCollections.contentIdField, isEqualTo: contentId)
      .snapshots()
      .map((snap) => _sorted(snap.docs));

  /// The query a student and a parent both use — `student_id ==` is the shape
  /// firestore.rules can check for each of them.
  Stream<List<Submission>> watchForStudent(String studentId) => _subs
      .where(FirebaseCollections.studentIdField, isEqualTo: studentId)
      .snapshots()
      .map((snap) => _sorted(snap.docs));

  Stream<List<Submission>> watchForTeacher(String teacherId) => _subs
      .where(FirebaseCollections.teacherIdField, isEqualTo: teacherId)
      .snapshots()
      .map((snap) => _sorted(snap.docs));

  /// EVERY result in the center — the admin dashboard's series.
  ///
  /// `firestore.rules` allows a collection read of `submissions` to staff, so
  /// this is a legal query for an admin AND for a teacher; the dashboard
  /// narrows a teacher's view to their own sections in Dart rather than in
  /// the query, because a teacher may hold more than the 30 section ids a
  /// `whereIn` would allow.
  Stream<List<Submission>> watchAll() =>
      _subs.snapshots().map((snap) => _sorted(snap.docs));

  Future<Submission?> fetch(String id) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _subs.doc(id).get();
    if (!doc.exists) return null;
    return SubmissionModel.fromDoc(doc);
  }

  /// `set` on a fixed id — the rules allow create but not overwrite for a
  /// student, so a second attempt fails instead of replacing the first.
  Future<void> submit(Submission submission) =>
      _subs.doc(submission.id).set(SubmissionModel.toMap(submission));

  Future<void> grade(String id, double score, String feedback) =>
      _subs.doc(id).update(SubmissionModel.toGradeMap(score, feedback));

  /// Teacher-created grade — may overwrite an existing row.
  Future<void> recordManual(Submission submission) => _subs
      .doc(submission.id)
      .set(SubmissionModel.toMap(submission), SetOptions(merge: true));

  List<Submission> _sorted(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final DateTime pending = DateTime(9999);
    return docs.map(SubmissionModel.fromDoc).toList()
      ..sort((a, b) =>
          (b.submittedAt ?? pending).compareTo(a.submittedAt ?? pending));
  }
}

class AttendanceRemoteDataSource {
  CollectionReference<Map<String, dynamic>> get _attendance =>
      AppFirebase.db.collection(FirebaseCollections.attendance);

  Stream<List<AttendanceRecord>> watchSectionDay(String sectionId, String date) =>
      _attendance
          .where(FirebaseCollections.sectionIdField, isEqualTo: sectionId)
          .where(FirebaseCollections.dateField, isEqualTo: date)
          .snapshots()
          .map((snap) => snap.docs.map(AttendanceModel.fromDoc).toList());

  Stream<List<AttendanceRecord>> watchForStudent(String studentId) => _attendance
      .where(FirebaseCollections.studentIdField, isEqualTo: studentId)
      .snapshots()
      .map((snap) => snap.docs.map(AttendanceModel.fromDoc).toList()
        ..sort((a, b) => b.date.compareTo(a.date)));

  /// EVERY attendance record — the admin dashboard's series. Staff-readable,
  /// same as [SubmissionsRemoteDataSource.watchAll].
  Stream<List<AttendanceRecord>> watchAll() => _attendance.snapshots().map(
        (snap) => snap.docs.map(AttendanceModel.fromDoc).toList()
          ..sort((a, b) => b.date.compareTo(a.date)),
      );

  /// One batch for the whole class: either the day is saved or nothing is.
  /// Firestore batches hold 500 writes — far more than a section.
  Future<void> saveDay(List<AttendanceRecord> records) async {
    final WriteBatch batch = AppFirebase.db.batch();
    for (final AttendanceRecord r in records) {
      batch.set(_attendance.doc(r.id), AttendanceModel.toMap(r));
    }
    await batch.commit();
  }
}
