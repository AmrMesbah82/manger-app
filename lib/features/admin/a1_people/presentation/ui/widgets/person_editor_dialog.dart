/// Module: admin / a1_people
///
///*************************** FILE INFO ****************************///
/// File Name: person_editor_dialog.dart
/// Purpose: Declares `PersonEditorDialog` — create or edit a teacher,
///          student or parent, including the teacher's permission switches.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'dart:math';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:manger_plus/core/constants/app_constants.dart';
import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/custom/2-custom_textfield.dart';
import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_padding.dart';
import 'package:manger_plus/core/theme/app_radius.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/section.dart';
import 'package:manger_plus/features/console/c1_shell/presentation/ui/widgets/choice_widgets.dart';
import 'package:manger_plus/features/console/c1_shell/presentation/ui/widgets/console_page.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/data/repository/auth_repository.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/teacher_permission.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/user_role.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

/// Opens the editor. [existing] null = create. Returns true when saved.
Future<bool?> showPersonEditor({
  required BuildContext context,
  required UserRole role,
  required List<Section> sections,
  List<AppUser> students = const <AppUser>[],
  AppUser? existing,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => PersonEditorDialog(
      role: role,
      sections: sections,
      students: students,
      existing: existing,
    ),
  );
}

class PersonEditorDialog extends StatefulWidget {
  const PersonEditorDialog({
    super.key,
    required this.role,
    required this.sections,
    required this.students,
    this.existing,
  });

  final UserRole role;
  final List<Section> sections;

  /// Only for parents — who can be picked as their children.
  final List<AppUser> students;
  final AppUser? existing;

  @override
  State<PersonEditorDialog> createState() => _PersonEditorDialogState();
}

class _PersonEditorDialogState extends State<PersonEditorDialog> {
  final UsersRepository _repository = UsersRepository();

  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.fullName ?? '');
  late final TextEditingController _email =
      TextEditingController(text: widget.existing?.email ?? '');
  late final TextEditingController _phone =
      TextEditingController(text: widget.existing?.phone ?? '');
  late final TextEditingController _password = TextEditingController();
  late final TextEditingController _subject =
      TextEditingController(text: widget.existing?.subject ?? '');

  late bool _active = widget.existing?.active ?? true;
  late Set<TeacherPermission> _permissions = widget.existing == null
      ? TeacherPermission.defaults.toSet()
      : widget.existing!.permissions.toSet();
  late Set<String> _teacherSections = widget.existing?.sectionIds.toSet() ?? <String>{};
  late String _studentSection = widget.existing?.sectionId ?? '';
  late Set<String> _children = widget.existing?.childrenIds.toSet() ?? <String>{};

  bool _saving = false;
  bool _submitted = false;
  String? _error;

  bool get _isCreate => widget.existing == null;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _subject.dispose();
    super.dispose();
  }

  String _generatePassword() {
    const String chars = 'abcdefghjkmnpqrstuvwxyz23456789';
    final Random r = Random.secure();
    return List<String>.generate(8, (_) => chars[r.nextInt(chars.length)]).join();
  }

  String? get _nameError =>
      _submitted && _name.text.trim().isEmpty ? S.of(context).enterName : null;

  String? get _emailError {
    if (!_submitted || !_isCreate) return null;
    final String v = _email.text.trim();
    if (v.isEmpty) return S.of(context).enterEmail;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
      return S.of(context).errInvalidEmail;
    }
    return null;
  }

  String? get _passwordError => _submitted &&
          _isCreate &&
          _password.text.length < AppConstants.minPasswordLength
      ? S.of(context).errWeakPassword
      : null;

  Future<void> _save() async {
    setState(() {
      _submitted = true;
      _error = null;
    });
    if (_nameError != null || _emailError != null || _passwordError != null) return;

    setState(() => _saving = true);

    final AppUser base = widget.existing ??
        AppUser(uid: '', email: _email.text.trim(), role: widget.role);
    final AppUser user = base.copyWith(
      fullName: _name.text.trim(),
      phone: _phone.text.trim(),
      active: _active,
      subject: widget.role == UserRole.teacher ? _subject.text.trim() : '',
      permissions: widget.role == UserRole.teacher ? _permissions : <TeacherPermission>{},
      sectionIds:
          widget.role == UserRole.teacher ? _teacherSections.toList() : const <String>[],
      sectionId: widget.role == UserRole.student ? _studentSection : '',
      childrenIds: widget.role == UserRole.parent ? _children.toList() : null,
    );

    final Either<AppFailure, Object> result = _isCreate
        ? await _repository.create(user, _password.text)
        : await _repository.update(user, previous: widget.existing);

    if (!mounted) return;
    result.fold(
      (AppFailure f) => setState(() {
        _saving = false;
        _error = f.message(context);
      }),
      (_) => Navigator.of(context).pop(true),
    );
  }

  String _title(S s) {
    switch (widget.role) {
      case UserRole.teacher:
        return _isCreate ? s.addTeacher : s.editTeacher;
      case UserRole.student:
        return _isCreate ? s.addStudent : s.editStudent;
      case UserRole.parent:
        return _isCreate ? s.addParent : s.editParent;
      case UserRole.admin:
        return s.roleAdmin;
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);

    return ConsoleDialog(
      title: _title(s),
      subtitle: _isCreate ? s.accountCreateHint : widget.existing!.email,
      width: widget.role == UserRole.teacher ? 680 : 560,
      actions: <Widget>[
        AppButton(
          label: s.cancel,
          kind: AppButtonKind.outlined,
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: _isCreate ? s.createAccount : s.save,
          icon: Icons.check_rounded,
          loading: _saving,
          onPressed: _save,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (_error != null) ...<Widget>[
            InfoBanner.error(_error!),
            SizedBox(height: 12.h),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: CustomTextField(
                  controller: _name,
                  label: s.fullName,
                  required: true,
                  errorText: _nameError,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomTextField(
                  controller: _phone,
                  label: s.phone,
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          CustomTextField(
            controller: _email,
            label: s.email,
            required: true,
            enabled: _isCreate,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
          ),
          if (_isCreate) ...<Widget>[
            SizedBox(height: 12.h),
            CustomTextField(
              controller: _password,
              label: s.password,
              required: true,
              errorText: _passwordError,
              helperText: s.passwordShareHint,
              suffixIcon: IconButton(
                tooltip: s.generate,
                icon: const AppIcon(Icons.casino_outlined),
                onPressed: () => setState(() => _password.text = _generatePassword()),
              ),
            ),
          ],

          // ── Teacher ─────────────────────────────────────────────────────
          if (widget.role == UserRole.teacher) ...<Widget>[
            SizedBox(height: 12.h),
            CustomTextField(controller: _subject, label: s.subject, hint: s.subjectHint),
            FormLabel(s.teachesSections),
            ChoiceWrap<String>(
              items: widget.sections.map((Section x) => x.id).toList(),
              selected: _teacherSections,
              labelOf: (String id) =>
                  widget.sections.firstWhere((Section x) => x.id == id).title,
              emptyText: s.noSectionsYet,
              onChanged: (Set<String> v) => setState(() => _teacherSections = v),
            ),
            FormLabel(s.permissions),
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: AppRadius.containerR,
              ),
              child: Column(
                children: <Widget>[
                  for (final TeacherPermission p in TeacherPermission.values)
                    SwitchRow(
                      icon: p.icon,
                      title: p.label(context),
                      subtitle: p.description(context),
                      value: _permissions.contains(p),
                      onChanged: (bool on) => setState(() {
                        _permissions = <TeacherPermission>{..._permissions};
                        on ? _permissions.add(p) : _permissions.remove(p);
                      }),
                    ),
                ],
              ),
            ),
          ],

          // ── Student ─────────────────────────────────────────────────────
          if (widget.role == UserRole.student) ...<Widget>[
            FormLabel(s.section),
            ChoiceWrap<String>(
              multi: false,
              items: widget.sections.map((Section x) => x.id).toList(),
              selected: _studentSection.isEmpty ? <String>{} : <String>{_studentSection},
              labelOf: (String id) =>
                  widget.sections.firstWhere((Section x) => x.id == id).title,
              emptyText: s.noSectionsYet,
              onChanged: (Set<String> v) =>
                  setState(() => _studentSection = v.isEmpty ? '' : v.first),
            ),
          ],

          // ── Parent ──────────────────────────────────────────────────────
          if (widget.role == UserRole.parent) ...<Widget>[
            FormLabel(s.children),
            PeoplePicker(
              people: widget.students,
              selected: _children,
              subtitleOf: (AppUser u) {
                final Iterable<Section> match =
                    widget.sections.where((Section x) => x.id == u.sectionId);
                return match.isEmpty ? u.email : match.first.title;
              },
              onChanged: (Set<String> v) => setState(() => _children = v),
            ),
          ],

          SizedBox(height: 8.h),
          SwitchRow(
            icon: Icons.power_settings_new_rounded,
            title: s.accountActive,
            subtitle: s.accountActiveHint,
            value: _active,
            onChanged: (bool v) => setState(() => _active = v),
          ),
          Text(
            '${s.roleLabel}: ${widget.role.label(context)}',
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}
