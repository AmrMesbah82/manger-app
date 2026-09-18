/// Module: teacher / t2_attendance
///
///*************************** FILE INFO ****************************///
/// File Name: attendance_page.dart
/// Purpose: Declares `AttendancePage` — take the register for a section on a
///          day.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'dart:async';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/data/repository/academy_repository.dart';
import 'package:manger_plus/features/academy/ac1_core/data/utils/academy_utils.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/attendance_record.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/section.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/attendance_status.dart';
import 'package:manger_plus/features/console/c1_shell/presentation/ui/widgets/console_page.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/data/repository/auth_repository.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/user_role.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/presentation/controller/session_controller.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

/// One arrow of the date stepper, at 30 square instead of an [IconButton]'s
/// default 48 — see the header comment where it is used.
class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      iconSize: 20,
      icon: AppIcon(icon),
    );
  }
}

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => _AttendanceView(user: SessionController.to.current));
  }
}

class _AttendanceView extends StatefulWidget {
  const _AttendanceView({required this.user});

  final AppUser user;

  @override
  State<_AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<_AttendanceView> {
  final AttendanceRepository _repository = AttendanceRepository();
  late final Stream<List<Section>> _sections = SectionsRepository().watchAll();

  String? _sectionId;
  DateTime _day = DateTime.now();

  Stream<List<AppUser>>? _students;
  StreamSubscription<List<AttendanceRecord>>? _recordsSub;

  /// What is saved in Firestore for this section/day.
  Map<String, AttendanceStatus> _saved = <String, AttendanceStatus>{};

  /// What the teacher has tapped but not saved yet.
  final Map<String, AttendanceStatus> _edits = <String, AttendanceStatus>{};
  bool _saving = false;

  bool get _dirty => _edits.isNotEmpty;

  @override
  void dispose() {
    _recordsSub?.cancel();
    super.dispose();
  }

  List<Section> _mySections(List<Section> all) => widget.user.role == UserRole.admin
      ? all
      : all.where((Section s) => widget.user.sectionIds.contains(s.id)).toList();

  void _select(String sectionId, DateTime day) {
    _sectionId = sectionId;
    _day = day;
    _edits.clear();
    _saved = <String, AttendanceStatus>{};
    _students = UsersRepository().watchStudentsIn(<String>[sectionId]);
    _recordsSub?.cancel();
    _recordsSub = _repository.watchSectionDay(sectionId, DateKey.of(day)).listen(
      (List<AttendanceRecord> records) {
        if (!mounted) return;
        setState(() => _saved = <String, AttendanceStatus>{
              for (final AttendanceRecord r in records) r.studentId: r.status,
            });
      },
      onError: (Object _) {},
    );
    setState(() {});
  }

  AttendanceStatus? _statusOf(String uid) => _edits[uid] ?? _saved[uid];

  Future<void> _save(List<AppUser> students) async {
    final S s = S.of(context);
    setState(() => _saving = true);
    final String date = DateKey.of(_day);
    final List<AttendanceRecord> records = <AttendanceRecord>[
      for (final AppUser st in students)
        if (_statusOf(st.uid) != null)
          AttendanceRecord(
            id: AttendanceRecord.idFor(date, st.uid),
            studentId: st.uid,
            studentName: st.displayName,
            sectionId: _sectionId!,
            date: date,
            status: _statusOf(st.uid)!,
            teacherId: widget.user.uid,
          ),
    ];
    final Either<AppFailure, Unit> r = await _repository.saveDay(records);
    if (!mounted) return;
    setState(() => _saving = false);
    r.fold(
      (AppFailure f) => showToast(context, f.message(context), error: true),
      (_) {
        setState(_edits.clear);
        showToast(context, s.attendanceSaved);
      },
    );
  }

  Future<void> _pickDay() async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (d != null && _sectionId != null) _select(_sectionId!, d);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);

    return StreamBuilder<List<Section>>(
      stream: _sections,
      builder: (BuildContext context, AsyncSnapshot<List<Section>> snap) {
        final List<Section> sections = _mySections(snap.data ?? const <Section>[]);

        // First section selected automatically once the list arrives.
        if (_sectionId == null && sections.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _sectionId == null) _select(sections.first.id, _day);
          });
        }

        return ConsolePage(
          title: s.attendance,
          subtitle: s.attendanceSub,
          actions: <Widget>[
            // Every control in a page header is kConsoleControlHeight tall,
            // so the two steppers are compact: a default IconButton is 48
            // square and this pill would be taller than the search boxes and
            // buttons it sits beside on every other page.
            Surface(
              radius: 8,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _StepButton(
                    icon: Icons.chevron_left_rounded,
                    onPressed: _sectionId == null
                        ? null
                        : () => _select(
                            _sectionId!, _day.subtract(const Duration(days: 1))),
                  ),
                  TextButton.icon(
                    onPressed: _pickDay,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: AppIcon(Icons.event_rounded, color: AppColors.primary, size: 18),
                    label: Text(AppDates.weekday(context, _day),
                        style: StyleText.fontSize14Weight600),
                  ),
                  _StepButton(
                    icon: Icons.chevron_right_rounded,
                    onPressed:
                        _sectionId == null || DateKey.of(_day) == DateKey.today
                            ? null
                            : () => _select(
                                _sectionId!, _day.add(const Duration(days: 1))),
                  ),
                ],
              ),
            ),
          ],
          child: sections.isEmpty
              ? AppEmptyView(title: s.noSectionsTitle, subtitle: s.noSectionsAssigned)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    FilterChipRow<String>(
                      items: sections.map((Section x) => x.id).toList(),
                      selected: _sectionId,
                      labelOf: (String id) =>
                          sections.firstWhere((Section x) => x.id == id).title,
                      onSelected: (String? id) {
                        if (id != null) _select(id, _day);
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _students == null
                          ? const AppLoading()
                          : StreamBuilder<List<AppUser>>(
                              stream: _students,
                              builder: (BuildContext context, AsyncSnapshot<List<AppUser>> st) {
                                if (st.hasError) {
                                  return AppErrorView(
                                      message: AppFailure.from(st.error!).message(context));
                                }
                                if (!st.hasData) return const AppLoading();
                                return _register(context, st.data!);
                              },
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _register(BuildContext context, List<AppUser> students) {
    final S s = S.of(context);
    if (students.isEmpty) {
      return AppEmptyView(title: s.noStudentsInSection, subtitle: s.noStudentsInSectionSub);
    }

    final Map<AttendanceStatus, int> counts = <AttendanceStatus, int>{
      for (final AttendanceStatus a in AttendanceStatus.values)
        a: students.where((AppUser u) => _statusOf(u.uid) == a).length,
    };
    final int unmarked = students.where((AppUser u) => _statusOf(u.uid) == null).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) {
            // Tablet portrait: the tallies wrap and the buttons get their own
            // line, instead of the row overflowing.
            final List<Widget> tallies = <Widget>[
            for (final AttendanceStatus a in AttendanceStatus.values) ...<Widget>[
              AppIcon(a.icon, color: a.color, size: 18),
              const SizedBox(width: 4),
              Text('${a.label(context)} ${counts[a]}', style: StyleText.fontSize13Weight600),
              const SizedBox(width: 16),
            ],
            if (unmarked > 0)
              Text(s.unmarkedCount('$unmarked'),
                  style: StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryText)),
            ];
            final List<Widget> buttons = <Widget>[
            AppButton(
              label: s.markAllPresent,
              icon: Icons.done_all_rounded,
              kind: AppButtonKind.subtle,
              dense: true,
              onPressed: () => setState(() {
                for (final AppUser u in students) {
                  _edits[u.uid] = AttendanceStatus.present;
                }
              }),
            ),
            const SizedBox(width: 10),
            AppButton(
              label: _dirty ? s.saveChanges : s.saved,
              icon: Icons.save_outlined,
              dense: true,
              loading: _saving,
              onPressed: _dirty ? () => _save(students) : null,
            ),
            ];
            if (c.maxWidth < 720) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 6,
                    children: tallies,
                  ),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: buttons),
                ],
              );
            }
            return Row(children: <Widget>[...tallies, const Spacer(), ...buttons]);
          },
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView.separated(
            itemCount: students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (BuildContext context, int i) {
              final AppUser u = students[i];
              final AttendanceStatus? current = _statusOf(u.uid);
              final List<Widget> chips = <Widget>[
                    for (final AttendanceStatus a in AttendanceStatus.values)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 6),
                        child: ChoiceChip(
                          label: Text(a.label(context)),
                          avatar: AppIcon(a.icon,
                              size: 16, color: current == a ? Colors.white : a.color),
                          selected: current == a,
                          showCheckmark: false,
                          selectedColor: a.color,
                          backgroundColor: a.color.withOpacity(0.08),
                          side: BorderSide.none,
                          labelStyle: StyleText.fontSize12Weight600
                              .copyWith(color: current == a ? Colors.white : a.color),
                          onSelected: (_) => setState(() => _edits[u.uid] = a),
                        ),
                      ),
              ];
              return Surface(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints c) {
                    final Widget who = Row(
                      children: <Widget>[
                    AppAvatar(name: u.displayName, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(u.displayName, style: StyleText.fontSize14Weight600),
                          if (_edits.containsKey(u.uid))
                            Text(s.notSavedYet,
                                style: StyleText.fontSize12Weight500
                                    .copyWith(color: AppColors.orange)),
                        ],
                      ),
                    ),
                      ],
                    );
                    // Tablet portrait: the four statuses move under the name.
                    if (c.maxWidth < 600) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          who,
                          const SizedBox(height: 8),
                          Wrap(runSpacing: 6, children: chips),
                        ],
                      );
                    }
                    return Row(children: <Widget>[Expanded(child: who), ...chips]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
