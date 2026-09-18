/// Module: academy / ac1_core
///
///*************************** FILE INFO ****************************///
/// File Name: attendance_record.dart
/// Purpose: Declares `AttendanceRecord` — one student on one day.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:manger_plus/features/academy/ac1_core/domain/enums/attendance_status.dart';

/// One document per student per day (`{date}_{studentId}`), not one per
/// section per day. That shape is what lets a parent query "my child's
/// attendance" with a plain `student_id ==` filter the rules can check — a
/// per-section document holding a map of every student could only be shared
/// all-or-nothing.
class AttendanceRecord {
  final String id;
  final String studentId;
  final String studentName;
  final String sectionId;

  /// `yyyy-MM-dd`. A string rather than a timestamp so "the 5th" is the same
  /// day in every timezone the app runs in.
  final String date;
  final AttendanceStatus status;
  final String teacherId;
  final String note;
  final bool demo;

  const AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.sectionId,
    required this.date,
    required this.status,
    this.studentName = '',
    this.teacherId = '',
    this.note = '',
    this.demo = false,
  });

  static String idFor(String date, String studentId) => '${date}_$studentId';

  DateTime get day => DateTime.tryParse(date) ?? DateTime(1970);
}
