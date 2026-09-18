/// Module: console / c1_shell
///
///*************************** FILE INFO ****************************///
/// File Name: console_section.dart
/// Purpose: Declares `ConsoleSection` and `ConsoleShellCubit`.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/teacher_permission.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/user_role.dart';
import 'package:manger_plus/generated/l10n.dart';

/// The pages of the desktop console, in rail order.
///
/// ONE console for admins and teachers. Which entries a person sees is
/// decided by [isVisibleTo]: role for the admin pages, the admin's
/// permission switches for the teacher pages. Because the session is live,
/// flipping a switch in the admin's "Edit teacher" dialog adds or removes the
/// page in that teacher's open console within a second.
enum ConsoleSection {
  dashboard(Icons.insights_outlined, Icons.insights_rounded),
  teachers(Icons.co_present_outlined, Icons.co_present_rounded),
  students(Icons.backpack_outlined, Icons.backpack_rounded),
  parents(Icons.family_restroom_outlined, Icons.family_restroom_rounded),
  sections(Icons.groups_2_outlined, Icons.groups_2_rounded),
  content(Icons.video_library_outlined, Icons.video_library_rounded),
  myStudents(Icons.school_outlined, Icons.school_rounded),
  attendance(Icons.fact_check_outlined, Icons.fact_check_rounded),
  grades(Icons.grade_outlined, Icons.grade_rounded),
  messages(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded),
  settings(Icons.settings_outlined, Icons.settings_rounded);

  const ConsoleSection(this.icon, this.activeIcon);

  final IconData icon;
  final IconData activeIcon;

  static const Set<TeacherPermission> _contentPermissions = <TeacherPermission>{
    TeacherPermission.video,
    TeacherPermission.pdf,
    TeacherPermission.image,
    TeacherPermission.exam,
    TeacherPermission.quiz,
  };

  bool isVisibleTo(AppUser user) {
    final bool admin = user.role == UserRole.admin;
    final bool teacher = user.role == UserRole.teacher;
    switch (this) {
      case ConsoleSection.dashboard:
      case ConsoleSection.settings:
        return admin || teacher;
      case ConsoleSection.teachers:
      case ConsoleSection.students:
      case ConsoleSection.parents:
      case ConsoleSection.sections:
        return admin;
      case ConsoleSection.content:
        return admin || (teacher && _contentPermissions.any(user.can));
      case ConsoleSection.myStudents:
        return teacher;
      case ConsoleSection.attendance:
        return user.can(TeacherPermission.attendance);
      case ConsoleSection.grades:
        return user.can(TeacherPermission.grades);
      case ConsoleSection.messages:
        // Messages are parent <-> teacher. The admin is not a party to them.
        return teacher && user.can(TeacherPermission.messages);
    }
  }

  static List<ConsoleSection> visibleTo(AppUser user) =>
      ConsoleSection.values.where((ConsoleSection s) => s.isVisibleTo(user)).toList();

  String label(BuildContext context) {
    final S s = S.of(context);
    switch (this) {
      case ConsoleSection.dashboard:
        return s.dashboard;
      case ConsoleSection.teachers:
        return s.teachers;
      case ConsoleSection.students:
        return s.students;
      case ConsoleSection.parents:
        return s.parents;
      case ConsoleSection.sections:
        return s.sections;
      case ConsoleSection.content:
        return s.content;
      case ConsoleSection.myStudents:
        return s.myStudents;
      case ConsoleSection.attendance:
        return s.attendance;
      case ConsoleSection.grades:
        return s.grades;
      case ConsoleSection.messages:
        return s.messages;
      case ConsoleSection.settings:
        return s.settings;
    }
  }
}

class ConsoleShellState {
  final ConsoleSection section;
  final bool railCollapsed;

  const ConsoleShellState({
    this.section = ConsoleSection.dashboard,
    this.railCollapsed = false,
  });

  ConsoleShellState copyWith({ConsoleSection? section, bool? railCollapsed}) =>
      ConsoleShellState(
        section: section ?? this.section,
        railCollapsed: railCollapsed ?? this.railCollapsed,
      );
}

class ConsoleShellCubit extends Cubit<ConsoleShellState> {
  ConsoleShellCubit() : super(const ConsoleShellState());

  void select(ConsoleSection section) {
    if (section != state.section) emit(state.copyWith(section: section));
  }

  void toggleRail() => emit(state.copyWith(railCollapsed: !state.railCollapsed));
}
