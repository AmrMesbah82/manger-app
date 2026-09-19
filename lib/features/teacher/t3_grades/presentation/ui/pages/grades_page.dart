/// Module: teacher / t3_grades
///
///*************************** FILE INFO ****************************///
/// File Name: grades_page.dart
/// Purpose: Declares `GradesPage` — every exam and quiz, who took it, what
///          they scored, and the teacher's override and feedback.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:manger_plus/core/custom/1-custom_dropdown.dart';
import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/helper/main_helper/platform_helper.dart';
import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_padding.dart';
import 'package:manger_plus/core/theme/app_radius.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/data/repository/academy_repository.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/submission.dart';
import 'package:manger_plus/features/console/c1_shell/presentation/ui/widgets/choice_widgets.dart';
import 'package:manger_plus/features/console/c1_shell/presentation/ui/widgets/console_page.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/data/repository/auth_repository.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/user_role.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/presentation/controller/session_controller.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/content_type.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

/// Colour for a percentage — the same bands everywhere a grade is shown.
Color gradeColor(double percent) {
  if (percent >= 85) return const Color(0xff10B981);
  if (percent >= 65) return const Color(0xff3B82F6);
  if (percent >= 50) return const Color(0xffF59E0B);
  return const Color(0xffEF4444);
}

class GradesPage extends StatelessWidget {
  const GradesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => _GradesView(user: SessionController.to.current));
  }
}

class _GradesView extends StatefulWidget {
  const _GradesView({required this.user});

  final AppUser user;

  @override
  State<_GradesView> createState() => _GradesViewState();
}

class _GradesViewState extends State<_GradesView> {
  late Stream<List<LearningContent>> _content;
  late Stream<List<AppUser>> _students;
  Stream<List<Submission>>? _submissions;
  String? _selectedId;

  bool get _isAdmin => widget.user.role == UserRole.admin;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(_GradesView old) {
    super.didUpdateWidget(old);
    if (old.user.uid != widget.user.uid ||
        old.user.sectionIds.join() != widget.user.sectionIds.join()) {
      _subscribe();
    }
  }

  void _subscribe() {
    _content = (_isAdmin
            ? ContentRepository().watchAll()
            : ContentRepository().watchByTeacher(widget.user.uid))
        .map((List<LearningContent> all) =>
            all.where((LearningContent c) => c.type.isAssessment).toList());
    _students = _isAdmin
        ? UsersRepository().watchByRole(UserRole.student)
        : UsersRepository().watchStudentsIn(widget.user.sectionIds);
  }

  void _select(LearningContent c) {
    setState(() {
      _selectedId = c.id;
      _submissions = SubmissionsRepository().watchForContent(c.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return ConsolePage(
      title: s.grades,
      subtitle: s.gradesSub,
      child: StreamBuilder<List<AppUser>>(
        stream: _students,
        builder: (BuildContext context, AsyncSnapshot<List<AppUser>> studentSnap) {
          final List<AppUser> students = studentSnap.data ?? const <AppUser>[];
          return StreamBuilder<List<LearningContent>>(
            stream: _content,
            builder: (BuildContext context, AsyncSnapshot<List<LearningContent>> snap) {
              if (snap.hasError) {
                return AppErrorView(message: AppFailure.from(snap.error!).message(context));
              }
              if (!snap.hasData) return const AppLoading();
              final List<LearningContent> items = snap.data!;
              if (items.isEmpty) {
                return AppEmptyView(title: s.noAssessments, subtitle: s.noAssessmentsSub);
              }
              final LearningContent? selected =
                  items.where((LearningContent c) => c.id == _selectedId).firstOrNull;
              if (selected == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _select(items.first);
                });
              }

              final Widget results = selected == null || _submissions == null
                  ? const AppLoading()
                  : StreamBuilder<List<Submission>>(
                      stream: _submissions,
                      builder: (BuildContext context, AsyncSnapshot<List<Submission>> sub) {
                        if (sub.hasError) {
                          return AppErrorView(
                              message: AppFailure.from(sub.error!).message(context));
                        }
                        if (!sub.hasData) return const AppLoading();
                        return _ResultsPanel(
                          content: selected,
                          submissions: sub.data!,
                          roster: students
                              .where((AppUser u) => selected.isAssignedTo(u))
                              .toList(),
                        );
                      },
                    );

              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints c) {
                  // TWO PANES ARE A DESKTOP IDEA (19/9/2026).
                  //
                  // A 320pt list of assessments beside the results is right on
                  // a wide window and wrong on a tablet: it took a third of
                  // the glass and left the results so narrow that a student's
                  // name broke into four lines and "17 Sep, 10:44" wrapped
                  // mid-time. In a tablet layout the list becomes the app's
                  // one dropdown at the top and the results get the whole
                  // width.
                  if (PlatformHelper.isTabletLayout(context, width: c.maxWidth)) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _AssessmentDropdown(
                          items: items,
                          selected: selected,
                          onSelected: _select,
                        ),
                        SizedBox(height: 12.h),
                        Expanded(child: results),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        width: c.maxWidth < 1200 ? 250.w : 320.w,
                        child: ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) => SizedBox(height: 8.h),
                          itemBuilder: (BuildContext context, int i) {
                            final LearningContent item = items[i];
                            final bool active = item.id == _selectedId;
                            return Surface(
                              color: active ? AppColors.primary.withOpacity(0.1) : null,
                              padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 14.sp),
                              onTap: () => _select(item),
                              child: Row(
                                children: <Widget>[
                                  ContentTypeIcon(type: item.type, size: 38.sp),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(item.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: StyleText.fontSize14Weight600),
                                        Text(
                                          '${item.type.label(context)} · ${s.pointsTotal(item.totalPoints.toStringAsFixed(0))}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: StyleText.fontSize12Weight400
                                              .copyWith(color: AppColors.secondaryText),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Expanded(child: results),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// The assessment list, as the app's one dropdown.
///
/// The tablet face of the left-hand list: same items, same selection, a
/// fortieth of the space. Each row carries its own type glyph, so the list
/// still reads as exams-and-quizzes rather than as a list of strings.
class _AssessmentDropdown extends StatelessWidget {
  const _AssessmentDropdown({
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final List<LearningContent> items;
  final LearningContent? selected;
  final ValueChanged<LearningContent> onSelected;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);

    return CustomDropdown<String>(
      value: selected?.id,
      hint: s.assessment,
      // Design pixels — the dropdown scales it.
      height: 46,
      borderRadius: AppRadius.fieldR,
      fillColor: AppColors.card,
      // No prefix icon: the trigger already draws the SELECTED ROW — its own
      // type glyph and its own label — so a prefix put the glyph on screen
      // twice.
      valueStyle: StyleText.fontSize14Weight600,
      items: <DropdownItem<String>>[
        for (final LearningContent item in items)
          DropdownItem<String>(
            value: item.id,
            label:
                '${item.title}  ·  ${s.pointsTotal(item.totalPoints.toStringAsFixed(0))}',
            leading: ContentTypeIcon(type: item.type, size: 20.sp),
          ),
      ],
      onChanged: (String id) {
        for (final LearningContent item in items) {
          if (item.id == id) {
            onSelected(item);
            return;
          }
        }
      },
    );
  }
}

class _ResultsPanel extends StatelessWidget {
  const _ResultsPanel({
    required this.content,
    required this.submissions,
    required this.roster,
  });

  final LearningContent content;
  final List<Submission> submissions;

  /// Students the item is assigned to — including those who have not
  /// submitted, so the teacher can see who is missing.
  final List<AppUser> roster;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Map<String, Submission> byStudent = <String, Submission>{
      for (final Submission x in submissions) x.studentId: x,
    };
    final List<AppUser> missing =
        roster.where((AppUser u) => !byStudent.containsKey(u.uid)).toList();
    final double average = submissions.isEmpty
        ? 0
        : submissions.fold<double>(0, (double a, Submission x) => a + x.percent) /
            submissions.length;

    final List<Widget> stats = <Widget>[
      _Stat(label: s.submitted, value: '${submissions.length}'),
      SizedBox(width: 20.w),
      _Stat(label: s.missing, value: '${missing.length}'),
      SizedBox(width: 20.w),
      _Stat(
        label: s.average,
        value: submissions.isEmpty ? '—' : '${average.round()}%',
        color: submissions.isEmpty ? null : gradeColor(average),
      ),
    ];

    return Surface(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final Widget title = Text(
                content.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize18Weight600,
              );
              // Three numbers and a title do not share a narrow line: the
              // title wins the first line and the numbers take the second.
              if (c.maxWidth < 560) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    title,
                    SizedBox(height: 10.h),
                    Row(children: stats),
                  ],
                );
              }
              return Row(
                children: <Widget>[Expanded(child: title), ...stats],
              );
            },
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: ListView(
              children: <Widget>[
                for (final Submission x in submissions)
                  _ResultRow(
                    name: x.studentName,
                    submission: x,
                    onEdit: () => _editGrade(context, x),
                  ),
                if (missing.isNotEmpty) ...<Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
                    child: Text(s.notSubmittedYet, style: StyleText.fontSize13Weight600),
                  ),
                  for (final AppUser u in missing)
                    _ResultRow(
                      name: u.displayName,
                      submission: null,
                      onEdit: () => _editGrade(context, null, student: u),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editGrade(BuildContext context, Submission? existing, {AppUser? student}) {
    return showDialog<void>(
      context: context,
      builder: (_) => _GradeDialog(content: content, existing: existing, student: student),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(value, style: StyleText.fontSize20Weight600.copyWith(color: color)),
        Text(label,
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.name, required this.submission, required this.onEdit});

  final String name;
  final Submission? submission;
  final VoidCallback onEdit;

  /// Below this the row is two lines: who on top, the facts underneath.
  ///
  /// FOUR COLUMNS NEED ROOM (19/9/2026). Name, date, state and score side by
  /// side is a table row, and a table row in a 350pt panel is what turned
  /// "Youssef Mahmoud" into four lines of three letters. The pieces are the
  /// same in both shapes — only how they are stacked changes.
  static const double _wideRow = 700;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Submission? x = submission;

    final Widget who = Row(
      children: <Widget>[
        AppAvatar(name: name, size: 34),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize14Weight600,
              ),
              if (x != null && x.feedback.isNotEmpty)
                Text(
                  x.feedback,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryText),
                ),
            ],
          ),
        ),
      ],
    );

    final Widget when = Text(
      x == null ? '—' : AppDates.dateTime(context, x.submittedAt),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
    );

    final Widget state = x == null
        ? StatusPill(label: s.missing, color: AppColors.orange)
        : StatusPill(
            label: x.gradedByTeacher ? s.gradedByTeacher : s.autoMarked,
            color: x.gradedByTeacher ? AppColors.primary : AppColors.secondaryText,
          );

    final Widget? score = x == null
        ? null
        : Text(
            '${_fmt(x.score)} / ${_fmt(x.total)}  ·  ${x.percent.round()}%',
            maxLines: 1,
            softWrap: false,
            textAlign: TextAlign.end,
            style: StyleText.fontSize13Weight600.copyWith(color: gradeColor(x.percent)),
          );

    final Widget edit = IconButton(
      tooltip: x == null ? s.enterGrade : s.editGrade,
      onPressed: onEdit,
      icon: AppIcon(Icons.edit_note_rounded, color: AppColors.primary, size: 22.sp),
    );

    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.containerR,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          if (c.maxWidth >= _wideRow) {
            return Row(
              children: <Widget>[
                Expanded(flex: 3, child: who),
                Expanded(flex: 2, child: when),
                state,
                SizedBox(width: 14.w),
                if (score != null) SizedBox(width: 110.w, child: score),
                edit,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(children: <Widget>[Expanded(child: who), edit]),
              SizedBox(height: 6.h),
              Row(
                children: <Widget>[
                  state,
                  SizedBox(width: 10.w),
                  Expanded(child: when),
                  if (score != null) ...<Widget>[SizedBox(width: 10.w), score],
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  static String _fmt(double v) => v == v.roundToDouble() ? '${v.toInt()}' : v.toStringAsFixed(1);
}

class _GradeDialog extends StatefulWidget {
  const _GradeDialog({required this.content, this.existing, this.student});

  final LearningContent content;
  final Submission? existing;

  /// Set when grading a student with no submission (paper exam).
  final AppUser? student;

  @override
  State<_GradeDialog> createState() => _GradeDialogState();
}

class _GradeDialogState extends State<_GradeDialog> {
  late final TextEditingController _score = TextEditingController(
      text: widget.existing == null ? '' : widget.existing!.score.toString());
  late final TextEditingController _feedback =
      TextEditingController(text: widget.existing?.feedback ?? '');
  bool _saving = false;
  String? _error;

  double get _total => widget.content.totalPoints;

  @override
  void dispose() {
    _score.dispose();
    _feedback.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final double? score = double.tryParse(_score.text.trim());
    if (score == null || score < 0 || score > _total) {
      setState(() => _error = S.of(context).scoreRange(_total.toStringAsFixed(0)));
      return;
    }
    setState(() => _saving = true);
    final SubmissionsRepository repo = SubmissionsRepository();
    final Either<AppFailure, Unit> r;
    if (widget.existing != null) {
      r = await repo.grade(
        submissionId: widget.existing!.id,
        score: score,
        feedback: _feedback.text,
      );
    } else {
      final AppUser st = widget.student!;
      r = await repo.recordManualGrade(Submission(
        id: Submission.idFor(widget.content.id, st.uid),
        contentId: widget.content.id,
        contentTitle: widget.content.title,
        contentType: widget.content.type,
        teacherId: widget.content.teacherId,
        studentId: st.uid,
        studentName: st.displayName,
        sectionId: st.sectionId,
        score: score,
        total: _total,
        gradedBy: 'teacher',
        feedback: _feedback.text.trim(),
      ));
    }
    if (!mounted) return;
    r.fold(
      (AppFailure f) => setState(() {
        _saving = false;
        _error = f.message(context);
      }),
      (_) => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return ConsoleDialog(
      title: widget.existing == null ? s.enterGrade : s.editGrade,
      subtitle: widget.existing?.studentName ?? widget.student?.displayName,
      width: 440,
      actions: <Widget>[
        AppButton(
          label: s.cancel,
          kind: AppButtonKind.outlined,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(label: s.save, icon: Icons.check_rounded, loading: _saving, onPressed: _save),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (_error != null) ...<Widget>[
            InfoBanner.error(_error!),
            SizedBox(height: 12.h),
          ],
          TextField(
            controller: _score,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: s.score,
              suffixText: '/ ${_total.toStringAsFixed(0)}',
              border: OutlineInputBorder(borderRadius: AppRadius.fieldR),
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _feedback,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: s.feedback,
              hintText: s.feedbackHint,
              border: OutlineInputBorder(borderRadius: AppRadius.fieldR),
            ),
          ),
        ],
      ),
    );
  }
}
