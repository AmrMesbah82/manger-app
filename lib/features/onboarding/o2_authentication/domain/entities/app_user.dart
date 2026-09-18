/// Module: onboarding / o2_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: app_user.dart
/// Purpose: Declares `AppUser` — any account, as the UI understands it.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/teacher_permission.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/user_role.dart';

/// One class for all four roles. The role-specific fields are simply empty on
/// the roles that do not use them — cheaper to reason about than four classes
/// and four mappers for what is one Firestore collection.
///
/// | field         | admin | teacher | student | parent |
/// |---------------|-------|---------|---------|--------|
/// | permissions   |       |    ✓    |         |        |
/// | subject       |       |    ✓    |         |        |
/// | sectionIds    |       |    ✓    |         |        |  sections they teach
/// | sectionId     |       |         |    ✓    |        |  the one they sit in
/// | parentIds     |       |         |    ✓    |        |
/// | childrenIds   |       |         |         |   ✓    |
class AppUser {
  /// Firebase Auth uid, and the id of the `users` document.
  final String uid;
  final String email;
  final String fullName;
  final String phone;
  final UserRole role;

  /// False = the admin switched the account off. It can still sign in to
  /// Firebase Auth, but the app refuses it at the splash.
  final bool active;

  final Set<TeacherPermission> permissions;
  final String subject;
  final List<String> sectionIds;
  final String sectionId;
  final List<String> parentIds;
  final List<String> childrenIds;

  /// Written by the demo-data button, so "remove demo data" finds it.
  final bool demo;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
    this.fullName = '',
    this.phone = '',
    this.active = true,
    this.permissions = const <TeacherPermission>{},
    this.subject = '',
    this.sectionIds = const <String>[],
    this.sectionId = '',
    this.parentIds = const <String>[],
    this.childrenIds = const <String>[],
    this.demo = false,
    this.createdAt,
  });

  static const AppUser empty =
      AppUser(uid: '', email: '', role: UserRole.student);

  bool get isEmpty => uid.isEmpty;

  /// Whether this account may do [permission]. Admins may do everything.
  bool can(TeacherPermission permission) =>
      role == UserRole.admin ||
      (role == UserRole.teacher && permissions.contains(permission));

  /// What to greet them with.
  String get displayName =>
      fullName.trim().isNotEmpty ? fullName.trim() : email.split('@').first;

  String get firstName => displayName.split(' ').first;

  /// Two letters for the avatar disc.
  String get initials {
    final String source = displayName;
    if (source.isEmpty) return '?';
    final List<String> parts =
        source.split(RegExp(r'[\s@._-]+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phone,
    UserRole? role,
    bool? active,
    Set<TeacherPermission>? permissions,
    String? subject,
    List<String>? sectionIds,
    String? sectionId,
    List<String>? parentIds,
    List<String>? childrenIds,
    bool? demo,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      active: active ?? this.active,
      permissions: permissions ?? this.permissions,
      subject: subject ?? this.subject,
      sectionIds: sectionIds ?? this.sectionIds,
      sectionId: sectionId ?? this.sectionId,
      parentIds: parentIds ?? this.parentIds,
      childrenIds: childrenIds ?? this.childrenIds,
      demo: demo ?? this.demo,
      createdAt: createdAt,
    );
  }
}
