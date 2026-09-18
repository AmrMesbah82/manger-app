/// Module: student / s5_results
///
///*************************** FILE INFO ****************************///
/// File Name: progress_widgets.dart
/// Purpose: Declares `SummaryCards`, `ResultTile` and `AttendanceCard` —
///          a learner's progress, shared by the student and parent apps.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/attendance_record.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/submission.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/attendance_status.dart';
import 'package:manger_plus/features/student/s1_home/presentation/controller/learner_cubit.dart';
import 'package:manger_plus/features/teacher/t3_grades/presentation/ui/pages/grades_page.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

/// Average grade and attendance rate side by side.
class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key, required this.state});

  final LearnerState state;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final double? avg = state.average;
    final double? att = state.attendanceRate;

    // On a phone each card is only ~170pt wide: a ring beside the text left
    // the label ~70pt and it wrapped / overflowed. There the ring sits on
    // top and the text is centred under it; tablets keep ring | text.
    final bool compact = MediaQuery.sizeOf(context).width < 480;

    Widget card(IconData icon, String label, double? value, String caption) {
      final Color color = value == null ? AppColors.secondaryText : gradeColor(value);
      final Widget ring = SizedBox(
        width: 54.r,
        height: 54.r,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CircularProgressIndicator(
              value: (value ?? 0) / 100,
              strokeWidth: 6,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            Center(child: AppIcon(icon, color: color, size: 22.sp)),
          ],
        ),
      );
      final CrossAxisAlignment align =
          compact ? CrossAxisAlignment.center : CrossAxisAlignment.start;
      final TextAlign textAlign = compact ? TextAlign.center : TextAlign.start;
      final Widget texts = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: align,
        children: <Widget>[
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value == null ? '—' : '${value.round()}%',
                style: StyleText.fontSize22Weight700.copyWith(color: color)),
          ),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: textAlign,
              style: StyleText.fontSize12Weight600),
          Text(caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: textAlign,
              style: StyleText.fontSize11Weight400
                  .copyWith(color: AppColors.secondaryText)),
        ],
      );
      return Expanded(
        child: Surface(
          padding: EdgeInsets.all(compact ? 14.r : 16.r),
          child: compact
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[ring, SizedBox(height: 10.h), texts],
                )
              : Row(
                  children: <Widget>[
                    ring,
                    SizedBox(width: 12.w),
                    Expanded(child: texts),
                  ],
                ),
        ),
      );
    }

    // IntrinsicHeight + stretch: both cards take the height of the taller
    // one, so a label that wraps on one card never leaves them ragged.
    return IntrinsicHeight(
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        card(Icons.emoji_events_outlined, s.averageGrade, avg,
            s.resultsCountLabel('${state.submissions.length}')),
        SizedBox(width: 12.w),
        card(Icons.fact_check_outlined, s.attendance, att,
            s.daysRecorded('${state.attendance.length}')),
      ],
      ),
    );
  }
}

class ResultTile extends StatelessWidget {
  const ResultTile({super.key, required this.submission, this.onTap});

  final Submission submission;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Submission x = submission;
    final Color color = gradeColor(x.percent);
    return Surface(
      onTap: onTap,
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              TypeBadge(icon: x.contentType.icon, color: x.contentType.color, size: 44),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(x.contentTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize14Weight600),
                    Text(
                      '${AppDates.day(context, x.submittedAt)} · ${x.gradedByTeacher ? s.gradedByTeacher : s.autoMarked}',
                      style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text('${x.percent.round()}%',
                      style: StyleText.fontSize18Weight700.copyWith(color: color)),
                  Text(
                    '${_fmt(x.score)}/${_fmt(x.total)}',
                    style: StyleText.fontSize11Weight400.copyWith(color: AppColors.secondaryText),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: x.percent / 100,
              minHeight: 6.h,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (x.feedback.isNotEmpty) ...<Widget>[
            SizedBox(height: 10.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppIcon(Icons.format_quote_rounded, size: 16.sp, color: AppColors.primary),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(x.feedback,
                      style: StyleText.fontSize13Weight500.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _fmt(double v) => v == v.roundToDouble() ? '${v.toInt()}' : v.toStringAsFixed(1);
}

/// Counts per status, then the latest days as coloured dots, then the
/// absences listed by date — what a parent actually wants to see.
class AttendanceCard extends StatelessWidget {
  const AttendanceCard({super.key, required this.records});

  final List<AttendanceRecord> records;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    if (records.isEmpty) {
      return Surface(
        child: Text(s.noAttendanceYet,
            style: StyleText.fontSize13Weight400.copyWith(color: AppColors.secondaryText)),
      );
    }
    final List<AttendanceRecord> missed = records
        .where((AttendanceRecord r) =>
            r.status == AttendanceStatus.absent || r.status == AttendanceStatus.lateArrival)
        .toList();

    return Surface(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 14.w,
            runSpacing: 8.h,
            children: <Widget>[
              for (final AttendanceStatus a in AttendanceStatus.values)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AppIcon(a.icon, color: a.color, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(
                      '${a.label(context)} ${records.where((AttendanceRecord r) => r.status == a).length}',
                      style: StyleText.fontSize13Weight600,
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(s.lastDays, style: StyleText.fontSize12Weight600.copyWith(color: AppColors.secondaryText)),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: <Widget>[
              for (final AttendanceRecord r in records.take(20).toList().reversed)
                Tooltip(
                  message: '${AppDates.weekday(context, r.day)} · ${r.status.label(context)}',
                  child: Container(
                    width: 22.r,
                    height: 22.r,
                    decoration: BoxDecoration(
                      color: r.status.color.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                ),
            ],
          ),
          if (missed.isNotEmpty) ...<Widget>[
            SizedBox(height: 14.h),
            Text(s.absencesAndLate,
                style: StyleText.fontSize12Weight600.copyWith(color: AppColors.secondaryText)),
            SizedBox(height: 6.h),
            for (final AttendanceRecord r in missed.take(8))
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  children: <Widget>[
                    AppIcon(r.status.icon, size: 16.sp, color: r.status.color),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(AppDates.weekday(context, r.day),
                          style: StyleText.fontSize13Weight500),
                    ),
                    Text(r.status.label(context),
                        style: StyleText.fontSize12Weight600.copyWith(color: r.status.color)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
