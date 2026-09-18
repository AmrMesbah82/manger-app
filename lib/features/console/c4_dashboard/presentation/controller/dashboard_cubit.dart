/// Module: console / c4_dashboard
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_cubit.dart
/// Purpose: Declares `DashboardCubit` — every Firestore read the dashboard
///          makes, and every filter it holds.
/// Author: Manger Plus team
/// Created: 18/9/2026
///
/// WHY A CUBIT AND NOT FIVE StreamBuilders
/// ---------------------------------------
/// The list pages in this app each watch ONE collection, so a `StreamBuilder`
/// in the widget is the right size. The dashboard cross-references five —
/// sections, students, content, submissions, attendance — and every tile and
/// chart is a function of more than one of them. Nested StreamBuilders would
/// rebuild the whole page five times per tick and put the arithmetic in the
/// widget tree. So the streams are subscribed once here, merged into a single
/// [DashboardState], and the widgets render it.
///
/// WHAT EACH ROLE SEES
/// -------------------
/// `firestore.rules` lets any STAFF member read the `submissions` and
/// `attendance` collections whole, so both roles use the same queries; the
/// narrowing to a teacher's own sections happens in Dart, in [_scope]. That
/// is deliberate — a `whereIn` on section ids caps at 30, and a teacher with
/// more sections than that would silently lose rows rather than fail loudly.
///
/// Content and students ARE queried per-teacher, because those queries exist
/// already and are cheaper than reading the whole center.
library;

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:manger_plus/features/academy/ac1_core/data/repository/academy_repository.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/attendance_record.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/section.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/submission.dart';
import 'package:manger_plus/features/console/c4_dashboard/presentation/controller/dashboard_state.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/data/repository/auth_repository.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/user_role.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required AppUser user,
    SectionsRepository? sections,
    ContentRepository? content,
    SubmissionsRepository? submissions,
    AttendanceRepository? attendance,
    UsersRepository? users,
  })  : _user = user,
        _sections = sections ?? SectionsRepository(),
        _content = content ?? ContentRepository(),
        _submissions = submissions ?? SubmissionsRepository(),
        _attendance = attendance ?? AttendanceRepository(),
        _users = users ?? UsersRepository(),
        super(const DashboardState());

  final AppUser _user;
  final SectionsRepository _sections;
  final ContentRepository _content;
  final SubmissionsRepository _submissions;
  final AttendanceRepository _attendance;
  final UsersRepository _users;

  final List<StreamSubscription<dynamic>> _subs = <StreamSubscription<dynamic>>[];

  /// One bit per stream. Loading ends when all five have delivered once —
  /// otherwise the page would flash a populated-looking zero state built from
  /// whichever stream happened to answer first.
  final Set<int> _arrived = <int>{};
  static const int _streamCount = 5;

  bool get _isAdmin => _user.role == UserRole.admin;

  /// A teacher's own sections. Empty for an admin, who sees everything.
  Set<String> get _mySections => _user.sectionIds.toSet();

  // Guard against emit-after-close: the admin can switch a permission off
  // while a snapshot is in flight, which closes this cubit mid-await.
  @override
  void emit(DashboardState state) {
    if (isClosed) return;
    super.emit(state);
  }

  void start() {
    if (_subs.isNotEmpty) return;

    _listen<List<Section>>(
      0,
      _sections.watchAll(),
      (List<Section> v) => state.copyWith(
        sections: _isAdmin
            ? v
            : v.where((Section s) => _mySections.contains(s.id)).toList(),
      ),
    );

    _listen<List<AppUser>>(
      1,
      _isAdmin
          ? _users.watchByRole(UserRole.student)
          : _users.watchStudentsIn(_user.sectionIds),
      (List<AppUser> v) => state.copyWith(students: v),
    );

    _listen<List<LearningContent>>(
      2,
      _isAdmin ? _content.watchAll() : _content.watchByTeacher(_user.uid),
      (List<LearningContent> v) => state.copyWith(content: v),
    );

    _listen<List<Submission>>(
      3,
      _isAdmin ? _submissions.watchAll() : _submissions.watchForTeacher(_user.uid),
      (List<Submission> v) => state.copyWith(submissions: v),
    );

    // No per-teacher query exists for attendance, and a `whereIn` would cap
    // at 30 sections — so read the collection and narrow here.
    _listen<List<AttendanceRecord>>(
      4,
      _attendance.watchAll(),
      (List<AttendanceRecord> v) => state.copyWith(
        attendance: _isAdmin
            ? v
            : v
                .where((AttendanceRecord r) => _mySections.contains(r.sectionId))
                .toList(),
      ),
    );
  }

  void _listen<T>(
    int slot,
    Stream<T> stream,
    DashboardState Function(T value) fold,
  ) {
    _subs.add(stream.listen(
      (T value) {
        _arrived.add(slot);
        emit(fold(value).copyWith(
          loading: _arrived.length < _streamCount,
          clearError: true,
        ));
      },
      onError: (Object e) {
        _arrived.add(slot);
        emit(state.copyWith(
          loading: _arrived.length < _streamCount,
          error: e,
        ));
      },
    ));
  }

  // ── Filters ─────────────────────────────────────────────────────────────

  void selectSection(String key) {
    if (key != state.sectionKey) emit(state.copyWith(sectionKey: key));
  }

  void search(String query) => emit(state.copyWith(query: query));

  void selectTab(DashboardTab tab) {
    // The sort is cleared with the tab: 'assessment' means nothing to the
    // attendance table, and a key it cannot honour would leave a sorted
    // header pointing at a column that is not there.
    if (tab != state.tab) emit(state.copyWith(tab: tab, clearSort: true));
  }

  /// Tapping the sorted column again flips the direction; tapping a new one
  /// starts it descending, because every column here — score, date, status —
  /// is one whose interesting end is the top.
  void sort(String key) {
    if (state.sortKey == key) {
      emit(state.copyWith(sortAscending: !state.sortAscending));
    } else {
      emit(state.copyWith(sortKey: key, sortAscending: false));
    }
  }

  void selectPeriod(DashboardPeriod period) =>
      emit(state.copyWith(period: period));

  void toggleCharts(bool value) => emit(state.copyWith(showCharts: value));

  void toggleOnlyBelowPass(bool value) =>
      emit(state.copyWith(onlyBelowPass: value));

  void toggleOnlyAbsences(bool value) =>
      emit(state.copyWith(onlyAbsences: value));

  /// Resets everything the filter dialog owns. The section chips and the
  /// search box are NOT reset — they are visible controls the user can see
  /// the state of, so clearing them from inside a dialog would be a surprise.
  void clearFilters() => emit(state.copyWith(
        period: DashboardPeriod.days30,
        onlyBelowPass: false,
        onlyAbsences: false,
      ));

  @override
  Future<void> close() async {
    for (final StreamSubscription<dynamic> s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    return super.close();
  }
}
