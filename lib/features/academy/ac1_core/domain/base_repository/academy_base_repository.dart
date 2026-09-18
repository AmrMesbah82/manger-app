/// Module: academy / ac1_core
///
///*************************** FILE INFO ****************************///
/// File Name: academy_base_repository.dart
/// Purpose: Declares the contracts for sections, content, submissions and
///          attendance.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/attendance_record.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/section.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/submission.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';

abstract class SectionsBaseRepository {
  Stream<List<Section>> watchAll();

  Future<Either<AppFailure, String>> save(Section section);

  Future<Either<AppFailure, Unit>> delete(String id);
}

/// A file the teacher picked, ready to upload. Exactly one of [path] (mobile
/// and desktop) or [bytes] (web) is set.
class PickedUpload {
  final String name;
  final String? path;
  final Uint8List? bytes;
  final int size;

  const PickedUpload({
    required this.name,
    required this.size,
    this.path,
    this.bytes,
  });
}

/// Where an uploaded file ended up.
class UploadedFile {
  final String url;
  final String storagePath;
  final String fileName;

  const UploadedFile({
    required this.url,
    required this.storagePath,
    required this.fileName,
  });
}

abstract class ContentBaseRepository {
  /// Everything — admin console.
  Stream<List<LearningContent>> watchAll();

  /// What one teacher made.
  Stream<List<LearningContent>> watchByTeacher(String teacherId);

  /// Published items assigned to [student] (by section or by name).
  Stream<List<LearningContent>> watchForStudent(AppUser student);

  Future<Either<AppFailure, LearningContent>> fetch(String id);

  /// Creates when `id` is empty, updates otherwise. Returns the id.
  Future<Either<AppFailure, String>> save(LearningContent content);

  /// Deletes the document and, when there is one, its file in Storage.
  Future<Either<AppFailure, Unit>> delete(LearningContent content);

  /// Uploads to `content/{teacherId}/…`. [onProgress] gets 0–1.
  Future<Either<AppFailure, UploadedFile>> upload({
    required String teacherId,
    required PickedUpload file,
    void Function(double progress)? onProgress,
  });
}

abstract class SubmissionsBaseRepository {
  Stream<List<Submission>> watchForContent(String contentId);

  Stream<List<Submission>> watchForStudent(String studentId);

  Stream<List<Submission>> watchForTeacher(String teacherId);

  /// Every result in the center — staff only.
  Stream<List<Submission>> watchAll();

  Future<Submission?> fetchMine(String contentId, String studentId);

  Future<Either<AppFailure, Unit>> submit(Submission submission);

  Future<Either<AppFailure, Unit>> grade({
    required String submissionId,
    required double score,
    required String feedback,
  });

  /// A grade for work done on paper — a submission with no answers.
  Future<Either<AppFailure, Unit>> recordManualGrade(Submission submission);
}

abstract class AttendanceBaseRepository {
  Stream<List<AttendanceRecord>> watchSectionDay(String sectionId, String date);

  Stream<List<AttendanceRecord>> watchForStudent(String studentId);

  /// Every attendance record — staff only.
  Stream<List<AttendanceRecord>> watchAll();

  /// Writes one record per student in a single batch.
  Future<Either<AppFailure, Unit>> saveDay(List<AttendanceRecord> records);
}
