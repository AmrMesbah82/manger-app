/// Module: onboarding / o2_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: auth_repository.dart
/// Purpose: Declares `AuthRepository` and `UsersRepository`.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/core/network/app_firebase.dart';
import 'package:manger_plus/core/network/guard.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/data/data_source/remote_data_source/users_remote_data_source.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/base_repository/auth_base_repository.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/auth_failure_type.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/user_role.dart';

void _log(String message) {
  if (kDebugMode) debugPrint('[auth] $message');
}

class AuthRepository implements AuthBaseRepository {
  AuthRepository({UsersRemoteDataSource? remote})
      : _remote = remote ?? UsersRemoteDataSource();

  final UsersRemoteDataSource _remote;

  /// Nothing waits forever: a missing Firestore database looks like a spinner
  /// that never stops unless something puts a limit on it.
  static const Duration _timeout = Duration(seconds: 20);

  @override
  Future<Either<AuthFailureType, AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    if (AppFirebase.notConfigured) {
      return const Left(AuthFailureType.notConfigured);
    }

    try {
      final UserCredential credential =
          await _remote.signIn(email, password).timeout(_timeout);
      final User? authUser = credential.user;
      if (authUser == null) return const Left(AuthFailureType.unknown);
      _log('auth OK uid=${authUser.uid}');

      // The profile read is a separate failure domain from the sign-in —
      // folding both into one catch turns "no Firestore database" into a
      // misleading "no connection".
      final AppUser? profile;
      try {
        profile = await _remote.fetch(authUser.uid).timeout(_timeout);
      } on TimeoutException {
        await _remote.signOut();
        return const Left(AuthFailureType.firestoreUnavailable);
      } on FirebaseException catch (error) {
        _log('profile read failed: ${error.code}');
        await _remote.signOut();
        return Left(error.code == 'permission-denied'
            ? AuthFailureType.rulesDenied
            : AuthFailureType.firestoreUnavailable);
      }

      if (profile == null) {
        await _remote.signOut();
        return const Left(AuthFailureType.profileMissing);
      }
      if (!profile.active) {
        await _remote.signOut();
        return const Left(AuthFailureType.accountInactive);
      }
      return Right(profile);
    } on TimeoutException {
      return const Left(AuthFailureType.network);
    } on FirebaseAuthException catch (error) {
      _log('auth failed: ${error.code}');
      return Left(AuthFailureType.fromCode(error.code));
    } catch (error) {
      _log('unexpected: $error');
      return const Left(AuthFailureType.unknown);
    }
  }

  @override
  Future<AppUser?> restoreSession() async {
    if (AppFirebase.notConfigured) return null;
    final User? current = _remote.currentUser;
    if (current == null) return null;
    try {
      final AppUser? profile = await _remote.fetch(current.uid).timeout(_timeout);
      if (profile == null || !profile.active) return null;
      return profile;
    } catch (error) {
      _log('restoreSession failed: $error');
      return null;
    }
  }

  @override
  Future<bool> isSetupDone() async {
    if (AppFirebase.notConfigured) return true;
    try {
      return await _remote.isSetupDone().timeout(_timeout);
    } catch (_) {
      // Unknown is treated as done: the worst case is hiding a setup button
      // on a project that needs it, never offering it on one that does not.
      return true;
    }
  }

  @override
  Future<Either<AuthFailureType, AppUser>> createFirstAdmin({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (AppFirebase.notConfigured) {
      return const Left(AuthFailureType.notConfigured);
    }
    if (await isSetupDone()) return const Left(AuthFailureType.setupAlreadyDone);

    try {
      final AppUser admin = await _remote.createFirstAdmin(
        fullName: fullName,
        email: email,
        password: password,
      );
      return Right(admin);
    } on FirebaseAuthException catch (error) {
      return Left(AuthFailureType.fromCode(error.code));
    } on FirebaseException catch (error) {
      _log('createFirstAdmin: ${error.code}');
      // The account was created but the batch was refused: sign out so the
      // next attempt starts clean.
      await _remote.signOut();
      return Left(error.code == 'permission-denied'
          ? AuthFailureType.setupAlreadyDone
          : AuthFailureType.firestoreUnavailable);
    } catch (_) {
      return const Left(AuthFailureType.unknown);
    }
  }

  @override
  Future<Either<AuthFailureType, Unit>> sendPasswordReset(String email) async {
    try {
      await _remote.sendPasswordReset(email);
      return const Right(unit);
    } on FirebaseAuthException catch (error) {
      return Left(AuthFailureType.fromCode(error.code));
    } catch (_) {
      return const Left(AuthFailureType.unknown);
    }
  }

  @override
  Future<void> signOut() => _remote.signOut();
}

class UsersRepository implements UsersBaseRepository {
  UsersRepository({UsersRemoteDataSource? remote})
      : _remote = remote ?? UsersRemoteDataSource();

  final UsersRemoteDataSource _remote;

  @override
  Stream<List<AppUser>> watchByRole(UserRole role) => _remote.watchByRole(role);

  @override
  Stream<List<AppUser>> watchStudentsIn(List<String> sectionIds) =>
      _remote.watchStudentsIn(sectionIds);

  @override
  Stream<List<AppUser>> watchTeachersOf(String sectionId) =>
      _remote.watchTeachersOf(sectionId);

  @override
  Stream<AppUser?> watchUser(String uid) => _remote.watch(uid);

  @override
  Future<List<AppUser>> fetchMany(List<String> uids) => _remote.fetchMany(uids);

  @override
  Future<Either<AppFailure, AppUser>> create(
    AppUser draft,
    String password,
  ) =>
      guard(() => _remote.create(draft, password));

  @override
  Future<Either<AppFailure, Unit>> update(AppUser user, {AppUser? previous}) =>
      guardUnit(() => _remote.update(user, previous: previous));

  @override
  Future<Either<AppFailure, Unit>> updateSelf(AppUser user) =>
      guardUnit(() => _remote.updateSelf(user));

  @override
  Future<Either<AppFailure, Unit>> setActive(String uid, bool active) =>
      guardUnit(() => _remote.setActive(uid, active));

  @override
  Future<Either<AppFailure, Unit>> delete(AppUser user) =>
      guardUnit(() => _remote.delete(user));
}
