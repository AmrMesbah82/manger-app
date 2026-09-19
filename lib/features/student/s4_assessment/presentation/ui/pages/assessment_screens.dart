/// Module: student / s4_assessment
///
///*************************** FILE INFO ****************************///
/// File Name: assessment_screens.dart
/// Purpose: Declares `AssessmentIntroScreen`, `AssessmentTakeScreen` and
///          `AssessmentResultScreen` — sitting an exam or quiz on a phone.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'dart:async';
import 'dart:math' as math;

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:manger_plus/core/custom/11-custom_confirm_dialog.dart';
import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_padding.dart';
import 'package:manger_plus/core/theme/app_radius.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/data/repository/academy_repository.dart';
import 'package:manger_plus/features/academy/ac1_core/data/utils/academy_utils.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/submission.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/teacher/t3_grades/presentation/ui/pages/grades_page.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

// ── Intro ───────────────────────────────────────────────────────────────────

class AssessmentIntroScreen extends StatelessWidget {
  const AssessmentIntroScreen({
    super.key,
    required this.content,
    required this.learner,
    this.readOnly = false,
  });

  final LearningContent content;
  final AppUser learner;

  /// Parent view: shows what the exam is, never a Start button.
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final LearningContent c = content;
    final Color color = c.type.color;

    Widget fact(IconData icon, String value, String label) => Expanded(
          child: Column(
            children: <Widget>[
              AppIcon(icon, color: Colors.white, size: 22.sp),
              SizedBox(height: 4.h),
              Text(value, style: StyleText.fontSize18Weight700.copyWith(color: Colors.white)),
              Text(label, style: StyleText.fontSize11Weight400.copyWith(color: Colors.white70)),
            ],
          ),
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 280.h,
            backgroundColor: color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[color, Color.lerp(color, Colors.black, 0.3)!],
                  ),
                ),
                padding: EdgeInsets.fromLTRB(AppPadding.h, 90.h, AppPadding.h, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(c.type.label(context).toUpperCase(),
                        style: StyleText.fontSize12Weight700.copyWith(color: Colors.white70)),
                    SizedBox(height: 4.h),
                    Text(c.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize24Weight600.copyWith(color: Colors.white)),
                    const Spacer(),
                    Row(
                      children: <Widget>[
                        fact(Icons.help_outline_rounded, '${c.questions.length}', s.questions),
                        fact(Icons.timer_outlined,
                            c.durationMinutes == 0 ? '∞' : '${c.durationMinutes}', s.minutes),
                        fact(Icons.star_outline_rounded, c.totalPoints.toStringAsFixed(0), s.points),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 20.r),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                if (c.description.isNotEmpty) ...<Widget>[
                  Text(c.description, style: StyleText.fontSize14Weight400),
                  SizedBox(height: 16.h),
                ],
                if (c.teacherName.isNotEmpty)
                  _Line(icon: Icons.person_outline_rounded, text: c.teacherName),
                if (c.dueAt != null)
                  _Line(
                    icon: Icons.event_rounded,
                    text: s.dueOn(AppDates.day(context, c.dueAt)),
                    color: c.isOverdue ? AppColors.red : null,
                  ),
                SizedBox(height: 16.h),
                if (readOnly)
                  InfoBanner(message: s.notTakenYet(learner.firstName))
                else ...<Widget>[
                  InfoBanner(message: s.examRules, icon: Icons.rule_rounded),
                  SizedBox(height: 24.h),
                  AppButton(
                    label: s.startExam(c.type.label(context)),
                    icon: Icons.play_arrow_rounded,
                    expand: true,
                    onPressed: c.questions.isEmpty
                        ? null
                        : () => Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
                              builder: (_) => AssessmentTakeScreen(content: c, learner: learner),
                            )),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? AppColors.secondaryText;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: <Widget>[
          AppIcon(icon, size: 18.sp, color: c),
          SizedBox(width: 8.w),
          Expanded(child: Text(text, style: StyleText.fontSize14Weight500.copyWith(color: c))),
        ],
      ),
    );
  }
}

// ── Taking it ───────────────────────────────────────────────────────────────

class AssessmentTakeScreen extends StatefulWidget {
  const AssessmentTakeScreen({super.key, required this.content, required this.learner});

  final LearningContent content;
  final AppUser learner;

  @override
  State<AssessmentTakeScreen> createState() => _AssessmentTakeScreenState();
}

class _AssessmentTakeScreenState extends State<AssessmentTakeScreen> {
  final PageController _pages = PageController();
  late final List<int> _answers = List<int>.filled(widget.content.questions.length, -1);
  int _index = 0;
  bool _submitting = false;

  Timer? _timer;
  Duration? _left;

  @override
  void initState() {
    super.initState();
    if (widget.content.durationMinutes > 0) {
      _left = Duration(minutes: widget.content.durationMinutes);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _left = _left! - const Duration(seconds: 1));
        // Time is up: hand in what there is.
        if (_left! <= Duration.zero) {
          _timer?.cancel();
          _submit(auto: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pages.dispose();
    super.dispose();
  }

  int get _answered => _answers.where((int a) => a >= 0).length;

  void _go(int i) {
    _pages.animateToPage(i,
        duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
  }

  Future<void> _confirmSubmit() async {
    final S s = S.of(context);
    final int blank = _answers.length - _answered;
    await showConfirmDialog(
      context: context,
      title: s.submitQuestion,
      subtitle: blank > 0 ? s.submitWithBlanks('$blank') : s.submitBody,
      confirmLabel: s.submit,
      cancelLabel: s.keepGoing,
      onConfirm: _submit,
    );
  }

  Future<void> _submit({bool auto = false}) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    _timer?.cancel();

    final LearningContent c = widget.content;
    final Submission submission = Submission(
      id: Submission.idFor(c.id, widget.learner.uid),
      contentId: c.id,
      contentTitle: c.title,
      contentType: c.type,
      teacherId: c.teacherId,
      studentId: widget.learner.uid,
      studentName: widget.learner.displayName,
      sectionId: widget.learner.sectionId,
      answers: _answers,
      score: ExamGrader.score(c, _answers),
      total: c.totalPoints,
    );

    final Either<AppFailure, Unit> r = await SubmissionsRepository().submit(submission);
    if (!mounted) return;
    r.fold(
      (AppFailure f) {
        setState(() => _submitting = false);
        showErrorDialog(
          context: context,
          title: S.of(context).submitFailed,
          subtitle: f == AppFailure.permissionDenied
              ? S.of(context).alreadySubmitted
              : f.message(context),
          closeLabel: S.of(context).close,
        );
      },
      (_) => Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => AssessmentResultScreen(
          content: c,
          submission: submission,
          justSubmitted: true,
          timeUp: auto,
        ),
      )),
    );
  }

  String _clock(Duration d) {
    final Duration v = d.isNegative ? Duration.zero : d;
    return '${v.inMinutes.toString().padLeft(2, '0')}:${v.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final LearningContent c = widget.content;
    final Color color = c.type.color;
    final bool last = _index == c.questions.length - 1;
    final bool hurry = _left != null && _left!.inSeconds <= 60;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (didPop) return;
        showConfirmDialog(
          context: context,
          title: s.leaveExamQuestion,
          subtitle: s.leaveExamBody,
          confirmLabel: s.leave,
          cancelLabel: s.keepGoing,
          onConfirm: () => Navigator.of(context).pop(),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.card,
          foregroundColor: AppColors.text,
          elevation: 0,
          title: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: <Widget>[
            if (_left != null)
              Container(
                margin: EdgeInsetsDirectional.only(end: AppPadding.h),
                padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 6.h),
                decoration: BoxDecoration(
                  color: (hurry ? AppColors.red : color).withOpacity(0.12),
                  borderRadius: AppRadius.buttonR,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AppIcon(Icons.timer_outlined, size: 16.sp, color: hurry ? AppColors.red : color),
                    SizedBox(width: 4.w),
                    Text(_clock(_left!),
                        style: StyleText.fontSize13Weight600
                            .copyWith(color: hurry ? AppColors.red : color)),
                  ],
                ),
              ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(4.h),
            child: LinearProgressIndicator(
              value: (_index + 1) / c.questions.length,
              minHeight: 4.h,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 640.w),
            child: Column(
              children: <Widget>[
                // Question dots — tap to jump; filled = answered.
                SizedBox(
                  height: 52.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 10.h),
                    itemCount: c.questions.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (BuildContext context, int i) {
                      final bool answered = _answers[i] >= 0;
                      final bool current = i == _index;
                      return GestureDetector(
                        onTap: () => _go(i),
                        child: Container(
                          width: 32.r,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: answered ? color : AppColors.card,
                            border: Border.all(
                              color: current ? color : AppColors.borderGrey.withOpacity(0.5),
                              width: current ? 2 : 1,
                            ),
                          ),
                          child: Text('${i + 1}',
                              style: StyleText.fontSize12Weight700
                                  .copyWith(color: answered ? Colors.white : AppColors.text)),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pages,
                    itemCount: c.questions.length,
                    onPageChanged: (int i) => setState(() => _index = i),
                    itemBuilder: (BuildContext context, int i) {
                      final Question q = c.questions[i];
                      return ListView(
                        padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 20.r),
                        children: <Widget>[
                          Text(s.questionNofM('${i + 1}', '${c.questions.length}'),
                              style: StyleText.fontSize13Weight600.copyWith(color: color)),
                          SizedBox(height: 8.h),
                          Text(q.text, style: StyleText.fontSize20Weight600),
                          SizedBox(height: 6.h),
                          Text(s.pointsTotal(q.points.toStringAsFixed(0)),
                              style: StyleText.fontSize12Weight500
                                  .copyWith(color: AppColors.secondaryText)),
                          SizedBox(height: 20.h),
                          for (int o = 0; o < q.options.length; o++)
                            if (q.options[o].trim().isNotEmpty)
                              _OptionCard(
                                letter: String.fromCharCode(65 + o),
                                text: q.options[o],
                                selected: _answers[i] == o,
                                color: color,
                                onTap: () => setState(() => _answers[i] = o),
                              ),
                        ],
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(AppPadding.h, 8.h, AppPadding.h, 12.h),
                    child: Row(
                      children: <Widget>[
                        if (_index > 0)
                          Expanded(
                            child: AppButton(
                              label: s.previous,
                              icon: Icons.arrow_back_rounded,
                              kind: AppButtonKind.outlined,
                              onPressed: () => _go(_index - 1),
                            ),
                          ),
                        if (_index > 0) SizedBox(width: 12.w),
                        Expanded(
                          child: AppButton(
                            label: last ? s.submit : s.next,
                            icon: last ? Icons.check_rounded : Icons.arrow_forward_rounded,
                            loading: _submitting,
                            onPressed: last ? _confirmSubmit : () => _go(_index + 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.letter,
    required this.text,
    required this.selected,
    required this.color,
    required this.onTap,
    this.state,
  });

  final String letter;
  final String text;
  final bool selected;
  final Color color;
  final VoidCallback? onTap;

  /// Review mode: true = correct answer, false = the student's wrong pick.
  final bool? state;

  @override
  Widget build(BuildContext context) {
    Color accent = color;
    if (state == true) accent = const Color(0xff10B981);
    if (state == false) accent = const Color(0xffEF4444);
    final bool highlighted = selected || state != null;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: highlighted ? accent.withOpacity(0.1) : AppColors.card,
        borderRadius: AppRadius.containerR,
        child: InkWell(
          borderRadius: AppRadius.containerR,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 14.r),
            decoration: BoxDecoration(
              borderRadius: AppRadius.containerR,
              border: Border.all(
                color: highlighted ? accent : AppColors.borderGrey.withOpacity(0.35),
                width: highlighted ? 2 : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 32.r,
                  height: 32.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: highlighted ? accent : AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: state == null
                      ? Text(letter,
                          style: StyleText.fontSize13Weight600
                              .copyWith(color: highlighted ? Colors.white : AppColors.text))
                      : AppIcon(state! ? Icons.check_rounded : Icons.close_rounded,
                          color: Colors.white, size: 18.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(child: Text(text, style: StyleText.fontSize15Weight500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Result ──────────────────────────────────────────────────────────────────

class AssessmentResultScreen extends StatelessWidget {
  const AssessmentResultScreen({
    super.key,
    required this.content,
    required this.submission,
    this.justSubmitted = false,
    this.timeUp = false,
  });

  final LearningContent content;
  final Submission submission;
  final bool justSubmitted;
  final bool timeUp;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Submission x = submission;
    final Color color = gradeColor(x.percent);
    final bool hasAnswers = x.answers.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.text,
        elevation: 0,
        title: Text(content.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 640.w),
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 20.r),
            children: <Widget>[
              if (timeUp) ...<Widget>[
                InfoBanner(message: s.timeUp, icon: Icons.timer_off_outlined, color: AppColors.orange),
                SizedBox(height: 16.h),
              ],
              Surface(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 24.r),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: 150.r,
                      height: 150.r,
                      child: CustomPaint(
                        painter: _RingPainter(
                          value: x.percent / 100,
                          color: color,
                          track: color.withOpacity(0.12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text('${x.percent.round()}%',
                                  style: StyleText.fontSize30Weight600.copyWith(color: color)),
                              Text(
                                '${_fmt(x.score)} / ${_fmt(x.total)}',
                                style: StyleText.fontSize13Weight500
                                    .copyWith(color: AppColors.secondaryText),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      justSubmitted ? s.submittedTitle : _verdict(s, x.percent),
                      style: StyleText.fontSize20Weight600,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      x.gradedByTeacher ? s.gradedByTeacher : s.autoMarked,
                      style: StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryText),
                    ),
                    if (x.feedback.isNotEmpty) ...<Widget>[
                      SizedBox(height: 16.h),
                      InfoBanner(message: x.feedback, icon: Icons.format_quote_rounded),
                    ],
                  ],
                ),
              ),
              if (hasAnswers && content.questions.isNotEmpty) ...<Widget>[
                SizedBox(height: 24.h),
                Text(s.review, style: StyleText.fontSize16Weight600),
                SizedBox(height: 12.h),
                for (int i = 0; i < content.questions.length; i++)
                  _ReviewCard(
                    index: i,
                    question: content.questions[i],
                    answer: i < x.answers.length ? x.answers[i] : -1,
                  ),
              ],
              SizedBox(height: 12.h),
              AppButton(
                label: s.done,
                expand: true,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _fmt(double v) => v == v.roundToDouble() ? '${v.toInt()}' : v.toStringAsFixed(1);

  String _verdict(S s, double percent) {
    if (percent >= 85) return s.verdictExcellent;
    if (percent >= 65) return s.verdictGood;
    if (percent >= 50) return s.verdictPass;
    return s.verdictKeepTrying;
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.index, required this.question, required this.answer});

  final int index;
  final Question question;
  final int answer;

  @override
  Widget build(BuildContext context) {
    final bool right = answer == question.correctIndex;
    return Surface(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              AppIcon(right ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: right ? const Color(0xff10B981) : const Color(0xffEF4444)),
              SizedBox(width: 8.w),
              Expanded(
                child: Text('${index + 1}. ${question.text}', style: StyleText.fontSize15Weight600),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          for (int o = 0; o < question.options.length; o++)
            if (question.options[o].trim().isNotEmpty)
              _OptionCard(
                letter: String.fromCharCode(65 + o),
                text: question.options[o],
                selected: false,
                color: AppColors.primary,
                onTap: null,
                state: o == question.correctIndex
                    ? true
                    : (o == answer ? false : null),
              ),
        ],
      ),
    ).withBottomGap(12.h);
  }
}

extension on Widget {
  Widget withBottomGap(double gap) => Padding(padding: EdgeInsets.only(bottom: gap), child: this);
}

/// A progress ring — the score on the result screen and the home summary.
class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.color, required this.track});

  final double value;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final double stroke = size.width * 0.09;
    final Rect rect = Offset.zero & size;
    final Rect arc = rect.deflate(stroke / 2);
    canvas.drawArc(arc, 0, math.pi * 2, false,
        Paint()
          ..color = track
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke);
    canvas.drawArc(arc, -math.pi / 2, math.pi * 2 * value.clamp(0.0, 1.0), false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = stroke);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value || old.color != color;
}
