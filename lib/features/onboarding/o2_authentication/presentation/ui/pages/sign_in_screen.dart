/// Module: onboarding / o2_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: sign_in_screen.dart
/// Purpose: Declares `SignInScreen` — one sign-in for all four roles, plus the
///          first-run "set up the center" form.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:manger_plus/core/constants/app_assets.dart';
import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/custom/2-custom_textfield.dart';
import 'package:manger_plus/core/custom/32-custom_svg.dart';
import 'package:manger_plus/core/helper/main_helper/platform_helper.dart';
import 'package:manger_plus/core/network/app_firebase.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/core/theme/theme_controller.dart';
import 'package:manger_plus/features/onboarding/o1_splash/presentation/ui/pages/splash_screen.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/presentation/controller/login_cubit.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/presentation/ui/widgets/brand_mark.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';
import 'package:manger_plus/core/custom/112-powered_by_footer.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
      create: (_) => LoginCubit()..checkSetup(),
      child: const _SignInView(),
    );
  }
}

class _SignInView extends StatefulWidget {
  const _SignInView();

  @override
  State<_SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<_SignInView> {
  /// Showing the first-admin form instead of the sign-in form.
  bool _setupMode = false;

  @override
  Widget build(BuildContext context) {
    // Tablets wide enough for it get the two-panel desktop layout too.
    final bool desktop = PlatformHelper.kindOf(context) == DeviceKind.desktop ||
        (PlatformHelper.isTablet(context) &&
            MediaQuery.sizeOf(context).width >= 900);

    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (LoginState a, LoginState b) => a.status != b.status,
      listener: (BuildContext context, LoginState state) {
        if (state.status == LoginStatus.success && state.user != null) {
          AppRouter.go(context, state.user);
        }
        if (state.status == LoginStatus.resetSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).resetEmailSent)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: desktop ? _desktop(context) : _mobile(context),
      ),
    );
  }

  Widget _form(BuildContext context) => _SignInForm(
        setupMode: _setupMode,
        onToggleSetup: () {
          context.read<LoginCubit>().clearErrors();
          setState(() => _setupMode = !_setupMode);
        },
      );

  // ── Desktop: brand panel | form ──────────────────────────────────────────

  Widget _desktop(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.primary, AppColors.secondaryPrimary],
              ),
            ),
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const BrandMark(size: 52, onDark: true),
                const Spacer(),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420, maxHeight: 340),
                    child: const CustomSvgImage.natural(
                      assetPath: AppAssets.illustrationLearning,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  S.of(context).consoleHeadline,
                  style: StyleText.fontSize28Weight600.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  S.of(context).consoleSubheadline,
                  style: StyleText.fontSize15Weight400.copyWith(color: Colors.white70),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Stack(
            children: <Widget>[
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(40),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: _form(context),
                  ),
                ),
              ),
              const PositionedDirectional(top: 20, end: 20, child: _LanguageToggle()),
            ],
          ),
        ),
      ],
    );
  }

  // ── Phone / tablet: gradient header over the form ────────────────────────

  Widget _mobile(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 40.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.primary, AppColors.secondaryPrimary],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(36.r)),
            ),
            child: Column(
              children: <Widget>[
                const Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: _LanguageToggle(onDark: true),
                ),
                const BrandMark(size: 64, vertical: true, onDark: true),
                SizedBox(height: 20.h),
                SizedBox(
                  height: 150.h,
                  child: const CustomSvgImage.natural(
                    assetPath: AppAssets.illustrationLogin,
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 480.w),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 32.h),
                child: _form(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignInForm extends StatelessWidget {
  const _SignInForm({required this.setupMode, required this.onToggleSetup});

  final bool setupMode;
  final VoidCallback onToggleSetup;

  String? _fieldMessage(BuildContext context, LoginFieldError? error) {
    final S s = S.of(context);
    switch (error) {
      case LoginFieldError.emailEmpty:
        return s.enterEmail;
      case LoginFieldError.emailInvalid:
        return s.errInvalidEmail;
      case LoginFieldError.passwordEmpty:
        return s.enterPassword;
      case LoginFieldError.passwordShort:
        return s.errWeakPassword;
      case LoginFieldError.nameEmpty:
        return s.enterName;
      case null:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final LoginCubit cubit = context.read<LoginCubit>();
    final bool desktop = PlatformHelper.kindOf(context) == DeviceKind.desktop;
    final bool tablet = PlatformHelper.isTablet(context);

    return BlocBuilder<LoginCubit, LoginState>(
      builder: (BuildContext context, LoginState state) {
        final String? bannerMessage = state.failure == null ||
                state.failure!.isEmailError ||
                state.failure!.isPasswordError
            ? null
            : state.failure!.message(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              setupMode ? s.setupTitle : s.welcomeBack,
              style: StyleText.fontSize25Weight600,
            ),
            SizedBox(height: 6.h),
            Text(
              setupMode ? s.setupSubtitle : s.signInSubtitle,
              style: StyleText.fontSize14Weight400
                  .copyWith(color: AppColors.secondaryText),
            ),
            SizedBox(height: 24.h),
            if (AppFirebase.notConfigured) ...<Widget>[
              InfoBanner.error(s.errNotConfigured),
              SizedBox(height: 16.h),
            ],
            if (bannerMessage != null) ...<Widget>[
              InfoBanner.error(bannerMessage),
              SizedBox(height: 16.h),
            ],
            if (setupMode) ...<Widget>[
              CustomTextField(
                controller: cubit.nameController,
                label: s.fullName,
                hint: s.fullNameHint,
                errorText: _fieldMessage(context, state.nameError),
                prefixIcon: const AppIcon(Icons.person_outline_rounded),
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 14.h),
            ],
            CustomTextField(
              controller: cubit.emailController,
              label: s.email,
              hint: 'name@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              errorText: _fieldMessage(context, state.emailError) ??
                  (state.failure != null && state.failure!.isEmailError
                      ? state.failure!.message(context)
                      : null),
              prefixIcon: const AppIcon(Icons.alternate_email_rounded),
            ),
            SizedBox(height: 14.h),
            CustomTextField(
              controller: cubit.passwordController,
              label: s.password,
              hint: '••••••',
              obscureText: state.obscure,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) =>
                  setupMode ? cubit.createFirstAdmin() : cubit.signIn(),
              errorText: _fieldMessage(context, state.passwordError) ??
                  (state.failure != null && state.failure!.isPasswordError
                      ? state.failure!.message(context)
                      : null),
              prefixIcon: const AppIcon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: cubit.toggleObscure,
                icon: AppIcon(state.obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
              ),
            ),
            if (!setupMode)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: state.isSubmitting ? null : cubit.sendReset,
                  child: Text(
                    s.forgotPassword,
                    style: StyleText.fontSize13Weight600
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              )
            else
              SizedBox(height: 20.h),
            SizedBox(height: 8.h),
            AppButton(
              label: setupMode ? s.createAdminAccount : s.signIn,
              icon: setupMode ? Icons.rocket_launch_rounded : Icons.login_rounded,
              expand: true,
              loading: state.isSubmitting,
              onPressed: AppFirebase.notConfigured
                  ? null
                  : (setupMode ? cubit.createFirstAdmin : cubit.signIn),
            ),
            SizedBox(height: 18.h),
            // The first-admin door: desktop or tablet (where admins work),
            // and only while the project has no admin yet.
            if ((desktop || tablet) && state.setupDone == false)
              Center(
                child: TextButton.icon(
                  onPressed: onToggleSetup,
                  icon: AppIcon(
                    setupMode ? Icons.arrow_back_rounded : Icons.admin_panel_settings_outlined,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    setupMode ? s.backToSignIn : s.setupCenter,
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ),
            if (!setupMode)
              Text(
                desktop
                    ? s.consoleAccountsHint
                    : (tablet ? s.tabletAccountsHint : s.mobileAccountsHint),
                textAlign: TextAlign.center,
                style: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.secondaryText),
              ),
            SizedBox(height: 28.h),
            const PoweredByFooter(),
          ],
        );
      },
    );
  }
}

/// EN | ع — switches the whole app's language.
class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final ThemeController theme = ThemeController.to;
    final Color color = onDark ? Colors.white : AppColors.text;
    return Obx(
      () => TextButton.icon(
        onPressed: theme.toggleLanguage,
        icon: AppIcon(Icons.translate_rounded, color: color, size: 18),
        label: Text(
          theme.languageCode.value == 'ar' ? 'English' : 'العربية',
          style: StyleText.fontSize13Weight600.copyWith(color: color),
        ),
      ),
    );
  }
}
