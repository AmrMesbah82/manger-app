/// Module: console / c4_dashboard
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_charts_section.dart
/// Purpose: Declares `DashboardChartsSection` — the four cards above the table.
/// Author: Manger Plus team
/// Created: 18/9/2026
///
/// Every card here is one of the shared chart widgets from `core/custom`
/// (24 / 26 / 27 / 28). Nothing in this file draws a chart itself; it turns
/// [DashboardState]'s series into [ChartData] and picks the card.
///
/// LAYOUT
/// ------
/// Two by two on a wide console. Under 1000px the cards stack — except the
/// two DONUTS, which share a row: a ring with its legend beneath it is the one
/// chart that still reads at half a tablet's width, where a bar chart's axis
/// would be unlabelled mush. The breakpoint is here rather than in the page
/// because it is a property of THESE cards.
///
/// The score bands are a BAR chart on a wide console and a DONUT on a tablet.
/// Same four numbers; the shape that fits the space it is given.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:manger_plus/core/custom/24-custom_chart_card.dart';
import 'package:manger_plus/core/custom/26-custom_bar_chart_card.dart';
import 'package:manger_plus/core/custom/27-custom_donut_chart_card.dart';
import 'package:manger_plus/core/custom/28-custom_horizontal_bar_chart_card.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/attendance_status.dart';
import 'package:manger_plus/features/console/c4_dashboard/presentation/controller/dashboard_state.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

class DashboardChartsSection extends StatelessWidget {
  const DashboardChartsSection({super.key, required this.state});

  final DashboardState state;

  static const double _cardHeight = 290;

  /// The tablet donut row. Short on purpose: a ring with its legend BESIDE it
  /// needs the width it already has and none of the height a bar chart's axis
  /// needs, so the pair is 210 tall rather than 290 — 20 padding, a 22 header,
  /// a 14 gap and the 128 ring, and nothing spare. Stacking the legend under
  /// the ring instead cost 90pt of empty card and shrank the ring — the ring
  /// is the chart, so it gets the room.
  static const double _donutRowHeight = 210;
  static const double _breakpoint = 1000;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);

    final Widget attendance = _attendanceDonut(context, s, compact: false);
    final Widget byDay = _attendanceByDay(context, s);
    final Widget bySection = _averageBySection(context, s);
    final Widget bands = _scoreBands(context, s);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        if (c.maxWidth < _breakpoint) {
          return Column(
            children: <Widget>[
              // TWO RINGS, ONE ROW. Side by side they read as the pair they
              // are — how the days went, how the marks went — and they cost
              // one row instead of two.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: _attendanceDonut(context, s, compact: true)),
                  SizedBox(width: 12.w),
                  Expanded(child: _scoreBandsDonut(context, s)),
                ],
              ),
              SizedBox(height: 16.h),
              byDay,
              SizedBox(height: 16.h),
              bySection,
            ],
          );
        }
        return Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(flex: 2, child: attendance),
                SizedBox(width: 16.w),
                Expanded(flex: 3, child: byDay),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(flex: 3, child: bySection),
                SizedBox(width: 16.w),
                Expanded(flex: 2, child: bands),
              ],
            ),
          ],
        );
      },
    );
  }

  // ── 1. Attendance by status ─────────────────────────────────────────────
  //
  // A donut rather than bars: these four add up to a whole (every record is
  // exactly one status), which is the one case a ring is the honest shape.
  Widget _attendanceDonut(BuildContext context, S s, {required bool compact}) {
    final Map<AttendanceStatus, int> counts = state.attendanceByStatus;
    final int total = counts.values.fold<int>(0, (int a, int b) => a + b);

    return DonutChartCard(
      title: s.attendanceByStatus,
      height: (compact ? _donutRowHeight : _cardHeight).h,
      expandChild: true,
      // Half a tablet row: legend on the left, a BIGGER ring on the right, in
      // a shorter card.
      chartSize: compact ? 128 : 140,
      ringWidth: compact ? 30 : 26,
      legendBelow: false,
      centerValue: total == 0 ? '—' : '${state.attendanceRate}%',
      // No label inside the compact ring: the hole is ~68pt across there and
      // "Attendance rate" would wrap into three lines inside the doughnut.
      // The card's own title already says what the ring is.
      centerLabel: compact ? null : s.attendanceRateLabel,
      emptyMessage: s.noAttendanceYet,
      sections: <ChartData>[
        for (final MapEntry<AttendanceStatus, int> e in counts.entries)
          if (e.value > 0)
            ChartData(
              label: e.key.label(context),
              value: e.value.toDouble(),
              color: e.key.color,
            ),
      ],
    );
  }

  // ── 2. Attendance rate per day ──────────────────────────────────────────
  //
  // The PERCENT per day, not the head-count: a class of 30 and a class of 8
  // both belong on this axis, and a head-count would make the big section
  // look like the well-attended one.
  Widget _attendanceByDay(BuildContext context, S s) {
    final Map<String, int> byDay = state.attendanceByDay();

    return BarChartCard(
      title: s.attendanceByDay,
      height: _cardHeight.h,
      expandChild: true,
      chartHeight: 210,
      barWidth: 14,
      barColor: AppColors.primary,
      emptyMessage: s.noAttendanceYet,
      bars: <ChartData>[
        for (final MapEntry<String, int> e in byDay.entries)
          ChartData(
            // `yyyy-MM-dd` -> `dd/MM`, which is all that fits under a bar.
            label: _shortDay(e.key),
            value: e.value.toDouble(),
          ),
      ],
    );
  }

  // ── 3. Average score per section ────────────────────────────────────────
  Widget _averageBySection(BuildContext context, S s) {
    final Map<String, int> bySection = state.averageBySection;

    return HorizontalBarChartCard(
      title: s.averageBySection,
      height: _cardHeight.h,
      expandChild: true,
      maxX: 100,
      suffix: '%',
      barHeight: 14,
      emptyMessage: s.noResultsYet,
      bars: <ChartData>[
        for (final MapEntry<String, int> e in bySection.entries)
          ChartData(
            label: state.sectionTitle(e.key),
            value: e.value.toDouble(),
            color: _gradeColor(e.value.toDouble()),
          ),
      ],
    );
  }

  // ── 4. Score bands ──────────────────────────────────────────────────────
  //
  // How many results fell in each quarter of the range. An average of 68 can
  // be "everyone got 68" or "half failed and half aced it", and only this
  // card tells those two apart.
  Widget _scoreBands(BuildContext context, S s) {
    final List<int> bands = state.scoreBands;
    final List<String> labels = <String>[s.band0, s.band50, s.band65, s.band80];
    final List<Color> colors = <Color>[
      const Color(0xffEF4444),
      const Color(0xffF59E0B),
      const Color(0xff3B82F6),
      const Color(0xff10B981),
    ];

    return BarChartCard(
      title: s.scoreBands,
      height: _cardHeight.h,
      expandChild: true,
      chartHeight: 210,
      barWidth: 26,
      caption: s.resultsCountLabel('${state.markedCount}'),
      emptyMessage: s.noResultsYet,
      bars: <ChartData>[
        for (int i = 0; i < bands.length; i++)
          ChartData(
            label: labels[i],
            value: bands[i].toDouble(),
            color: colors[i],
          ),
      ],
    );
  }

  // ── 4b. Score bands, as a ring ──────────────────────────────────────────
  //
  // The same four numbers as [_scoreBands], drawn as a donut for the tablet
  // row. Bands are parts of one whole — every marked result is in exactly one
  // of them — so a ring is as honest here as it is for attendance, and it
  // survives a narrow column that a four-bar axis does not.
  Widget _scoreBandsDonut(BuildContext context, S s) {
    final List<int> bands = state.scoreBands;
    final List<String> labels = <String>[s.band0, s.band50, s.band65, s.band80];
    final List<Color> colors = <Color>[
      const Color(0xffEF4444),
      const Color(0xffF59E0B),
      const Color(0xff3B82F6),
      const Color(0xff10B981),
    ];
    final int total = bands.fold<int>(0, (int a, int b) => a + b);

    return DonutChartCard(
      title: s.scoreBands,
      height: _donutRowHeight.h,
      expandChild: true,
      chartSize: 128,
      ringWidth: 30,
      legendBelow: false,
      // A COUNT in the middle, not a percentage: the ring already shows the
      // shares, and a second percentage in the hole would read as one of them.
      centerValue: total == 0 ? '—' : '$total',
      emptyMessage: s.noResultsYet,
      sections: <ChartData>[
        for (int i = 0; i < bands.length; i++)
          if (bands[i] > 0)
            ChartData(
              label: labels[i],
              value: bands[i].toDouble(),
              color: colors[i],
            ),
      ],
    );
  }

  static String _shortDay(String isoDate) {
    final List<String> parts = isoDate.split('-');
    if (parts.length != 3) return isoDate;
    return '${parts[2]}/${parts[1]}';
  }

  /// Local copy of the grades page's scale, so this file does not drag the
  /// whole grades page in for one function.
  static Color _gradeColor(double percent) {
    if (percent >= 80) return const Color(0xff10B981);
    if (percent >= 65) return const Color(0xff3B82F6);
    if (percent >= 50) return const Color(0xffF59E0B);
    return const Color(0xffEF4444);
  }
}

/// Shown instead of the four cards when nothing has been recorded yet.
class DashboardChartsEmpty extends StatelessWidget {
  const DashboardChartsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return ChartCard(
      title: s.nothingToChart,
      caption: s.nothingToChartSub,
      height: 220.h,
      child: Center(
        child: AppIcon(
          Icons.insights_rounded,
          size: 56.sp,
          color: AppColors.secondaryText.withOpacity(0.35),
        ),
      ),
    );
  }
}
