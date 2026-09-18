/// Module: onboarding / o2_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: login_cubit.dart
/// Purpose: Declares `LoginCubit` and `LoginState` — sign-in, password reset
///          and first-admin setup.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import 'package:manger_plus/core/constants/app_constants.dart';
import 'package:manger_plus/core/constants/app_keys.dart';
import 'package:manger_plus/core/network/app_firebase.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/data/repository/auth_repository.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/base_repository/auth_base_repository.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/auth_failure_type.dart';

enum LoginStatus { idle, submitting, success, resetSent, failure }

/// Which local check failed, before anything reached Firebase.
enum LoginFieldError { emailEmpty, emailInvalid, passwordEmpty, passwordShort, nameEmpty }

class LoginState {
  final LoginStatus status;
  final AuthFailureType? failure;
  final LoginFieldError? emailError;
  final LoginFieldError? passwordError;
  final LoginFieldError? nameError;
  final bool obscure;

  /// Null while checking. False on a brand-new project: the sign-in screen
  /// then offers "Set up the center".
  final bool? setupDone;
  final AppUser? user;

  const LoginState({
    this.status = LoginStatus.idle,
    this.failure,
    this.emailError,
    this.passwordError,
    this.nameError,
    this.obscure = true,
    this.setupDone,
    this.user,
  });

  bool get isSubmitting => status == LoginStatus.submitting;

  LoginState copyWith({
    LoginStatus? status,
    AuthFailureType? failure,
    LoginFieldError? emailError,
    LoginFieldError? passwordError,
    LoginFieldError? nameError,
    bool? obscure,
    bool? setupDone,
    AppUser? user,
    bool clearErrors = false,
  }) {
    return LoginState(
      status: status ?? this.status,
      failure: clearErrors ? null : (failure ?? this.failure),
      emailError: clearErrors ? null : (emailError ?? this.emailError),
      passwordError: clearErrors ? null : (passwordError ?? this.passwordError),
      nameError: clearErrors ? null : (nameError ?? this.nameError),
      obscure: obscure ?? this.obscure,
      setupDone: setupDone ?? this.setupDone,
      user: user ?? this.user,
    );
  }
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({AuthBaseRepository? repository})
      : _repository = repository ?? AuthRepository(),
        super(const LoginState()) {
    emailController.text = _storage.read(AppKeys.savedEmail) ?? '';
  }

  final AuthBaseRepository _repository;
  final GetStorage _storage = GetStorage();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  bool get firebaseMissing => AppFirebase.notConfigured;

  Future<void> checkSetup() async {
    final bool done = await _repository.isSetupDone();
    if (!isClosed) emit(state.copyWith(setupDone: done));
  }

  void toggleObscure() => emit(state.copyWith(obscure: !state.obscure));

  void clearErrors() => emit(state.copyWith(clearErrors: true));

  bool _validate({bool withName = false, bool withPassword = true}) {
    final String email = emailController.text.trim();
    final String password = passwordController.text;

    LoginFieldError? emailError;
    if (email.isEmpty) {
      emailError = LoginFieldError.emailEmpty;
    } else if (!_emailPattern.hasMatch(email)) {
      emailError = LoginFieldError.emailInvalid;
    }

    LoginFieldError? passwordError;
    if (withPassword) {
      if (password.isEmpty) {
        passwordError = LoginFieldError.passwordEmpty;
      } else if (withName && password.length < AppConstants.minPasswordLength) {
        passwordError = LoginFieldError.passwordShort;
      }
    }

    final LoginFieldError? nameError =
        withName && nameController.text.trim().isEmpty
            ? LoginFieldError.nameEmpty
            : null;

    emit(LoginState(
      status: LoginStatus.idle,
      emailError: emailError,
      passwordError: passwordError,
      nameError: nameError,
      obscure: state.obscure,
      setupDone: state.setupDone,
    ));
    return emailError == null && passwordError == null && nameError == null;
  }

  Future<void> signIn() async {
    if (state.isSubmitting || !_validate()) return;
    emit(state.copyWith(status: LoginStatus.submitting, clearErrors: true));

    final Either<AuthFailureType, AppUser> result = await _repository.signIn(
      email: emailController.text,
      password: passwordController.text,
    );
    _finish(result);
  }

  Future<void> createFirstAdmin() async {
    if (state.isSubmitting || !_validate(withName: true)) return;
    emit(state.copyWith(status: LoginStatus.submitting, clearErrors: true));

    final Either<AuthFailureType, AppUser> result =
        await _repository.createFirstAdmin(
      fullName: nameController.text,
      email: emailController.text,
      password: passwordController.text,
    );
    _finish(result);
  }

  Future<void> sendReset() async {
    if (state.isSubmitting || !_validate(withPassword: false)) return;
    emit(state.copyWith(status: LoginStatus.submitting, clearErrors: true));
    final Either<AuthFailureType, Unit> result =
        await _repository.sendPasswordReset(emailController.text);
    result.fold(
      (AuthFailureType f) =>
          emit(state.copyWith(status: LoginStatus.failure, failure: f)),
      (_) => emit(state.copyWith(status: LoginStatus.resetSent)),
    );
  }

  void _finish(Either<AuthFailureType, AppUser> result) {
    result.fold(
      (AuthFailureType failure) => emit(state.copyWith(
        status: LoginStatus.failure,
        failure: failure,
      )),
      (AppUser user) {
        _storage.write(AppKeys.savedEmail, emailController.text.trim());
        passwordController.clear();
        emit(state.copyWith(status: LoginStatus.success, user: user));
      },
    );
  }

  @override
  Future<void> close() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
