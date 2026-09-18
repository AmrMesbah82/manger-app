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
import 'package:get/get.dart';

import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
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

              // Narrower list on a tablet in portrait so the results keep room.
              final double listWidth =
                  MediaQuery.sizeOf(context).width < 1000 ? 250 : 320;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    width: listWidth,
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (BuildContext context, int i) {
                        final LearningContent c = items[i];
                        final bool active = c.id == _selectedId;
                        return Surface(
                          color: active ? AppColors.primary.withOpacity(0.1) : null,
                          padding: const EdgeInsets.all(14),
                          onTap: () => _select(c),
                          child: Row(
                            children: <Widget>[
                              ContentTypeIcon(type: c.type, size: 38),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(c.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: StyleText.fontSize14Weight600),
                                    Text(
                                      '${c.type.label(context)} · ${s.pointsTotal(c.totalPoints.toStringAsFixed(0))}',
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
                  const SizedBox(width: 20),
                  Expanded(
                    child: selected == null || _submissions == null
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
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
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

    return Surface(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(content.title, style: StyleText.fontSize18Weight600),
              ),
              _Stat(label: s.submitted, value: '${submissions.length}'),
              const SizedBox(width: 20),
              _Stat(label: s.missing, value: '${missing.length}'),
              const SizedBox(width: 20),
              _Stat(
                label: s.average,
                value: submissions.isEmpty ? '—' : '${average.round()}%',
                color: submissions.isEmpty ? null : gradeColor(average),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
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

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Submission? x = submission;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          AppAvatar(name: name, size: 34),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(name, style: StyleText.fontSize14Weight600),
                if (x != null && x.feedback.isNotEmpty)
                  Text(
                    x.feedback,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              x == null ? '—' : AppDates.dateTime(context, x.submittedAt),
              style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
            ),
          ),
          if (x != null) ...<Widget>[
            StatusPill(
              label: x.gradedByTeacher ? s.gradedByTeacher : s.autoMarked,
              color: x.gradedByTeacher ? AppColors.primary : AppColors.secondaryText,
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: 110,
              child: Text(
                '${_fmt(x.score)} / ${_fmt(x.total)}  ·  ${x.percent.round()}%',
                textAlign: TextAlign.end,
                style: StyleText.fontSize13Weight600.copyWith(color: gradeColor(x.percent)),
              ),
            ),
          ] else
            StatusPill(label: s.missing, color: AppColors.orange),
          IconButton(
            tooltip: x == null ? s.enterGrade : s.editGrade,
            onPressed: onEdit,
            icon: AppIcon(Icons.edit_note_rounded, color: AppColors.primary),
          ),
        ],
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
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _score,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: s.score,
              suffixText: '/ ${_total.toStringAsFixed(0)}',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _feedback,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: s.feedback,
              hintText: s.feedbackHint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
