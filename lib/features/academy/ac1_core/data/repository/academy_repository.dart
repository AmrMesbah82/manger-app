/// Module: academy / ac1_core
///
///*************************** FILE INFO ****************************///
/// File Name: academy_repository.dart
/// Purpose: Declares `SectionsRepository`, `ContentRepository`,
///          `SubmissionsRepository` and `AttendanceRepository`.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:dartz/dartz.dart';

import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/core/network/guard.dart';
import 'package:manger_plus/features/academy/ac1_core/data/data_source/remote_data_source/content_remote_data_source.dart';
import 'package:manger_plus/features/academy/ac1_core/data/data_source/remote_data_source/progress_remote_data_source.dart';
import 'package:manger_plus/features/academy/ac1_core/data/data_source/remote_data_source/sections_remote_data_source.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/base_repository/academy_base_repository.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/attendance_record.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/section.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/submission.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';

class SectionsRepository implements SectionsBaseRepository {
  SectionsRepository({SectionsRemoteDataSource? remote})
      : _remote = remote ?? SectionsRemoteDataSource();

  final SectionsRemoteDataSource _remote;

  @override
  Stream<List<Section>> watchAll() => _remote.watchAll();

  @override
  Future<Either<AppFailure, String>> save(Section section) =>
      guard(() => _remote.save(section));

  @override
  Future<Either<AppFailure, Unit>> delete(String id) =>
      guardUnit(() => _remote.delete(id));
}

class ContentRepository implements ContentBaseRepository {
  ContentRepository({ContentRemoteDataSource? remote})
      : _remote = remote ?? ContentRemoteDataSource();

  final ContentRemoteDataSource _remote;

  @override
  Stream<List<LearningContent>> watchAll() => _remote.watchAll();

  @override
  Stream<List<LearningContent>> watchByTeacher(String teacherId) =>
      _remote.watchByTeacher(teacherId);

  @override
  Stream<List<LearningContent>> watchForStudent(AppUser student) =>
      _remote.watchForStudent(student);

  @override
  Future<Either<AppFailure, LearningContent>> fetch(String id) =>
      guard(() async {
        final LearningContent? content = await _remote.fetch(id);
        if (content == null) throw StateError('not-found');
        return content;
      }).then((Either<AppFailure, LearningContent> r) => r.fold(
            (AppFailure f) => Left<AppFailure, LearningContent>(
                f == AppFailure.unknown ? AppFailure.notFound : f),
            (LearningContent c) => Right<AppFailure, LearningContent>(c),
          ));

  @override
  Future<Either<AppFailure, String>> save(LearningContent content) =>
      guard(() => _remote.save(content));

  @override
  Future<Either<AppFailure, Unit>> delete(LearningContent content) =>
      guardUnit(() => _remote.delete(content));

  @override
  Future<Either<AppFailure, UploadedFile>> upload({
    required String teacherId,
    required PickedUpload file,
    void Function(double progress)? onProgress,
  }) =>
      guard(() => _remote.upload(
            teacherId: teacherId,
            file: file,
            onProgress: onProgress,
          ));
}

class SubmissionsRepository implements SubmissionsBaseRepository {
  SubmissionsRepository({SubmissionsRemoteDataSource? remote})
      : _remote = remote ?? SubmissionsRemoteDataSource();

  final SubmissionsRemoteDataSource _remote;

  @override
  Stream<List<Submission>> watchForContent(String contentId) =>
      _remote.watchForContent(contentId);

  @override
  Stream<List<Submission>> watchForStudent(String studentId) =>
      _remote.watchForStudent(studentId);

  @override
  Stream<List<Submission>> watchForTeacher(String teacherId) =>
      _remote.watchForTeacher(teacherId);

  @override
  Stream<List<Submission>> watchAll() => _remote.watchAll();

  @override
  Future<Submission?> fetchMine(String contentId, String studentId) async {
    try {
      return await _remote.fetch(Submission.idFor(contentId, studentId));
    } catch (_) {
      // The rules refuse a GET on a document that does not exist yet when
      // they read its fields — "no permission" here means "not submitted".
      return null;
    }
  }

  @override
  Future<Either<AppFailure, Unit>> submit(Submission submission) =>
      guardUnit(() => _remote.submit(submission));

  @override
  Future<Either<AppFailure, Unit>> grade({
    required String submissionId,
    required double score,
    required String feedback,
  }) =>
      guardUnit(() => _remote.grade(submissionId, score, feedback));

  @override
  Future<Either<AppFailure, Unit>> recordManualGrade(Submission submission) =>
      guardUnit(() => _remote.recordManual(submission));
}

class AttendanceRepository implements AttendanceBaseRepository {
  AttendanceRepository({AttendanceRemoteDataSource? remote})
      : _remote = remote ?? AttendanceRemoteDataSource();

  final AttendanceRemoteDataSource _remote;

  @override
  Stream<List<AttendanceRecord>> watchSectionDay(String sectionId, String date) =>
      _remote.watchSectionDay(sectionId, date);

  @override
  Stream<List<AttendanceRecord>> watchForStudent(String studentId) =>
      _remote.watchForStudent(studentId);

  @override
  Stream<List<AttendanceRecord>> watchAll() => _remote.watchAll();

  @override
  Future<Either<AppFailure, Unit>> saveDay(List<AttendanceRecord> records) =>
      guardUnit(() => _remote.saveDay(records));
}
