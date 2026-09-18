/// Module: console / c4_dashboard
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_table_section.dart
/// Purpose: Declares `DashboardTableSection` — the records under the charts.
/// Author: Manger Plus team
/// Created: 18/9/2026
///
/// Two tabs over one table. `10-custom_tabs` draws the switch and
/// `100-custom_data_table` draws the rows, so this file only decides what a
/// column is.
///
/// The charts answer "how is the center doing"; this answers "which record
/// are you looking for". That is why the search box and the two narrowing
/// switches reach the table but not the charts — see [DashboardState].
library;

import 'package:flutter/material.dart';

import 'package:manger_plus/core/custom/10-custom_tabs.dart';
import 'package:manger_plus/core/custom/100-custom_data_table.dart';
import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/attendance_record.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/submission.dart';
import 'package:manger_plus/features/console/c4_dashboard/presentation/controller/dashboard_state.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

class DashboardTableSection extends StatelessWidget {
  const DashboardTableSection({
    super.key,
    required this.state,
    required this.onTabChanged,
    required this.onSort,
  });

  final DashboardState state;
  final ValueChanged<DashboardTab> onTabChanged;
  final ValueChanged<String> onSort;

  /// A dashboard is read top-down, so the table below the charts is a sample,
  /// not an archive. It shrink-wraps inside the page's scroll view, which
  /// means every row it is given is BUILT — ten thousand of them would freeze
  /// the page. The header says how many of how many are on screen, sorting
  /// picks which ones, and the CSV export is the way out with all of them.
  static const int maxRows = 200;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: CustomTabs(
                tabs: <String>[s.results, s.attendance],
                selectedValue: state.tab.index,
                onChanged: (int i) => onTabChanged(DashboardTab.values[i]),
              ),
            ),
            Text(
              s.rowsShown(
                '${state.rowsShown > maxRows ? maxRows : state.rowsShown}',
                '${state.rowsTotal}',
              ),
              style: StyleText.fontSize12Weight500
                  .copyWith(color: AppColors.secondaryText),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: AppColors.card,
            // The page scrolls, so the table must not: it shrink-wraps and
            // grows with its rows instead of fighting the page for height.
            child: state.tab == DashboardTab.results
                ? _results(context, s)
                : _attendance(context, s),
          ),
        ),
      ],
    );
  }

  // ── Results ─────────────────────────────────────────────────────────────

  Widget _results(BuildContext context, S s) {
    return AppDataTable<Submission>(
      rows: _capped<Submission>(state.resultRows),
      rowHeight: 56,
      shrinkWrap: true,
      showRowNumbers: true,
      sortKey: state.sortKey,
      sortAscending: state.sortAscending,
      onSort: onSort,
      emptyState: AppEmptyView(
        title: state.scopedSubmissions.isEmpty ? s.noResultsYet : s.noRowsMatch,
      ),
      columns: <AppTableColumn<Submission>>[
        AppTableColumn<Submission>(
          label: s.student,
          flex: 3,
          sortKey: kSortStudent,
          cell: (_, Submission x) => Row(
            children: <Widget>[
              AppAvatar(name: x.studentName, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: AppTableCellText(x.studentName, emphasis: true),
              ),
            ],
          ),
        ),
        AppTableColumn<Submission>(
          label: s.section,
          flex: 2,
          sortKey: kSortSection,
          cell: (_, Submission x) =>
              AppTableCellText(state.sectionTitle(x.sectionId)),
        ),
        AppTableColumn<Submission>(
          label: s.assessment,
          flex: 3,
          sortKey: kSortAssessment,
          cell: (_, Submission x) => Row(
            children: <Widget>[
              AppIcon(x.contentType.icon, size: 16, color: x.contentType.color),
              const SizedBox(width: 8),
              Expanded(child: AppTableCellText(x.contentTitle)),
            ],
          ),
        ),
        AppTableColumn<Submission>(
          label: s.score,
          fixedWidth: 90,
          sortKey: kSortScore,
          alignment: Alignment.centerRight,
          cell: (_, Submission x) => AppTableCellText(
            '${x.percent.round()}%',
            emphasis: true,
            color: _gradeColor(x.percent),
            textAlign: TextAlign.end,
          ),
        ),
        AppTableColumn<Submission>(
          label: s.dateLabel,
          flex: 2,
          sortKey: kSortDate,
          cell: (BuildContext context, Submission x) =>
              AppTableCellText(AppDates.day(context, x.submittedAt)),
        ),
      ],
    );
  }

  // ── Attendance ──────────────────────────────────────────────────────────

  Widget _attendance(BuildContext context, S s) {
    return AppDataTable<AttendanceRecord>(
      rows: _capped<AttendanceRecord>(state.attendanceRows),
      rowHeight: 56,
      shrinkWrap: true,
      showRowNumbers: true,
      sortKey: state.sortKey,
      sortAscending: state.sortAscending,
      onSort: onSort,
      emptyState: AppEmptyView(
        title:
            state.scopedAttendance.isEmpty ? s.noAttendanceYet : s.noRowsMatch,
      ),
      columns: <AppTableColumn<AttendanceRecord>>[
        AppTableColumn<AttendanceRecord>(
          label: s.student,
          flex: 3,
          sortKey: kSortStudent,
          cell: (_, AttendanceRecord x) => Row(
            children: <Widget>[
              AppAvatar(name: x.studentName, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: AppTableCellText(x.studentName, emphasis: true),
              ),
            ],
          ),
        ),
        AppTableColumn<AttendanceRecord>(
          label: s.section,
          flex: 2,
          sortKey: kSortSection,
          cell: (_, AttendanceRecord x) =>
              AppTableCellText(state.sectionTitle(x.sectionId)),
        ),
        AppTableColumn<AttendanceRecord>(
          label: s.dateLabel,
          flex: 2,
          sortKey: kSortDate,
          cell: (BuildContext context, AttendanceRecord x) =>
              AppTableCellText(AppDates.day(context, x.day)),
        ),
        AppTableColumn<AttendanceRecord>(
          label: s.status,
          fixedWidth: 140,
          sortKey: kSortStatus,
          cell: (BuildContext context, AttendanceRecord x) => Row(
            children: <Widget>[
              AppIcon(x.status.icon, size: 16, color: x.status.color),
              const SizedBox(width: 8),
              Expanded(
                child: AppTableCellText(
                  x.status.label(context),
                  color: x.status.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static List<T> _capped<T>(List<T> rows) =>
      rows.length <= maxRows ? rows : rows.sublist(0, maxRows);

  static Color _gradeColor(double percent) {
    if (percent >= 80) return const Color(0xff10B981);
    if (percent >= 65) return const Color(0xff3B82F6);
    if (percent >= 50) return const Color(0xffF59E0B);
    return const Color(0xffEF4444);
  }
}
