/// Module: student / s1_home
///
///*************************** FILE INFO ****************************///
/// File Name: student_home_screen.dart
/// Purpose: Declares `StudentHomeScreen` — the first thing a student sees.
/// Author: Manger Plus team
/// Created: 18/9/2026
///
/// LAYOUT, TOP TO BOTTOM
/// ---------------------
///  1. Header     — avatar, greeting, section, date, "3 of 5 done" progress.
///  2. Focus card — the ONE thing to do now, chosen in this order:
///                  overdue assessment > soonest due assessment >
///                  newest lesson this week > "all caught up".
///  3. Today | Latest result — attendance today + streak, last score vs the
///                  student's own average.
///  4. At a glance — new / to do / average / attendance.
///  5. Up next    — the other pending exams and quizzes.
///  6. Continue learning — lessons carousel.
///  7. Browse     — one compact row of type chips.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_padding.dart';
import 'package:manger_plus/core/theme/app_radius.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/attendance_record.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/submission.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/content_type.dart';
import 'package:manger_plus/features/student/s1_home/presentation/controller/learner_cubit.dart';
import 'package:manger_plus/features/student/s1_home/presentation/ui/pages/student_layout.dart';
import 'package:manger_plus/features/student/s3_viewer/presentation/ui/pages/content_viewers.dart';
import 'package:manger_plus/generated/l10n.dart';

// ── Small pure helpers ──────────────────────────────────────────────────────

Color _scoreColor(double percent) {
  if (percent >= 80) return const Color(0xff10B981);
  if (percent >= 65) return const Color(0xff3B82F6);
  if (percent >= 50) return const Color(0xffF59E0B);
  return const Color(0xffEF4444);
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Whole days from today to [due]: 0 today, 1 tomorrow, -2 two days late.
int _daysUntil(DateTime due) =>
    _dateOnly(due).difference(_dateOnly(DateTime.now())).inDays;

/// "Due today" / "Due in 3 days" / "2 days overdue", or null without a date.
String? _dueLabel(S s, LearningContent c) {
  if (c.dueAt == null) return null;
  final int d = _daysUntil(c.dueAt!);
  if (d < 0) return s.overdueByDays('${-d}');
  if (d == 0) return s.dueToday;
  if (d == 1) return s.dueTomorrow;
  return s.dueInDays('$d');
}

Color _dueColor(LearningContent c) {
  if (c.dueAt == null) return AppColors.secondaryText;
  final int d = _daysUntil(c.dueAt!);
  if (d < 0) return const Color(0xffEF4444);
  if (d <= 1) return const Color(0xffF59E0B);
  return AppColors.secondaryText;
}

/// Attendance records newest first.
List<AttendanceRecord> _byDayDesc(List<AttendanceRecord> list) =>
    List<AttendanceRecord>.of(list)..sort((a, b) => b.day.compareTo(a.day));

/// Recorded days attended in a row, counting back from the latest one.
int _streak(List<AttendanceRecord> list) {
  int n = 0;
  for (final AttendanceRecord r in _byDayDesc(list)) {
    if (!r.status.attended) break;
    n++;
  }
  return n;
}

// ── Screen ──────────────────────────────────────────────────────────────────

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  String _greeting(S s) {
    final int hour = DateTime.now().hour;
    if (hour < 12) return s.goodMorning;
    if (hour < 17) return s.goodAfternoon;
    return s.goodEvening;
  }

  static void open(BuildContext context, LearnerState state, LearningContent c) {
    ContentOpener.open(
      context,
      content: c,
      learner: state.learner,
      submission: state.submissions[c.id],
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);

    return BlocBuilder<LearnerCubit, LearnerState>(
      builder: (BuildContext context, LearnerState state) {
        final double screenW = MediaQuery.sizeOf(context).width;
        final bool tablet = screenW >= 600;
        // Keep a readable column on tablets instead of stretching edge to edge.
        final double side = screenW > 760 ? (screenW - 720) / 2 : 16.w;

        final List<LearningContent> lessons = state.lessons;
        final List<LearningContent> pending = state.pendingAssessments;
        final LearningContent? focus = pending.isNotEmpty ? pending.first : null;
        final List<LearningContent> upNext =
            pending.length > 1 ? pending.sublist(1) : const <LearningContent>[];

        EdgeInsets pad([double top = 0]) =>
            EdgeInsets.fromLTRB(side, top, side, 0);

        return RefreshIndicator(
          color: AppColors.primary,
          // Everything is live already; this is here because people pull.
          onRefresh: () => Future<void>.delayed(const Duration(milliseconds: 600)),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: _Header(state: state, greeting: _greeting(s), side: side),
              ),
              if (state.failure != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: pad(16.h),
                    child: InfoBanner.error(state.failure!.message(context)),
                  ),
                ),
              if (state.loading)
                const SliverFillRemaining(hasScrollBody: false, child: AppLoading())
              else if (state.content.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyView(
                      title: s.nothingAssignedYet, subtitle: s.nothingAssignedYetSub),
                )
              else ...<Widget>[
                // 2. Focus
                SliverToBoxAdapter(
                  child: Padding(
                    padding: pad(16.h),
                    child: _FocusCard(state: state, focus: focus),
                  ),
                ),

                // 3. Today | Latest result
                SliverToBoxAdapter(
                  child: Padding(
                    padding: pad(12.h),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(child: _TodayCard(state: state)),
                          SizedBox(width: 12.w),
                          Expanded(child: _LatestResultCard(state: state)),
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. At a glance
                _SectionTitle(title: s.atAGlance, side: side),
                SliverToBoxAdapter(
                  child: Padding(padding: pad(), child: _GlanceStrip(state: state)),
                ),

                // 5. Up next
                if (upNext.isNotEmpty) ...<Widget>[
                  _SectionTitle(title: s.upNext, side: side),
                  SliverPadding(
                    padding: pad(),
                    sliver: SliverList.separated(
                      itemCount: upNext.length.clamp(0, 4),
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (BuildContext context, int i) => _UpNextRow(
                        content: upNext[i],
                        onTap: () => open(context, state, upNext[i]),
                      ),
                    ),
                  ),
                ],

                // 6. Continue learning
                if (lessons.isNotEmpty) ...<Widget>[
                  _SectionTitle(
                    title: s.continueLearning,
                    side: side,
                    action: s.seeAll,
                    onAction: () => context.read<StudentTabCubit>().openLibrary(),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 212.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: side, vertical: 2.h),
                        itemCount: lessons.length.clamp(0, 8),
                        separatorBuilder: (_, __) => SizedBox(width: 12.w),
                        itemBuilder: (BuildContext context, int i) => _LessonCard(
                          content: lessons[i],
                          width: tablet ? 220.w : 168.w,
                          onTap: () => open(context, state, lessons[i]),
                        ),
                      ),
                    ),
                  ),
                ],

                // 7. Browse
                _SectionTitle(title: s.browse, side: side),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: side),
                      itemCount: ContentType.values.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (BuildContext context, int i) {
                        final ContentType t = ContentType.values[i];
                        return _BrowseChip(
                          type: t,
                          count: state.ofType(t).length,
                          onTap: () => context.read<StudentTabCubit>().openLibrary(t),
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 28.h)),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ── 1. Header ───────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.state, required this.greeting, required this.side});

  final LearnerState state;
  final String greeting;
  final double side;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final int total =
        state.content.where((LearningContent c) => c.type.isAssessment).length;
    final int done = total - state.pendingAssessments.length;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.primary, AppColors.secondaryPrimary],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(AppPadding.h, MediaQuery.of(context).padding.top + 16.h, AppPadding.h, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 2.r),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: AppAvatar(name: state.learner.displayName, size: 48),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(greeting,
                        style: StyleText.fontSize13Weight500.copyWith(color: Colors.white70)),
                    Text(
                      state.learner.firstName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize22Weight700.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(AppDates.weekday(context, DateTime.now()),
                      style: StyleText.fontSize12Weight600.copyWith(color: Colors.white)),
                  if (state.section != null)
                    Container(
                      margin: EdgeInsets.only(top: 6.h),
                      padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: AppRadius.buttonR,
                      ),
                      child: Text(state.section!.title,
                          style: StyleText.fontSize11Weight600.copyWith(color: Colors.white)),
                    ),
                ],
              ),
            ],
          ),
          if (total > 0) ...<Widget>[
            SizedBox(height: 18.h),
            Text(
              s.assessmentsDone('$done', '$total'),
              style: StyleText.fontSize12Weight600.copyWith(color: Colors.white),
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: AppRadius.containerR,
              child: LinearProgressIndicator(
                value: done / total,
                minHeight: 8.h,
                backgroundColor: Colors.white.withOpacity(0.22),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── 2. Focus card ───────────────────────────────────────────────────────────

class _FocusCard extends StatelessWidget {
  const _FocusCard({required this.state, required this.focus});

  final LearnerState state;
  final LearningContent? focus;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    LearningContent? item = focus;
    String kicker;
    Color accent;
    String? cta;

    if (item != null) {
      final bool late = item.isOverdue;
      kicker = late ? s.focusOverdue : s.focusNext;
      accent = late ? const Color(0xffEF4444) : AppColors.primary;
      cta = s.startNow;
    } else {
      // Nothing to sit: the newest lesson from this week, if any.
      final DateTime weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final Iterable<LearningContent> fresh = state.lessons.where(
          (LearningContent c) => c.createdAt != null && c.createdAt!.isAfter(weekAgo));
      item = fresh.isEmpty ? null : fresh.first;
      kicker = s.focusNew;
      accent = const Color(0xff10B981);
      cta = s.open;
    }

    if (item == null) {
      return Surface(
        padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 18.r),
        child: Row(
          children: <Widget>[
            AppIcon(Icons.check_circle_rounded, color: const Color(0xff10B981), size: 40.r),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(s.allCaughtUp, style: StyleText.fontSize16Weight600),
                  SizedBox(height: 2.h),
                  Text(s.allCaughtUpSub,
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: AppColors.secondaryText)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final LearningContent c = item;
    final String? due = c.type.isAssessment ? _dueLabel(s, c) : null;
    final List<String> meta = <String>[
      if (c.subject.isNotEmpty) c.subject,
      if (c.teacherName.isNotEmpty) c.teacherName,
      if (c.type.isAssessment && c.questions.isNotEmpty) s.questionsCount('${c.questions.length}'),
      if (c.type.isAssessment && c.durationMinutes > 0) s.minutesShort('${c.durationMinutes}'),
    ];

    // A coloured strip on the leading edge says how urgent this is (red =
    // overdue, brand = next, green = new lesson). Drawn as a positioned bar
    // because a one-sided Border cannot be combined with a borderRadius.
    return Surface(
      padding: EdgeInsets.zero,
      onTap: () => StudentHomeScreen.open(context, state, c),
      child: ClipRRect(
        borderRadius: AppRadius.containerR,
        child: Stack(
          children: <Widget>[
            PositionedDirectional(
              start: 0,
              top: 0.h,
              bottom: 0.h,
              child: Container(width: 4.w, color: accent),
            ),
            Padding(
        padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    kicker.toUpperCase(),
                    style: StyleText.fontSize11Weight700.copyWith(color: accent),
                  ),
                ),
                if (due != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: _dueColor(c).withOpacity(0.14),
                      borderRadius: AppRadius.containerR,
                    ),
                    child: Text(due,
                        style: StyleText.fontSize11Weight600.copyWith(color: _dueColor(c))),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: <Widget>[
                ContentTypeIcon(type: c.type, size: 44.r),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(c.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: StyleText.fontSize16Weight600),
                      if (meta.isNotEmpty)
                        Text(meta.join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: StyleText.fontSize12Weight400
                                .copyWith(color: AppColors.secondaryText)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            AppButton(
              label: cta,
              icon: c.type.isAssessment ? Icons.play_arrow_rounded : Icons.open_in_new_rounded,
              expand: true,
              onPressed: () => StudentHomeScreen.open(context, state, c),
            ),
          ],
        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 3a. Today ───────────────────────────────────────────────────────────────

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.state});

  final LearnerState state;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<AttendanceRecord> days = _byDayDesc(state.attendance);
    final DateTime today = _dateOnly(DateTime.now());
    final Iterable<AttendanceRecord> todays =
        days.where((AttendanceRecord r) => _dateOnly(r.day) == today);
    final AttendanceRecord? rec = todays.isEmpty ? null : todays.first;
    final int streak = _streak(state.attendance);
    // Oldest -> newest, so the row reads left to right like a calendar.
    final List<AttendanceRecord> last7 = days.take(7).toList().reversed.toList();

    return Surface(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(s.todayLabel,
              style: StyleText.fontSize12Weight500.copyWith(color: AppColors.secondaryText)),
          SizedBox(height: 6.h),
          Row(
            children: <Widget>[
              AppIcon(rec?.status.icon ?? Icons.schedule_rounded,
                  size: 16.r, color: rec?.status.color ?? AppColors.secondaryText),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  rec?.status.label(context) ?? s.notRecordedToday,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize13Weight600
                      .copyWith(color: rec?.status.color ?? AppColors.text),
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text('$streak', style: StyleText.fontSize24Weight600),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(s.dayStreak,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize11Weight500
                        .copyWith(color: AppColors.secondaryText)),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: <Widget>[
              for (final AttendanceRecord r in last7)
                Expanded(
                  child: Container(
                    height: 8.h,
                    margin: EdgeInsetsDirectional.only(end: AppPadding.h),
                    decoration: BoxDecoration(
                      color: r.status.color,
                      borderRadius: AppRadius.containerR,
                    ),
                  ),
                ),
              for (int i = last7.length; i < 7; i++)
                Expanded(
                  child: Container(
                    height: 8.h,
                    margin: EdgeInsetsDirectional.only(end: AppPadding.h),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryText.withOpacity(0.15),
                      borderRadius: AppRadius.containerR,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 3b. Latest result ───────────────────────────────────────────────────────

class _LatestResultCard extends StatelessWidget {
  const _LatestResultCard({required this.state});

  final LearnerState state;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<Submission> results = state.results;
    final Submission? last = results.isEmpty ? null : results.first;

    if (last == null) {
      return Surface(
        padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(s.latestResult,
                style: StyleText.fontSize12Weight500.copyWith(color: AppColors.secondaryText)),
            SizedBox(height: 10.h),
            AppIcon(Icons.grade_outlined, size: 28.r, color: AppColors.secondaryText),
            SizedBox(height: 8.h),
            Text(s.noResultYetShort,
                style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
          ],
        ),
      );
    }

    final double pct = last.percent;
    final Color color = _scoreColor(pct);
    // Compared with the average of the OTHER results, so a first good mark
    // is not compared with itself.
    final List<Submission> others = results.skip(1).toList();
    String? delta;
    Color deltaColor = AppColors.secondaryText;
    IconData deltaIcon = Icons.arrow_forward_rounded;
    if (others.isNotEmpty) {
      final double avg =
          others.fold<double>(0, (double a, Submission x) => a + x.percent) / others.length;
      final int diff = (pct - avg).round();
      if (diff > 0) {
        delta = s.aboveAverage('$diff');
        deltaColor = const Color(0xff10B981);
      } else if (diff < 0) {
        delta = s.belowAverage('${-diff}');
        deltaColor = const Color(0xffEF4444);
      } else {
        delta = s.onYourAverage;
      }
    }

    String fmt(double v) => v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

    return Surface(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 14.r),
      onTap: () => context.read<StudentTabCubit>().select(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(s.latestResult,
              style: StyleText.fontSize12Weight500.copyWith(color: AppColors.secondaryText)),
          SizedBox(height: 6.h),
          Text(last.contentTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: StyleText.fontSize13Weight600),
          const Spacer(),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text('${pct.round()}%',
                  style: StyleText.fontSize24Weight600.copyWith(color: color)),
              SizedBox(width: 6.w),
              Text('${fmt(last.score)}/${fmt(last.total)}',
                  style: StyleText.fontSize11Weight500
                      .copyWith(color: AppColors.secondaryText)),
            ],
          ),
          SizedBox(height: 6.h),
          if (delta != null)
            Row(
              children: <Widget>[
                if (deltaColor != AppColors.secondaryText)
                  Transform.rotate(
                    angle: deltaColor == const Color(0xff10B981) ? -0.785 : 0.785,
                    child: AppIcon(deltaIcon, size: 12.r, color: deltaColor),
                  ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(delta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize10Weight600.copyWith(color: deltaColor)),
                ),
              ],
            )
          else
            ClipRRect(
              borderRadius: AppRadius.containerR,
              child: LinearProgressIndicator(
                value: pct / 100,
                minHeight: 6.h,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
        ],
      ),
    );
  }
}

// ── 4. At a glance ──────────────────────────────────────────────────────────

class _GlanceStrip extends StatelessWidget {
  const _GlanceStrip({required this.state});

  final LearnerState state;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final double? avg = state.average;
    final double? att = state.attendanceRate;

    Widget cell(IconData icon, Color color, String value, String label) => Expanded(
          child: Column(
            children: <Widget>[
              AppIcon(icon, color: color, size: 20.r),
              SizedBox(height: 6.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value, style: StyleText.fontSize16Weight700),
              ),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize11Weight500
                      .copyWith(color: AppColors.secondaryText)),
            ],
          ),
        );

    Widget divider() => Container(
          width: 1.w,
          height: 36.h,
          color: AppColors.secondaryText.withOpacity(0.15),
        );

    return Surface(
      padding: EdgeInsets.symmetric(vertical: 14.h,horizontal: AppPadding.h),
      child: Row(
        children: <Widget>[
          cell(Icons.video_library_outlined, const Color(0xff3B82F6), '${state.newThisWeek}',
              s.newThisWeek),
          divider(),
          cell(Icons.pending_actions_rounded, const Color(0xffF59E0B),
              '${state.pendingAssessments.length}', s.toDo),
          divider(),
          cell(Icons.grade_rounded, avg == null ? AppColors.secondaryText : _scoreColor(avg),
              avg == null ? '—' : '${avg.round()}%', s.average),
          divider(),
          cell(Icons.fact_check_outlined,
              att == null ? AppColors.secondaryText : _scoreColor(att),
              att == null ? '—' : '${att.round()}%', s.attendance),
        ],
      ),
    );
  }
}

// ── 5. Up next row ──────────────────────────────────────────────────────────

class _UpNextRow extends StatelessWidget {
  const _UpNextRow({required this.content, required this.onTap});

  final LearningContent content;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String? due = _dueLabel(s, content);
    final Color dueColor = _dueColor(content);

    return Surface(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 12.h),
      onTap: onTap,
      child: Row(
        children: <Widget>[
          ContentTypeIcon(type: content.type, size: 36.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(content.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize14Weight600),
                Text(
                  <String>[
                    content.type.label(context),
                    if (content.questions.isNotEmpty)
                      s.questionsCount('${content.questions.length}'),
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          if (due != null) ...<Widget>[
            SizedBox(width: 8.w),
            Text(due, style: StyleText.fontSize11Weight600.copyWith(color: dueColor)),
          ],
          SizedBox(width: 4.w),
          AppIcon(Icons.chevron_right_rounded, size: 18.r, color: AppColors.secondaryText),
        ],
      ),
    );
  }
}

// ── 6. Lesson card ──────────────────────────────────────────────────────────

/// A compact lesson card on the normal card surface: icon panel with the
/// type and a "New" tag, then title, subject · teacher, and the date added.
class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.content, required this.width, required this.onTap});

  final LearningContent content;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final LearningContent c = content;
    final bool isNew = c.createdAt != null &&
        c.createdAt!.isAfter(DateTime.now().subtract(const Duration(days: 7)));
    final String meta = <String>[
      if (c.subject.isNotEmpty) c.subject,
      if (c.teacherName.isNotEmpty) c.teacherName,
    ].join(' · ');

    return SizedBox(
      width: width,
      child: Surface(
        padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 8.r),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Icon panel
            Container(
              height: 88.h,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: AppRadius.containerR,
              ),
              child: Stack(
                children: <Widget>[
                  Center(child: ContentTypeIcon(type: c.type, size: 46.r)),
                  PositionedDirectional(
                    top: 8.h,
                    start: 8.w,
                    child: _Tag(text: c.type.label(context), color: c.type.color),
                  ),
                  if (isNew)
                    PositionedDirectional(
                      top: 8.h,
                      end: 8.w,
                      child: _Tag(text: s.newThisWeek, color: const Color(0xff10B981)),
                    ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.h),
              child: Text(
                c.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize13Weight600,
              ),
            ),
            if (meta.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(AppPadding.h, 2.h, AppPadding.h, 0),
                child: Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize11Weight400
                      .copyWith(color: AppColors.secondaryText),
                ),
              ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.fromLTRB(AppPadding.h, 6.h, AppPadding.h, 2.h),
              child: Row(
                children: <Widget>[
                  AppIcon(Icons.event_outlined, size: 13.r, color: AppColors.secondaryText),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      AppDates.day(context, c.createdAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize11Weight400
                          .copyWith(color: AppColors.secondaryText),
                    ),
                  ),
                  AppIcon(Icons.arrow_forward_rounded, size: 14.r, color: c.type.color),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.containerR,
      ),
      child: Text(text, style: StyleText.fontSize10Weight600.copyWith(color: color)),
    );
  }
}

// ── 7. Browse chip ──────────────────────────────────────────────────────────

class _BrowseChip extends StatelessWidget {
  const _BrowseChip({required this.type, required this.count, required this.onTap});

  final ContentType type;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: AppRadius.buttonR,
      child: InkWell(
        borderRadius: AppRadius.buttonR,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ContentTypeIcon(type: type, size: 22.r),
              SizedBox(width: 6.w),
              Text(type.plural(context), style: StyleText.fontSize13Weight600),
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppRadius.buttonR,
                ),
                child: Text('$count',
                    style: StyleText.fontSize11Weight600.copyWith(color: type.color)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section title ───────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.side,
    this.action,
    this.onAction,
  });

  final String title;
  final double side;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(side + 4.w, 22.h, side - 4.w, 10.h),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(title, style: StyleText.fontSize18Weight600)),
            if (action != null)
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: AppPadding.h),
                  minimumSize: Size(0, 28.h),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(action!,
                    style: StyleText.fontSize13Weight600.copyWith(color: AppColors.primary)),
              ),
          ],
        ),
      ),
    );
  }
}
