/// Module: admin / a1_people
///
///*************************** FILE INFO ****************************///
/// File Name: people_page.dart
/// Purpose: Declares `PeoplePage` — the admin's Teachers, Students and
///          Parents pages (one widget, three roles).
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';

import 'package:manger_plus/core/custom/100-custom_data_table.dart';
import 'package:manger_plus/core/custom/11-custom_confirm_dialog.dart';
import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/data/repository/academy_repository.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/section.dart';
import 'package:manger_plus/features/admin/a1_people/presentation/ui/widgets/person_editor_dialog.dart';
import 'package:manger_plus/features/console/c1_shell/presentation/ui/widgets/choice_widgets.dart';
import 'package:manger_plus/features/console/c1_shell/presentation/ui/widgets/console_page.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/data/repository/auth_repository.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/teacher_permission.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/user_role.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

/// A live table of every account with [role], with search, a section filter
/// (teachers and students), and add / edit / switch off / delete.
class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key, required this.role});

  final UserRole role;

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  final UsersRepository _repository = UsersRepository();

  late final Stream<List<AppUser>> _people = _repository.watchByRole(widget.role);
  late final Stream<List<Section>> _sections = SectionsRepository().watchAll();

  /// Parents need the student list — to pick children and to show names.
  late final Stream<List<AppUser>>? _students = widget.role == UserRole.parent
      ? _repository.watchByRole(UserRole.student)
      : null;

  String _query = '';
  String? _sectionFilter;

  String _sectionName(List<Section> sections, String id) {
    for (final Section s in sections) {
      if (s.id == id) return s.title;
    }
    return '—';
  }

  List<AppUser> _filter(List<AppUser> people) {
    final String q = _query.trim().toLowerCase();
    return people.where((AppUser u) {
      if (_sectionFilter != null) {
        final bool inSection = widget.role == UserRole.teacher
            ? u.sectionIds.contains(_sectionFilter)
            : u.sectionId == _sectionFilter;
        if (!inSection) return false;
      }
      if (q.isEmpty) return true;
      return u.displayName.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.phone.contains(q);
    }).toList();
  }

  String _title(S s) {
    switch (widget.role) {
      case UserRole.teacher:
        return s.teachers;
      case UserRole.student:
        return s.students;
      case UserRole.parent:
        return s.parents;
      case UserRole.admin:
        return s.roleAdmin;
    }
  }

  String _addLabel(S s) {
    switch (widget.role) {
      case UserRole.teacher:
        return s.addTeacher;
      case UserRole.student:
        return s.addStudent;
      case UserRole.parent:
        return s.addParent;
      case UserRole.admin:
        return s.add;
    }
  }

  Future<void> _edit(List<Section> sections, List<AppUser> students, [AppUser? user]) async {
    final bool? saved = await showPersonEditor(
      context: context,
      role: widget.role,
      sections: sections,
      students: students,
      existing: user,
    );
    if (saved == true && mounted) showToast(context, S.of(context).saved);
  }

  Future<void> _toggleActive(AppUser user) async {
    final Either<AppFailure, Unit> r =
        await _repository.setActive(user.uid, !user.active);
    if (!mounted) return;
    r.fold((AppFailure f) => showToast(context, f.message(context), error: true), (_) {});
  }

  void _delete(AppUser user) {
    final S s = S.of(context);
    showConfirmDialog(
      context: context,
      title: s.deleteQuestion(user.displayName),
      subtitle: s.deletePersonBody,
      confirmLabel: s.delete,
      cancelLabel: s.cancel,
      onConfirm: () async {
        final Either<AppFailure, Unit> r = await _repository.delete(user);
        if (!mounted) return;
        r.fold(
          (AppFailure f) => showToast(context, f.message(context), error: true),
          (_) => showToast(context, s.deleted),
        );
      },
    );
  }

  List<AppTableColumn<AppUser>> _columns(
    BuildContext context,
    List<Section> sections,
    List<AppUser> students,
  ) {
    final S s = S.of(context);
    final List<AppTableColumn<AppUser>> columns = <AppTableColumn<AppUser>>[
      AppTableColumn<AppUser>(
        label: s.name,
        flex: 3,
        cell: (_, AppUser u) => Row(
          children: <Widget>[
            AppAvatar(name: u.displayName, size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AppTableCellText(u.displayName, emphasis: true),
                  AppTableCellText(u.email),
                ],
              ),
            ),
          ],
        ),
      ),
    ];

    switch (widget.role) {
      case UserRole.teacher:
        columns.addAll(<AppTableColumn<AppUser>>[
          AppTableColumn<AppUser>(
            label: s.subject,
            flex: 2,
            cell: (_, AppUser u) => AppTableCellText(u.subject.isEmpty ? '—' : u.subject),
          ),
          AppTableColumn<AppUser>(
            label: s.sections,
            flex: 3,
            cell: (_, AppUser u) => AppTableCellText(u.sectionIds.isEmpty
                ? '—'
                : u.sectionIds.map((String id) => _sectionName(sections, id)).join(', ')),
          ),
          AppTableColumn<AppUser>(
            label: s.permissions,
            flex: 2,
            cell: (_, AppUser u) => Tooltip(
              message: u.permissions.map((TeacherPermission p) => p.label(context)).join(' · '),
              child: AppTableCellText(
                '${u.permissions.length} / ${TeacherPermission.values.length}',
              ),
            ),
          ),
        ]);
      case UserRole.student:
        columns.addAll(<AppTableColumn<AppUser>>[
          AppTableColumn<AppUser>(
            label: s.section,
            flex: 2,
            cell: (_, AppUser u) => AppTableCellText(
                u.sectionId.isEmpty ? s.noSection : _sectionName(sections, u.sectionId)),
          ),
          AppTableColumn<AppUser>(
            label: s.phone,
            flex: 2,
            cell: (_, AppUser u) => AppTableCellText(u.phone.isEmpty ? '—' : u.phone),
          ),
          AppTableColumn<AppUser>(
            label: s.parents,
            flex: 1,
            cell: (_, AppUser u) => AppTableCellText('${u.parentIds.length}'),
          ),
        ]);
      case UserRole.parent:
        columns.addAll(<AppTableColumn<AppUser>>[
          AppTableColumn<AppUser>(
            label: s.phone,
            flex: 2,
            cell: (_, AppUser u) => AppTableCellText(u.phone.isEmpty ? '—' : u.phone),
          ),
          AppTableColumn<AppUser>(
            label: s.children,
            flex: 3,
            cell: (_, AppUser u) => AppTableCellText(u.childrenIds.isEmpty
                ? '—'
                : students
                    .where((AppUser st) => u.childrenIds.contains(st.uid))
                    .map((AppUser st) => st.displayName)
                    .join(', ')),
          ),
        ]);
      case UserRole.admin:
        break;
    }

    columns.addAll(<AppTableColumn<AppUser>>[
      AppTableColumn<AppUser>(
        label: s.status,
        fixedWidth: 110,
        cell: (_, AppUser u) => StatusPill(
          label: u.active ? s.active : s.inactive,
          color: u.active ? const Color(0xff10B981) : AppColors.secondaryText,
        ),
      ),
      AppTableColumn<AppUser>(
        label: '',
        fixedWidth: 140,
        alignment: Alignment.centerRight,
        cell: (_, AppUser u) => Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              tooltip: s.edit,
              icon: AppIcon(Icons.edit_outlined, color: AppColors.primary, size: 20),
              onPressed: () => _edit(sections, students, u),
            ),
            IconButton(
              tooltip: u.active ? s.switchOff : s.switchOn,
              icon: AppIcon(
                u.active ? Icons.pause_circle_outline : Icons.play_circle_outline,
                color: AppColors.secondaryText,
                size: 20,
              ),
              onPressed: () => _toggleActive(u),
            ),
            IconButton(
              tooltip: s.delete,
              icon: AppIcon(Icons.delete_outline_rounded, color: AppColors.red, size: 20),
              onPressed: () => _delete(u),
            ),
          ],
        ),
      ),
    ]);
    return columns;
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);

    return StreamBuilder<List<Section>>(
      stream: _sections,
      builder: (BuildContext context, AsyncSnapshot<List<Section>> sectionSnap) {
        final List<Section> sections = sectionSnap.data ?? const <Section>[];
        return StreamBuilder<List<AppUser>>(
          stream: _students ?? const Stream<List<AppUser>>.empty(),
          builder: (BuildContext context, AsyncSnapshot<List<AppUser>> studentSnap) {
            final List<AppUser> students = studentSnap.data ?? const <AppUser>[];
            return ConsolePage(
              title: _title(s),
              subtitle: s.peopleSub,
              actions: <Widget>[
                ConsoleSearchField(onChanged: (String v) => setState(() => _query = v)),
                AppButton(
                  label: _addLabel(s),
                  icon: Icons.add_rounded,
                  dense: true,
                  onPressed: () => _edit(sections, students),
                ),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (widget.role != UserRole.parent && sections.isNotEmpty) ...<Widget>[
                    FilterChipRow<String>(
                      items: sections.map((Section x) => x.id).toList(),
                      selected: _sectionFilter,
                      allLabel: s.all,
                      labelOf: (String id) => _sectionName(sections, id),
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
                          stream: _people,
                          builder: (BuildContext context, AsyncSnapshot<List<AppUser>> snap) {
                            if (snap.hasError) {
                              return AppErrorView(
                                message: AppFailure.from(snap.error!).message(context),
                              );
                            }
                            if (!snap.hasData) return const AppLoading();
                            return AppDataTable<AppUser>(
                              columns: _columns(context, sections, students),
                              rows: _filter(snap.data!),
                              rowHeight: 64,
                              emptyState: AppEmptyView(
                                title: s.nobodyYet,
                                subtitle: s.nobodyYetSub,
                              ),
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
      },
    );
  }
}
