/// Module: onboarding / o2_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: session_controller.dart
/// Purpose: Declares `SessionController` — who is signed in, kept live.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'dart:async';

import 'package:get/get.dart';

import 'package:manger_plus/features/onboarding/o2_authentication/data/repository/auth_repository.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/base_repository/auth_base_repository.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';

/// The signed-in account, app-wide.
///
/// Registered permanently in `main.dart`, next to the theme controller —
/// every role's shell needs the current user, and threading it through every
/// constructor is how wash_application ended up re-reading the profile in
/// four cubits.
///
/// LIVE: after sign-in it subscribes to the user's own document. When the
/// admin flips one of a teacher's permission switches, [user] changes and the
/// teacher's console rebuilds with the section appearing or disappearing — no
/// sign-out needed. When the admin switches an account off, [onDeactivated]
/// fires and the shell signs out.
class SessionController extends GetxController {
  SessionController({
    AuthBaseRepository? auth,
    UsersBaseRepository? users,
  })  : _auth = auth ?? AuthRepository(),
        _users = users ?? UsersRepository();

  static SessionController get to => Get.find<SessionController>();

  final AuthBaseRepository _auth;
  final UsersBaseRepository _users;

  final Rxn<AppUser> user = Rxn<AppUser>();

  /// Called when the live profile says the account was switched off or
  /// deleted. Set by whichever shell is showing.
  void Function()? onDeactivated;

  StreamSubscription<AppUser?>? _sub;

  AppUser get current => user.value ?? AppUser.empty;
  String get uid => current.uid;

  /// Starts following [signedIn]'s profile document.
  void start(AppUser signedIn) {
    user.value = signedIn;
    _sub?.cancel();
    _sub = _users.watchUser(signedIn.uid).listen(
      (AppUser? live) {
        if (live == null || !live.active) {
          onDeactivated?.call();
          return;
        }
        user.value = live;
      },
      // A transient read error must not sign anybody out.
      onError: (Object _) {},
    );
  }

  Future<void> signOut() async {
    await _sub?.cancel();
    _sub = null;
    // `user` keeps its last value on purpose. Clearing it would rebuild every
    // console page still on screen during the sign-out transition with an
    // empty user — and each would open queries it is not allowed to run.
    // The next sign-in replaces it through [start].
    onDeactivated = null;
    await _auth.signOut();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
