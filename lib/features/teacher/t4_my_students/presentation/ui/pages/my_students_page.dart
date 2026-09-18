/// Module: teacher / t4_my_students
///
///*************************** FILE INFO ****************************///
/// File Name: my_students_page.dart
/// Purpose: Declares `MyStudentsPage` — the students in a teacher's sections,
///          each with their results, attendance and a way to reach a parent.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:manger_plus/core/custom/100-custom_data_table.dart';
import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/data/repository/academy_repository.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/attendance_record.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/section.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/submission.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/attendance_status.dart';
import 'package:manger_plus/features/console/c1_shell/presentation/ui/widgets/console_page.dart';
import 'package:manger_plus/features/messages/m1_conversations/data/repository/messages_repository.dart';
import 'package:manger_plus/features/messages/m1_conversations/domain/entities/conversation.dart';
import 'package:manger_plus/features/messages/m1_conversations/presentation/ui/pages/inbox_page.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/data/repository/auth_repository.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/teacher_permission.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/presentation/controller/session_controller.dart';
import 'package:manger_plus/features/teacher/t3_grades/presentation/ui/pages/grades_page.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

class MyStudentsPage extends StatelessWidget {
  const MyStudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => _MyStudentsView(teacher: SessionController.to.current));
  }
}

class _MyStudentsView extends StatefulWidget {
  const _MyStudentsView({required this.teacher});

  final AppUser teacher;

  @override
  State<_MyStudentsView> createState() => _MyStudentsViewState();
}

class _MyStudentsViewState extends State<_MyStudentsView> {
  late Stream<List<AppUser>> _students;
  late final Stream<List<Section>> _sections = SectionsRepository().watchAll();
  String _query = '';
  String? _sectionFilter;

  @override
  void initState() {
    super.initState();
    _students = UsersRepository().watchStudentsIn(widget.teacher.sectionIds);
  }

  @override
  void didUpdateWidget(_MyStudentsView old) {
    super.didUpdateWidget(old);
    if (old.teacher.sectionIds.join() != widget.teacher.sectionIds.join()) {
      _students = UsersRepository().watchStudentsIn(widget.teacher.sectionIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return StreamBuilder<List<Section>>(
      stream: _sections,
      builder: (BuildContext context, AsyncSnapshot<List<Section>> secSnap) {
        final List<Section> sections = (secSnap.data ?? const <Section>[])
            .where((Section x) => widget.teacher.sectionIds.contains(x.id))
            .toList();
        String sectionName(String id) =>
            sections.where((Section x) => x.id == id).firstOrNull?.title ?? '—';

        return ConsolePage(
          title: s.myStudents,
          subtitle: s.myStudentsSub,
          actions: <Widget>[
            ConsoleSearchField(onChanged: (String v) => setState(() => _query = v)),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (sections.length > 1) ...<Widget>[
                FilterChipRow<String>(
                  items: sections.map((Section x) => x.id).toList(),
                  selected: _sectionFilter,
                  allLabel: s.all,
                  labelOf: sectionName,
                  onSelected: (String? v) => setState(() => _sectionFilter = v),
                ),
                const SizedBox(height: 14),
              ],
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: AppColors.card,
                    child: StreamBuilder<List<AppUser>>(
                      stream: _students,
                      builder: (BuildContext context, AsyncSnapshot<List<AppUser>> snap) {
                        if (snap.hasError) {
                          return AppErrorView(message: AppFailure.from(snap.error!).message(context));
                        }
                        if (!snap.hasData) return const AppLoading();
                        final String q = _query.trim().toLowerCase();
                        final List<AppUser> rows = snap.data!
                            .where((AppUser u) =>
                                (_sectionFilter == null || u.sectionId == _sectionFilter) &&
                                (q.isEmpty || u.displayName.toLowerCase().contains(q)))
                            .toList();
                        return AppDataTable<AppUser>(
                          rows: rows,
                          rowHeight: 60,
                          onRowTap: (AppUser u) => showDialog<void>(
                            context: context,
                            builder: (_) => _StudentDialog(
                              student: u,
                              teacher: widget.teacher,
                              sectionName: sectionName(u.sectionId),
                            ),
                          ),
                          emptyState: AppEmptyView(
                            title: s.noStudentsInSection,
                            subtitle: widget.teacher.sectionIds.isEmpty
                                ? s.noSectionsAssigned
                                : s.noStudentsInSectionSub,
                          ),
                          columns: <AppTableColumn<AppUser>>[
                            AppTableColumn<AppUser>(
                              label: s.name,
                              flex: 3,
                              cell: (_, AppUser u) => Row(
                                children: <Widget>[
                                  AppAvatar(name: u.displayName, size: 32),
                                  const SizedBox(width: 10),
                                  Expanded(child: AppTableCellText(u.displayName, emphasis: true)),
                                ],
                              ),
                            ),
                            AppTableColumn<AppUser>(
                              label: s.section,
                              flex: 2,
                              cell: (_, AppUser u) => AppTableCellText(sectionName(u.sectionId)),
                            ),
                            AppTableColumn<AppUser>(
                              label: s.email,
                              flex: 3,
                              cell: (_, AppUser u) => AppTableCellText(u.email),
                            ),
                            AppTableColumn<AppUser>(
                              label: s.parents,
                              flex: 1,
                              cell: (_, AppUser u) => AppTableCellText('${u.parentIds.length}'),
                            ),
                            AppTableColumn<AppUser>(
                              label: '',
                              fixedWidth: 40,
                              cell: (_, __) => AppIcon(Icons.chevron_right_rounded,
                                  color: AppColors.secondaryText),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Everything about one student, for their teacher.
class _StudentDialog extends StatefulWidget {
  const _StudentDialog({
    required this.student,
    required this.teacher,
    required this.sectionName,
  });

  final AppUser student;
  final AppUser teacher;
  final String sectionName;

  @override
  State<_StudentDialog> createState() => _StudentDialogState();
}

class _StudentDialogState extends State<_StudentDialog> {
  late final Stream<List<Submission>> _results =
      SubmissionsRepository().watchForStudent(widget.student.uid);
  late final Stream<List<AttendanceRecord>> _attendance =
      AttendanceRepository().watchForStudent(widget.student.uid);
  late final Future<List<AppUser>> _parents =
      UsersRepository().fetchMany(widget.student.parentIds);

  Future<void> _message(AppUser parent) async {
    final Conversation draft = Conversation(
      id: Conversation.idFor(
        teacherId: widget.teacher.uid,
        parentId: parent.uid,
        studentId: widget.student.uid,
      ),
      teacherId: widget.teacher.uid,
      teacherName: widget.teacher.displayName,
      parentId: parent.uid,
      parentName: parent.displayName,
      studentId: widget.student.uid,
      studentName: widget.student.displayName,
    );
    final Either<AppFailure, Conversation> r = await MessagesRepository().open(draft);
    if (!mounted) return;
    final List<LearningContent> mine =
        await ContentRepository().watchByTeacher(widget.teacher.uid).first;
    if (!mounted) return;
    r.fold(
      (AppFailure f) => showToast(context, f.message(context), error: true),
      (Conversation c) => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => ChatScreen(conversation: c, me: widget.teacher, attachable: mine),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool canMessage = widget.teacher.can(TeacherPermission.messages);

    return ConsoleDialog(
      title: widget.student.displayName,
      subtitle: '${widget.sectionName} · ${widget.student.email}',
      width: 720,
      actions: <Widget>[
        AppButton(label: s.close, kind: AppButtonKind.outlined, onPressed: () => Navigator.of(context).pop()),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ── Parents ───────────────────────────────────────────────────────
          FormLabel(s.parents),
          FutureBuilder<List<AppUser>>(
            future: _parents,
            builder: (BuildContext context, AsyncSnapshot<List<AppUser>> snap) {
              final List<AppUser> parents = snap.data ?? const <AppUser>[];
              if (snap.connectionState != ConnectionState.done) return const AppLoading();
              if (parents.isEmpty) {
                return Text(s.noParentsLinked,
                    style: StyleText.fontSize13Weight400.copyWith(color: AppColors.secondaryText));
              }
              return Column(
                children: <Widget>[
                  for (final AppUser p in parents)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: <Widget>[
                          AppAvatar(name: p.displayName, size: 34),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(p.displayName, style: StyleText.fontSize14Weight600),
                                Text(
                                  <String>[p.phone, p.email].where((String x) => x.isNotEmpty).join(' · '),
                                  style: StyleText.fontSize12Weight400
                                      .copyWith(color: AppColors.secondaryText),
                                ),
                              ],
                            ),
                          ),
                          if (canMessage)
                            AppButton(
                              label: s.message,
                              icon: Icons.chat_bubble_outline_rounded,
                              kind: AppButtonKind.subtle,
                              dense: true,
                              onPressed: () => _message(p),
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),

          // ── Attendance ──────────────────────────────────────────────────
          FormLabel(s.attendance),
          StreamBuilder<List<AttendanceRecord>>(
            stream: _attendance,
            builder: (BuildContext context, AsyncSnapshot<List<AttendanceRecord>> snap) {
              final List<AttendanceRecord> list = snap.data ?? const <AttendanceRecord>[];
              if (list.isEmpty) {
                return Text(s.noAttendanceYet,
                    style: StyleText.fontSize13Weight400.copyWith(color: AppColors.secondaryText));
              }
              final int attended = list.where((AttendanceRecord r) => r.status.attended).length;
              return Wrap(
                spacing: 16,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(s.attendanceRate('${(attended / list.length * 100).round()}'),
                      style: StyleText.fontSize14Weight600),
                  for (final AttendanceStatus a in AttendanceStatus.values)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AppIcon(a.icon, color: a.color, size: 16),
                        const SizedBox(width: 4),
                        Text('${a.label(context)}: ${list.where((AttendanceRecord r) => r.status == a).length}',
                            style: StyleText.fontSize13Weight500),
                      ],
                    ),
                ],
              );
            },
          ),

          // ── Results ─────────────────────────────────────────────────────
          FormLabel(s.results),
          StreamBuilder<List<Submission>>(
            stream: _results,
            builder: (BuildContext context, AsyncSnapshot<List<Submission>> snap) {
              final List<Submission> list = snap.data ?? const <Submission>[];
              if (list.isEmpty) {
                return Text(s.noResultsYet,
                    style: StyleText.fontSize13Weight400.copyWith(color: AppColors.secondaryText));
              }
              return Column(
                children: <Widget>[
                  for (final Submission x in list)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: AppIcon(x.contentType.icon, color: x.contentType.color),
                      title: Text(x.contentTitle, style: StyleText.fontSize14Weight600),
                      subtitle: Text(AppDates.day(context, x.submittedAt),
                          style: StyleText.fontSize12Weight400),
                      trailing: Text(
                        '${x.percent.round()}%',
                        style: StyleText.fontSize15Weight600.copyWith(color: gradeColor(x.percent)),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
