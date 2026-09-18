/// Module: console / c1_shell
///
///*************************** FILE INFO ****************************///
/// File Name: console_shell.dart
/// Purpose: Declares `ConsoleShell` — the desktop frame for admins and
///          teachers.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:manger_plus/core/constants/app_assets.dart';
import 'package:manger_plus/core/custom/104-custom_motion.dart';
import 'package:manger_plus/core/custom/11-custom_confirm_dialog.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/features/admin/a1_people/presentation/ui/pages/people_page.dart';
import 'package:manger_plus/features/admin/a2_sections/presentation/ui/pages/sections_page.dart';
import 'package:manger_plus/features/console/c1_shell/presentation/controller/console_section.dart';
import 'package:manger_plus/features/console/c1_shell/presentation/ui/widgets/console_side_rail.dart';
import 'package:manger_plus/features/console/c4_dashboard/presentation/ui/pages/dashboard_page.dart';
import 'package:manger_plus/features/console/c3_settings/presentation/ui/pages/console_settings_page.dart';
import 'package:manger_plus/features/messages/m1_conversations/presentation/ui/pages/inbox_page.dart';
import 'package:manger_plus/features/onboarding/o1_splash/presentation/ui/pages/splash_screen.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/user_role.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/presentation/controller/session_controller.dart';
import 'package:manger_plus/features/teacher/t1_content/presentation/ui/pages/content_page.dart';
import 'package:manger_plus/features/teacher/t2_attendance/presentation/ui/pages/attendance_page.dart';
import 'package:manger_plus/features/teacher/t3_grades/presentation/ui/pages/grades_page.dart';
import 'package:manger_plus/features/teacher/t4_my_students/presentation/ui/pages/my_students_page.dart';
import 'package:manger_plus/generated/l10n.dart';

/// The rail on the left, the selected page on the right.
///
/// Only the pages this account may open are BUILT — not merely hidden. A
/// hidden admin page would still open its Firestore listeners for a teacher
/// and fill the log with permission errors.
///
/// Pages sit in an [IndexedStack] keyed by section, so switching keeps each
/// page's scroll position and its live subscription.
class ConsoleShell extends StatelessWidget {
  const ConsoleShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConsoleShellCubit>(
      create: (_) => ConsoleShellCubit(),
      child: const _ConsoleShellView(),
    );
  }
}

class _ConsoleShellView extends StatefulWidget {
  const _ConsoleShellView();

  @override
  State<_ConsoleShellView> createState() => _ConsoleShellViewState();
}

class _ConsoleShellViewState extends State<_ConsoleShellView> {
  @override
  void initState() {
    super.initState();
    // The admin switched this account off while it was open.
    SessionController.to.onDeactivated = () {
      if (mounted) AppRouter.signOut(context);
    };
  }

  Widget _pageFor(ConsoleSection section) {
    switch (section) {
      case ConsoleSection.dashboard:
        return const DashboardPage();
      case ConsoleSection.teachers:
        return const PeoplePage(role: UserRole.teacher);
      case ConsoleSection.students:
        return const PeoplePage(role: UserRole.student);
      case ConsoleSection.parents:
        return const PeoplePage(role: UserRole.parent);
      case ConsoleSection.sections:
        return const SectionsPage();
      case ConsoleSection.content:
        return const ContentPage();
      case ConsoleSection.myStudents:
        return const MyStudentsPage();
      case ConsoleSection.attendance:
        return const AttendancePage();
      case ConsoleSection.grades:
        return const GradesPage();
      case ConsoleSection.messages:
        return const InboxPage();
      case ConsoleSection.settings:
        return const ConsoleSettingsPage();
    }
  }

  void _confirmSignOut(BuildContext context) {
    final S s = S.of(context);
    showConfirmDialog(
      context: context,
      title: s.signOutQuestion,
      subtitle: s.signOutBody,
      confirmLabel: s.signOut,
      cancelLabel: s.cancel,
      lottieAsset: AppAssets.lottieLogout,
      onConfirm: () => AppRouter.signOut(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final AppUser user = SessionController.to.current;
      final List<ConsoleSection> sections = ConsoleSection.visibleTo(user);

      return BlocBuilder<ConsoleShellCubit, ConsoleShellState>(
        builder: (BuildContext context, ConsoleShellState state) {
          final ConsoleShellCubit cubit = context.read<ConsoleShellCubit>();

          // A permission switched off under an open page: fall back to the
          // dashboard rather than showing a page this account may not use.
          final ConsoleSection current =
              sections.contains(state.section) ? state.section : ConsoleSection.dashboard;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool tight = constraints.maxWidth < 1100;
                return Row(
                  children: <Widget>[
                    ConsoleSideRail(
                      user: user,
                      sections: sections,
                      current: current,
                      collapsed: state.railCollapsed || tight,
                      onSelected: cubit.select,
                      onToggle: cubit.toggleRail,
                      onSignOut: () => _confirmSignOut(context),
                    ),
                    Expanded(
                      child: SectionTransition(
                        section: current,
                        child: IndexedStack(
                          index: sections.indexOf(current),
                          children: <Widget>[
                            for (final ConsoleSection section in sections)
                              KeyedSubtree(
                                key: ValueKey<ConsoleSection>(section),
                                child: _pageFor(section),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    });
  }
}
