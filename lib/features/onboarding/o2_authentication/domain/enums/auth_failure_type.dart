/// Module: onboarding / o2_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: auth_failure_type.dart
/// Purpose: Declares `AuthFailureType` — every way signing in can fail.
/// Author: Manger Plus team
/// Created: 18/9/2026 - Ported from wash_application.

import 'package:flutter/widgets.dart';

import 'package:manger_plus/generated/l10n.dart';

/// A closed set, so the UI keeps control of the wording and can put an error
/// under the right field.
enum AuthFailureType {
  wrongCredentials,
  invalidEmail,
  emailInUse,
  weakPassword,
  userDisabled,
  tooManyRequests,
  network,

  /// Signed in to Firebase Auth, but `users/{uid}` does not exist — an
  /// account created in the Firebase console instead of by the admin.
  profileMissing,

  /// The admin switched this account off.
  accountInactive,

  /// Auth worked, then Firestore did not answer — usually no database created
  /// in the project yet.
  firestoreUnavailable,

  /// Firestore answered and the rules said no — usually rules not deployed.
  rulesDenied,

  /// The first-admin setup has already been done on this project.
  setupAlreadyDone,

  notConfigured,
  unknown;

  static AuthFailureType fromCode(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return AuthFailureType.wrongCredentials;
      case 'invalid-email':
        return AuthFailureType.invalidEmail;
      case 'email-already-in-use':
        return AuthFailureType.emailInUse;
      case 'weak-password':
        return AuthFailureType.weakPassword;
      case 'user-disabled':
        return AuthFailureType.userDisabled;
      case 'too-many-requests':
        return AuthFailureType.tooManyRequests;
      case 'network-request-failed':
      case 'unavailable':
        return AuthFailureType.network;
      case 'permission-denied':
        return AuthFailureType.rulesDenied;
      default:
        return AuthFailureType.unknown;
    }
  }

  bool get isEmailError =>
      this == AuthFailureType.invalidEmail ||
      this == AuthFailureType.emailInUse;

  bool get isPasswordError =>
      this == AuthFailureType.wrongCredentials ||
      this == AuthFailureType.weakPassword;

  String message(BuildContext context) {
    final S s = S.of(context);
    switch (this) {
      case AuthFailureType.wrongCredentials:
        return s.errWrongCredentials;
      case AuthFailureType.invalidEmail:
        return s.errInvalidEmail;
      case AuthFailureType.emailInUse:
        return s.errEmailInUse;
      case AuthFailureType.weakPassword:
        return s.errWeakPassword;
      case AuthFailureType.userDisabled:
        return s.errUserDisabled;
      case AuthFailureType.tooManyRequests:
        return s.errTooManyRequests;
      case AuthFailureType.network:
        return s.errNetwork;
      case AuthFailureType.profileMissing:
        return s.errProfileMissing;
      case AuthFailureType.accountInactive:
        return s.errAccountInactive;
      case AuthFailureType.firestoreUnavailable:
        return s.errFirestoreUnavailable;
      case AuthFailureType.rulesDenied:
        return s.errRulesDenied;
      case AuthFailureType.setupAlreadyDone:
        return s.errSetupAlreadyDone;
      case AuthFailureType.notConfigured:
        return s.errNotConfigured;
      case AuthFailureType.unknown:
        return s.errUnknown;
    }
  }
}
