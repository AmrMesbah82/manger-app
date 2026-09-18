/// Module: onboarding / o2_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: auth_base_repository.dart
/// Purpose: Declares `AuthBaseRepository` and `UsersBaseRepository`.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:dartz/dartz.dart';

import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/auth_failure_type.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/user_role.dart';

/// Signing in and out — the current session.
abstract class AuthBaseRepository {
  Future<Either<AuthFailureType, AppUser>> signIn({
    required String email,
    required String password,
  });

  /// The signed-in user with their profile, or null. Never throws.
  Future<AppUser?> restoreSession();

  /// Whether the first admin has been created on this Firebase project.
  Future<bool> isSetupDone();

  Future<Either<AuthFailureType, AppUser>> createFirstAdmin({
    required String fullName,
    required String email,
    required String password,
  });

  Future<Either<AuthFailureType, Unit>> sendPasswordReset(String email);

  Future<void> signOut();
}

/// Everybody else's accounts — what the admin manages and the other roles
/// look up.
abstract class UsersBaseRepository {
  Stream<List<AppUser>> watchByRole(UserRole role);

  Stream<List<AppUser>> watchStudentsIn(List<String> sectionIds);

  Stream<List<AppUser>> watchTeachersOf(String sectionId);

  Stream<AppUser?> watchUser(String uid);

  Future<List<AppUser>> fetchMany(List<String> uids);

  Future<Either<AppFailure, AppUser>> create(AppUser draft, String password);

  Future<Either<AppFailure, Unit>> update(AppUser user, {AppUser? previous});

  Future<Either<AppFailure, Unit>> updateSelf(AppUser user);

  Future<Either<AppFailure, Unit>> setActive(String uid, bool active);

  Future<Either<AppFailure, Unit>> delete(AppUser user);
}
