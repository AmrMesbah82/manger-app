/// Module: onboarding / o2_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: user_model.dart
/// Purpose: Declares `UserModel` — the `users/{uid}` document shape.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:manger_plus/core/constants/firebase_collections.dart';
import 'package:manger_plus/core/helper/main_helper/firestore_mapper.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/teacher_permission.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/user_role.dart';

/// Field names here MUST match the `onlyKeys` lists in firestore.rules. The
/// wash app shipped with the rules expecting `name` while the client wrote
/// `full_name`, and every profile save was refused — keep the two in step.
abstract final class UserModel {
  const UserModel._();

  static const String fullName = 'full_name';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String permissions = 'permissions';
  static const String subject = 'subject';
  static const String parentIds = 'parent_ids';
  static const String childrenIds = 'children_ids';

  static AppUser fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.safeData;
    final Map<String, dynamic> perms = data.nested(permissions);

    return AppUser(
      uid: doc.id,
      email: data.str(email),
      fullName: data.str(fullName),
      phone: data.str(phone),
      role: UserRole.fromKey(data.str(FirebaseCollections.roleField)),
      active: data.boolean(FirebaseCollections.activeField, true),
      permissions: <TeacherPermission>{
        for (final MapEntry<String, dynamic> e in perms.entries)
          if (e.value == true && TeacherPermission.fromKey(e.key) != null)
            TeacherPermission.fromKey(e.key)!,
      },
      subject: data.str(subject),
      sectionIds: data.stringList(FirebaseCollections.sectionIdsField),
      sectionId: data.str(FirebaseCollections.sectionIdField),
      parentIds: data.stringList(parentIds),
      childrenIds: data.stringList(childrenIds),
      demo: data.boolean(FirebaseCollections.demoField),
      createdAt: data.date(FirebaseCollections.createdAtField),
    );
  }

  /// Every field the admin controls. Used for create AND update, so an edit
  /// can never leave a role-specific field half-written.
  static Map<String, dynamic> toMap(AppUser user, {bool isCreate = false}) {
    return <String, dynamic>{
      email: user.email.trim().toLowerCase(),
      fullName: user.fullName.trim(),
      phone: user.phone.trim(),
      FirebaseCollections.roleField: user.role.key,
      FirebaseCollections.activeField: user.active,
      permissions: <String, bool>{
        for (final TeacherPermission p in TeacherPermission.values)
          p.key: user.role == UserRole.teacher && user.permissions.contains(p),
      },
      subject: user.subject.trim(),
      FirebaseCollections.sectionIdsField: user.sectionIds,
      FirebaseCollections.sectionIdField: user.sectionId,
      parentIds: user.parentIds,
      childrenIds: user.childrenIds,
      FirebaseCollections.demoField: user.demo,
      if (isCreate)
        FirebaseCollections.createdAtField: FieldValue.serverTimestamp(),
      FirebaseCollections.updatedAtField: FieldValue.serverTimestamp(),
    };
  }

  /// What a user may change about themselves: name and phone, nothing else.
  static Map<String, dynamic> toSelfUpdateMap(AppUser user) =>
      <String, dynamic>{
        fullName: user.fullName.trim(),
        phone: user.phone.trim(),
        FirebaseCollections.updatedAtField: FieldValue.serverTimestamp(),
      };
}
