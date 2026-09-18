/// Module: onboarding / o2_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: user_role.dart
/// Purpose: Declares `UserRole` — the four kinds of account.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/widgets.dart';

import 'package:manger_plus/core/helper/main_helper/platform_helper.dart';
import 'package:manger_plus/generated/l10n.dart';

/// Stored as the `role` string on `users/{uid}`. The check in this app is for
/// the UI; `firestore.rules` is the real boundary.
enum UserRole {
  /// Runs the center: creates teachers, students, parents and sections, and
  /// decides what each teacher may do. Desktop or tablet.
  admin('admin'),

  /// Publishes content, assigns it, takes attendance, grades, messages
  /// parents — each of those only if the admin switched it on. Desktop or
  /// tablet.
  teacher('teacher'),

  /// Watches, reads and sits exams on a phone or tablet.
  student('student'),

  /// Follows their children and messages teachers on a phone or tablet.
  parent('parent');

  const UserRole(this.key);

  final String key;

  static UserRole fromKey(String? key) {
    for (final UserRole role in UserRole.values) {
      if (role.key == key) return role;
    }
    // Unknown or missing is the least privileged, never the most.
    return UserRole.student;
  }

  /// Whether this role may use the device in [context]. Console roles run on
  /// a desktop or a tablet; students and parents on a phone or tablet.
  bool canUseOn(BuildContext context) => usesConsole
      ? PlatformHelper.canRunConsole(context)
      : PlatformHelper.kindOf(context) == DeviceKind.mobile;

  /// The kind of device to send this role to when it is on the wrong one
  /// (desktop = "a computer or a tablet" for console roles).
  DeviceKind get allowedOn =>
      usesConsole ? DeviceKind.desktop : DeviceKind.mobile;

  /// Admin and teacher work in the desktop console.
  bool get usesConsole => this == UserRole.admin || this == UserRole.teacher;

  bool get isAdmin => this == UserRole.admin;
  bool get isTeacher => this == UserRole.teacher;
  bool get isStudent => this == UserRole.student;
  bool get isParent => this == UserRole.parent;

  String label(BuildContext context) {
    final S s = S.of(context);
    switch (this) {
      case UserRole.admin:
        return s.roleAdmin;
      case UserRole.teacher:
        return s.roleTeacher;
      case UserRole.student:
        return s.roleStudent;
      case UserRole.parent:
        return s.roleParent;
    }
  }
}
