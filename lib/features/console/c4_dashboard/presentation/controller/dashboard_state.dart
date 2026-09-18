/// Module: console / c4_dashboard
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_state.dart
/// Purpose: Declares `DashboardState`, `DashboardPeriod` and `DashboardTab`.
/// Author: Manger Plus team
/// Created: 18/9/2026
///
/// ONE state object, not a sealed family. The dashboard is five live
/// Firestore streams feeding one screen: a `loading` / `loaded` split would
/// mean the whole page blanked every time any one of them ticked. Instead the
/// records start empty and `loading` goes false once the first snapshot of
/// each has landed.
///
/// WHY THE DERIVED VALUES LIVE HERE
/// --------------------------------
/// Every number on the page — the four tiles, the four charts, the table —
/// is a pure function of the raw records plus the filters. Putting those
/// functions on the state (rather than in the widgets) is what keeps the UI
/// a renderer: the widgets read `state.attendanceRate`, they do not know what
/// an [AttendanceStatus] is. It is also what makes the CSV export and the
/// charts agree, because both read the same getter.
library;

import 'package:manger_plus/core/custom/8-custom_filter_app.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/attendance_record.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/section.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/submission.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/attendance_status.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/content_type.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';

/// How far back the dashboard looks.
enum DashboardPeriod {
  days30(30),
  days90(90),
  all(null);

  const DashboardPeriod(this.days);

  final int? days;
}

/// Which records the table below the charts is showing.
enum DashboardTab { results, attendance }

/// Sort keys, shared by the table's columns and [DashboardState]'s
/// comparators so a typo cannot silently disable a column's sort.
const String kSortStudent = 'student';
const String kSortSection = 'section';
const String kSortAssessment = 'assessment';
const String kSortScore = 'score';
const String kSortDate = 'date';
const String kSortStatus = 'status';

/// A pass mark is 50%. One constant so the KPI tile, the score-band chart and
/// the "only below pass" filter cannot drift apart.
const double kPassMark = 50;

class DashboardState {
  const DashboardState({
    this.loading = true,
    this.error,
    this.sections = const <Section>[],
    this.students = const <AppUser>[],
    this.content = const <LearningContent>[],
    this.submissions = const <Submission>[],
    this.attendance = const <AttendanceRecord>[],
    this.sectionKey = kAllChipKey,
    this.period = DashboardPeriod.days30,
    this.query = '',
    this.tab = DashboardTab.results,
    this.showCharts = true,
    this.onlyBelowPass = false,
    this.onlyAbsences = false,
    this.sortKey,
    this.sortAscending = false,
  });

  final bool loading;

  /// The raw stream failure, not a message: turning it into words needs a
  /// [BuildContext] for `AppFailure.from(e).message(context)`, which a cubit
  /// does not have and should not want.
  final Object? error;

  // ── Raw records, already narrowed to what this account may see ──────────
  final List<Section> sections;
  final List<AppUser> students;
  final List<LearningContent> content;
  final List<Submission> submissions;
  final List<AttendanceRecord> attendance;

  // ── Filters ─────────────────────────────────────────────────────────────
  final String sectionKey;
  final DashboardPeriod period;
  final String query;
  final DashboardTab tab;
  final bool showCharts;
  final bool onlyBelowPass;
  final bool onlyAbsences;

  /// The column the table is ordered by, or null for the natural order —
  /// which is newest first, because that is what both underlying queries
  /// already return and re-sorting a fresh snapshot to say the same thing is
  /// work for nothing.
  final String? sortKey;
  final bool sortAscending;

  DashboardState copyWith({
    bool? loading,
    Object? error,
    bool clearError = false,
    List<Section>? sections,
    List<AppUser>? students,
    List<LearningContent>? content,
    List<Submission>? submissions,
    List<AttendanceRecord>? attendance,
    String? sectionKey,
    DashboardPeriod? period,
    String? query,
    DashboardTab? tab,
    bool? showCharts,
    bool? onlyBelowPass,
    bool? onlyAbsences,
    String? sortKey,
    bool clearSort = false,
    bool? sortAscending,
  }) {
    return DashboardState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      sections: sections ?? this.sections,
      students: students ?? this.students,
      content: content ?? this.content,
      submissions: submissions ?? this.submissions,
      attendance: attendance ?? this.attendance,
      sectionKey: sectionKey ?? this.sectionKey,
      period: period ?? this.period,
      query: query ?? this.query,
      tab: tab ?? this.tab,
      showCharts: showCharts ?? this.showCharts,
      onlyBelowPass: onlyBelowPass ?? this.onlyBelowPass,
      onlyAbsences: onlyAbsences ?? this.onlyAbsences,
      sortKey: clearSort ? null : (sortKey ?? this.sortKey),
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  //  FILTER PREDICATES
  // ───────────────────────────────────────────────────────────────────────

  bool get isAllSections => sectionKey == kAllChipKey;

  /// True when a filter OTHER than the section chips is on — what lights the
  /// toolbar's filter button.
  bool get hasActiveFilters =>
      period != DashboardPeriod.days30 || onlyBelowPass || onlyAbsences;

  DateTime? get _since {
    final int? days = period.days;
    if (days == null) return null;
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day).subtract(Duration(days: days));
  }

  bool _inSection(String id) => isAllSections || id == sectionKey;

  bool _inPeriod(DateTime? at) {
    final DateTime? since = _since;
    if (since == null || at == null) return true;
    return !at.isBefore(since);
  }

  /// Section + period only. The table adds the search box and the checkboxes
  /// on top; the CHARTS deliberately do not, so a search for one student does
  /// not redraw the whole center's attendance donut around them.
  List<Submission> get scopedSubmissions => submissions
      .where((Submission x) =>
          _inSection(x.sectionId) && _inPeriod(x.submittedAt))
      .toList();

  List<AttendanceRecord> get scopedAttendance => attendance
      .where((AttendanceRecord x) => _inSection(x.sectionId) && _inPeriod(x.day))
      .toList();

  List<AppUser> get scopedStudents =>
      students.where((AppUser x) => _inSection(x.sectionId)).toList();

  List<LearningContent> get scopedContent => content
      .where((LearningContent x) =>
          isAllSections || x.sectionIds.contains(sectionKey))
      .toList();

  // ───────────────────────────────────────────────────────────────────────
  //  TABLE ROWS — scoped, then searched and narrowed
  // ───────────────────────────────────────────────────────────────────────

  String get _q => query.trim().toLowerCase();

  List<Submission> get resultRows {
    final String q = _q;
    final List<Submission> rows = scopedSubmissions.where((Submission x) {
      if (onlyBelowPass && x.percent >= kPassMark) return false;
      if (q.isEmpty) return true;
      return x.studentName.toLowerCase().contains(q) ||
          x.contentTitle.toLowerCase().contains(q);
    }).toList();

    switch (sortKey) {
      case kSortStudent:
        _sort(rows, (Submission x) => x.studentName.toLowerCase());
      case kSortSection:
        _sort(rows, (Submission x) => sectionTitle(x.sectionId).toLowerCase());
      case kSortAssessment:
        _sort(rows, (Submission x) => x.contentTitle.toLowerCase());
      case kSortScore:
        _sort(rows, (Submission x) => x.percent);
      case kSortDate:
        _sort(rows, (Submission x) => x.submittedAt ?? DateTime(1970));
      default:
        break;
    }
    return rows;
  }

  List<AttendanceRecord> get attendanceRows {
    final String q = _q;
    final List<AttendanceRecord> rows =
        scopedAttendance.where((AttendanceRecord x) {
      if (onlyAbsences && x.status.attended) return false;
      if (q.isEmpty) return true;
      return x.studentName.toLowerCase().contains(q) || x.date.contains(q);
    }).toList();

    switch (sortKey) {
      case kSortStudent:
        _sort(rows, (AttendanceRecord x) => x.studentName.toLowerCase());
      case kSortSection:
        _sort(rows, (AttendanceRecord x) => sectionTitle(x.sectionId).toLowerCase());
      case kSortDate:
        _sort(rows, (AttendanceRecord x) => x.date);
      case kSortStatus:
        _sort(rows, (AttendanceRecord x) => x.status.index);
      default:
        break;
    }
    return rows;
  }

  /// Sorts in place by a [Comparable] the caller pulls off the row, honouring
  /// [sortAscending]. One helper rather than eight comparators, so a column
  /// added later cannot get the direction backwards.
  void _sort<T>(List<T> rows, Comparable<dynamic> Function(T row) by) {
    rows.sort((T a, T b) {
      final int r = by(a).compareTo(by(b));
      return sortAscending ? r : -r;
    });
  }

  int get rowsShown =>
      tab == DashboardTab.results ? resultRows.length : attendanceRows.length;

  int get rowsTotal => tab == DashboardTab.results
      ? scopedSubmissions.length
      : scopedAttendance.length;

  // ───────────────────────────────────────────────────────────────────────
  //  KPI TILES
  // ───────────────────────────────────────────────────────────────────────

  int get studentCount => scopedStudents.length;

  /// Percent of records where the student was in the room, 0 when nothing has
  /// been recorded yet. Null would be truer, but the tile already renders a
  /// dash while [loading] and a second null path buys nothing.
  int get attendanceRate {
    final List<AttendanceRecord> list = scopedAttendance;
    if (list.isEmpty) return 0;
    final int attended =
        list.where((AttendanceRecord x) => x.status.attended).length;
    return (attended / list.length * 100).round();
  }

  int get averageScore {
    final List<Submission> list = scopedSubmissions;
    if (list.isEmpty) return 0;
    final double sum =
        list.fold<double>(0, (double a, Submission b) => a + b.percent);
    return (sum / list.length).round();
  }

  int get publishedContentCount =>
      scopedContent.where((LearningContent x) => x.published).length;

  /// Distinct days a register was taken on, in scope. Cheaper than asking
  /// [attendanceByDay] for every day just to count them.
  int get recordedDays =>
      scopedAttendance.map((AttendanceRecord x) => x.date).toSet().length;

  int get markedCount => scopedSubmissions.length;

  int get belowPassCount =>
      scopedSubmissions.where((Submission x) => x.percent < kPassMark).length;

  // ───────────────────────────────────────────────────────────────────────
  //  CHART SERIES
  // ───────────────────────────────────────────────────────────────────────

  /// present / absent / late / excused counts, in enum order.
  Map<AttendanceStatus, int> get attendanceByStatus => <AttendanceStatus, int>{
        for (final AttendanceStatus a in AttendanceStatus.values)
          a: scopedAttendance
              .where((AttendanceRecord x) => x.status == a)
              .length,
      };

  /// The last [take] recorded school days, oldest first, as
  /// `yyyy-MM-dd -> attendance percent`. Days nobody took a register on do
  /// not appear at all — an empty column would read as "everyone was away".
  Map<String, int> attendanceByDay({int take = 10}) {
    final Map<String, List<AttendanceRecord>> byDay =
        <String, List<AttendanceRecord>>{};
    for (final AttendanceRecord x in scopedAttendance) {
      byDay.putIfAbsent(x.date, () => <AttendanceRecord>[]).add(x);
    }
    final List<String> days = byDay.keys.toList()..sort();
    final List<String> tail =
        days.length <= take ? days : days.sublist(days.length - take);
    return <String, int>{
      for (final String d in tail)
        d: byDay[d]!.isEmpty
            ? 0
            : (byDay[d]!.where((AttendanceRecord x) => x.status.attended).length /
                    byDay[d]!.length *
                    100)
                .round(),
    };
  }

  /// Average percent per section, busiest section first. Sections with no
  /// marked work are left out rather than drawn as a zero bar.
  Map<String, int> get averageBySection {
    final Map<String, List<Submission>> bySection =
        <String, List<Submission>>{};
    for (final Submission x in scopedSubmissions) {
      bySection.putIfAbsent(x.sectionId, () => <Submission>[]).add(x);
    }
    final List<MapEntry<String, List<Submission>>> entries =
        bySection.entries.toList()
          ..sort((MapEntry<String, List<Submission>> a,
                  MapEntry<String, List<Submission>> b) =>
              b.value.length.compareTo(a.value.length));
    return <String, int>{
      for (final MapEntry<String, List<Submission>> e in entries)
        e.key: (e.value.fold<double>(0, (double a, Submission b) => a + b.percent) /
                e.value.length)
            .round(),
    };
  }

  /// Four bands, low to high. The keys are band INDEXES so the labels can be
  /// localized at the call site.
  List<int> get scoreBands {
    final List<int> bands = <int>[0, 0, 0, 0];
    for (final Submission x in scopedSubmissions) {
      final double p = x.percent;
      if (p < 50) {
        bands[0]++;
      } else if (p < 65) {
        bands[1]++;
      } else if (p < 80) {
        bands[2]++;
      } else {
        bands[3]++;
      }
    }
    return bands;
  }

  Map<ContentType, int> get resultsByType => <ContentType, int>{
        for (final ContentType t in <ContentType>[
          ContentType.exam,
          ContentType.quiz,
        ])
          t: scopedSubmissions
              .where((Submission x) => x.contentType == t)
              .length,
      };

  /// True when every series is empty — the page shows one empty state instead
  /// of four blank cards.
  bool get isEmpty => scopedSubmissions.isEmpty && scopedAttendance.isEmpty;

  // ───────────────────────────────────────────────────────────────────────
  //  LOOKUPS
  // ───────────────────────────────────────────────────────────────────────

  String sectionTitle(String id) {
    for (final Section s in sections) {
      if (s.id == id) return s.title;
    }
    return '—';
  }

  /// Student head-count per section id, for the chip row.
  Map<String, int> get studentsPerSection {
    final Map<String, int> counts = <String, int>{};
    for (final Section s in sections) {
      counts[s.id] = students.where((AppUser u) => u.sectionId == s.id).length;
    }
    return counts;
  }
}
