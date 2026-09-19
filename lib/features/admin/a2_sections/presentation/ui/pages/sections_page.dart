/// Module: admin / a2_sections
///
///*************************** FILE INFO ****************************///
/// File Name: sections_page.dart
/// Purpose: Declares `SectionsPage` — the admin's class groups.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:manger_plus/core/custom/11-custom_confirm_dialog.dart';
import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/custom/2-custom_textfield.dart';
import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_padding.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/data/repository/academy_repository.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/section.dart';
import 'package:manger_plus/features/console/c1_shell/presentation/ui/widgets/console_page.dart';
import 'package:manger_plus/features/console/c4_dashboard/presentation/ui/widgets/stat_tile.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/data/repository/auth_repository.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/user_role.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

class SectionsPage extends StatefulWidget {
  const SectionsPage({super.key});

  @override
  State<SectionsPage> createState() => _SectionsPageState();
}

class _SectionsPageState extends State<SectionsPage> {
  final SectionsRepository _repository = SectionsRepository();
  late final Stream<List<Section>> _sections = _repository.watchAll();
  late final Stream<List<AppUser>> _students =
      UsersRepository().watchByRole(UserRole.student);
  late final Stream<List<AppUser>> _teachers =
      UsersRepository().watchByRole(UserRole.teacher);

  Future<void> _edit([Section? section]) async {
    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (_) => _SectionDialog(existing: section),
    );
    if (saved == true && mounted) showToast(context, S.of(context).saved);
  }

  void _delete(Section section, int students) {
    final S s = S.of(context);
    showConfirmDialog(
      context: context,
      title: s.deleteQuestion(section.name),
      subtitle: students > 0 ? s.deleteSectionWithStudents('$students') : s.deleteSectionBody,
      confirmLabel: s.delete,
      cancelLabel: s.cancel,
      onConfirm: () async {
        final Either<AppFailure, Unit> r = await _repository.delete(section.id);
        if (!mounted) return;
        r.fold(
          (AppFailure f) => showToast(context, f.message(context), error: true),
          (_) => showToast(context, s.deleted),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return ConsolePage(
      title: s.sections,
      subtitle: s.sectionsSub,
      scrollable: true,
      actions: <Widget>[
        AppButton(
          label: s.addSection,
          icon: Icons.add_rounded,
          dense: true,
          onPressed: _edit,
        ),
      ],
      child: StreamBuilder<List<AppUser>>(
        stream: _teachers,
        builder: (BuildContext context, AsyncSnapshot<List<AppUser>> teacherSnap) {
          return StreamBuilder<List<AppUser>>(
            stream: _students,
            builder: (BuildContext context, AsyncSnapshot<List<AppUser>> studentSnap) {
              return StreamBuilder<List<Section>>(
                stream: _sections,
                builder: (BuildContext context, AsyncSnapshot<List<Section>> snap) {
                  if (snap.hasError) {
                    return AppErrorView(message: AppFailure.from(snap.error!).message(context));
                  }
                  if (!snap.hasData) return const AppLoading();
                  if (snap.data!.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(top: 40.h),
                      child: AppEmptyView(title: s.noSectionsTitle, subtitle: s.noSectionsSub),
                    );
                  }
                  final List<AppUser> students = studentSnap.data ?? const <AppUser>[];
                  final List<AppUser> teachers = teacherSnap.data ?? const <AppUser>[];
                  return TileGrid(
                    minWidth: 300,
                    // Header (48) + a two-line description (36) + the counts
                    // row + the teacher line, inside 18 of padding.
                    tileHeight: 190,
                    children: <Widget>[
                      for (final Section section in snap.data!)
                        _SectionCard(
                          section: section,
                          students: students
                              .where((AppUser u) => u.sectionId == section.id)
                              .toList(),
                          teachers: teachers
                              .where((AppUser u) => u.sectionIds.contains(section.id))
                              .toList(),
                          onEdit: () => _edit(section),
                          onDelete: (int count) => _delete(section, count),
                        ),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.students,
    required this.teachers,
    required this.onEdit,
    required this.onDelete,
  });

  final Section section;
  final List<AppUser> students;
  final List<AppUser> teachers;
  final VoidCallback onEdit;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Surface(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 18.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const TypeBadge(icon: Icons.groups_2_rounded, color: Color(0xff3B82F6)),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(section.name, style: StyleText.fontSize16Weight600),
                    if (section.level.isNotEmpty)
                      Text(
                        section.level,
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: AppColors.secondaryText),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: s.edit,
                onPressed: onEdit,
                icon: AppIcon(Icons.edit_outlined, color: AppColors.primary, size: 20.sp),
              ),
              IconButton(
                tooltip: s.delete,
                onPressed: () => onDelete(students.length),
                icon: AppIcon(Icons.delete_outline_rounded, color: AppColors.red, size: 20.sp),
              ),
            ],
          ),
          // The description is the part that varies, so it takes the leftover
          // space and the counts row below sits on the bottom edge of EVERY
          // card — see TileGrid.tileHeight.
          Expanded(
            child: section.description.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Text(
                      section.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize13Weight400
                          .copyWith(color: AppColors.secondaryText),
                    ),
                  ),
          ),
          Row(
            children: <Widget>[
              AppIcon(Icons.backpack_outlined, size: 16.sp, color: AppColors.secondaryText),
              SizedBox(width: 6.w),
              Text(s.studentsCount('${students.length}'), style: StyleText.fontSize13Weight500),
              SizedBox(width: 16.w),
              AppIcon(Icons.co_present_outlined, size: 16.sp, color: AppColors.secondaryText),
              SizedBox(width: 6.w),
              Text(s.teachersCount('${teachers.length}'), style: StyleText.fontSize13Weight500),
            ],
          ),
          SizedBox(height: 8.h),
          // Kept in the layout even when empty, so the counts row above it is
          // at the same height on a section with teachers and one without.
          Text(
            teachers.isEmpty
                ? ''
                : teachers.map((AppUser t) => t.displayName).join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _SectionDialog extends StatefulWidget {
  const _SectionDialog({this.existing});

  final Section? existing;

  @override
  State<_SectionDialog> createState() => _SectionDialogState();
}

class _SectionDialogState extends State<_SectionDialog> {
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _level =
      TextEditingController(text: widget.existing?.level ?? '');
  late final TextEditingController _description =
      TextEditingController(text: widget.existing?.description ?? '');
  bool _saving = false;
  bool _submitted = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _level.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    if (_name.text.trim().isEmpty) return;
    setState(() => _saving = true);

    final Section section = (widget.existing ?? const Section(id: '', name: '')).copyWith(
      name: _name.text,
      level: _level.text,
      description: _description.text,
    );
    final Either<AppFailure, String> r = await SectionsRepository().save(section);
    if (!mounted) return;
    r.fold(
      (AppFailure f) => setState(() {
        _saving = false;
        _error = f.message(context);
      }),
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return ConsoleDialog(
      title: widget.existing == null ? s.addSection : s.editSection,
      width: 480,
      actions: <Widget>[
        AppButton(
          label: s.cancel,
          kind: AppButtonKind.outlined,
          onPressed: () => Navigator.of(context).pop(false),
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
          CustomTextField(
            controller: _name,
            label: s.sectionName,
            hint: s.sectionNameHint,
            required: true,
            errorText: _submitted && _name.text.trim().isEmpty ? s.enterName : null,
          ),
          SizedBox(height: 12.h),
          CustomTextField(controller: _level, label: s.level, hint: s.levelHint),
          SizedBox(height: 12.h),
          CustomTextField(
            controller: _description,
            label: s.description,
            maxLines: 3,
            minLines: 2,
          ),
        ],
      ),
    );
  }
}
