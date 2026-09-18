/// Module: student / s1_home
///
///*************************** FILE INFO ****************************///
/// File Name: learner_cubit.dart
/// Purpose: Declares `LearnerCubit` and `LearnerState` — everything the apps
///          show about ONE student, kept live.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/features/academy/ac1_core/data/repository/academy_repository.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/base_repository/academy_base_repository.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/attendance_record.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/section.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/submission.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/content_type.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';

class LearnerState {
  final bool loading;
  final AppFailure? failure;
  final AppUser learner;
  final List<LearningContent> content;

  /// By content id — "has this exam been taken" is a map lookup.
  final Map<String, Submission> submissions;
  final List<AttendanceRecord> attendance;
  final Section? section;

  const LearnerState({
    required this.learner,
    this.loading = true,
    this.failure,
    this.content = const <LearningContent>[],
    this.submissions = const <String, Submission>{},
    this.attendance = const <AttendanceRecord>[],
    this.section,
  });

  // ── Derived — the home screen's numbers ──────────────────────────────────

  List<LearningContent> ofType(ContentType type) =>
      content.where((LearningContent c) => c.type == type).toList();

  /// Exams and quizzes not taken yet, soonest due first (undated last).
  List<LearningContent> get pendingAssessments {
    final List<LearningContent> list = content
        .where((LearningContent c) => c.type.isAssessment && !submissions.containsKey(c.id))
        .toList();
    final DateTime never = DateTime(9999);
    list.sort((a, b) => (a.dueAt ?? never).compareTo(b.dueAt ?? never));
    return list;
  }

  /// Lessons (video / pdf / image), newest first.
  List<LearningContent> get lessons =>
      content.where((LearningContent c) => c.type.hasFile).toList();

  /// Added in the last seven days.
  int get newThisWeek {
    final DateTime weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return content
        .where((LearningContent c) => c.createdAt != null && c.createdAt!.isAfter(weekAgo))
        .length;
  }

  List<Submission> get results {
    final List<Submission> list = submissions.values.toList();
    final DateTime pending = DateTime(9999);
    list.sort((a, b) => (b.submittedAt ?? pending).compareTo(a.submittedAt ?? pending));
    return list;
  }

  /// Average percentage across results, or null with none.
  double? get average {
    if (submissions.isEmpty) return null;
    return submissions.values.fold<double>(0, (double a, Submission s) => a + s.percent) /
        submissions.length;
  }

  /// Share of recorded days attended (present or late), or null with none.
  double? get attendanceRate {
    if (attendance.isEmpty) return null;
    return attendance.where((AttendanceRecord r) => r.status.attended).length /
        attendance.length *
        100;
  }

  LearnerState copyWith({
    bool? loading,
    AppFailure? failure,
    AppUser? learner,
    List<LearningContent>? content,
    Map<String, Submission>? submissions,
    List<AttendanceRecord>? attendance,
    Section? section,
  }) {
    return LearnerState(
      loading: loading ?? this.loading,
      failure: failure ?? this.failure,
      learner: learner ?? this.learner,
      content: content ?? this.content,
      submissions: submissions ?? this.submissions,
      attendance: attendance ?? this.attendance,
      section: section ?? this.section,
    );
  }
}

/// Used by the student app for the student themself, and by the parent app
/// for whichever child is selected — the same numbers, seen from two sides.
class LearnerCubit extends Cubit<LearnerState> {
  LearnerCubit({
    required AppUser learner,
    ContentBaseRepository? content,
    SubmissionsBaseRepository? submissions,
    AttendanceBaseRepository? attendance,
    SectionsBaseRepository? sections,
  })  : _content = content ?? ContentRepository(),
        _submissions = submissions ?? SubmissionsRepository(),
        _attendance = attendance ?? AttendanceRepository(),
        _sections = sections ?? SectionsRepository(),
        super(LearnerState(learner: learner)) {
    _listen(learner);
  }

  final ContentBaseRepository _content;
  final SubmissionsBaseRepository _submissions;
  final AttendanceBaseRepository _attendance;
  final SectionsBaseRepository _sections;

  final List<StreamSubscription<Object?>> _subs = <StreamSubscription<Object?>>[];

  /// Switches to another learner (the parent picked another child).
  void switchTo(AppUser learner) {
    if (learner.uid == state.learner.uid && learner.sectionId == state.learner.sectionId) {
      return;
    }
    emit(LearnerState(learner: learner));
    _listen(learner);
  }

  void _listen(AppUser learner) {
    for (final StreamSubscription<Object?> s in _subs) {
      s.cancel();
    }
    _subs.clear();

    void fail(Object error) {
      if (!isClosed) emit(state.copyWith(loading: false, failure: AppFailure.from(error)));
    }

    _subs.add(_content.watchForStudent(learner).listen(
      (List<LearningContent> items) {
        if (!isClosed) emit(state.copyWith(loading: false, content: items));
      },
      onError: fail,
    ));
    _subs.add(_submissions.watchForStudent(learner.uid).listen(
      (List<Submission> list) {
        if (!isClosed) {
          emit(state.copyWith(submissions: <String, Submission>{
            for (final Submission s in list) s.contentId: s,
          }));
        }
      },
      onError: fail,
    ));
    _subs.add(_attendance.watchForStudent(learner.uid).listen(
      (List<AttendanceRecord> list) {
        if (!isClosed) emit(state.copyWith(attendance: list));
      },
      onError: fail,
    ));
    _subs.add(_sections.watchAll().listen(
      (List<Section> all) {
        final Iterable<Section> match =
            all.where((Section s) => s.id == learner.sectionId);
        if (!isClosed && match.isNotEmpty) emit(state.copyWith(section: match.first));
      },
      onError: (Object _) {},
    ));
  }

  @override
  Future<void> close() {
    for (final StreamSubscription<Object?> s in _subs) {
      s.cancel();
    }
    return super.close();
  }
}
