/// Module: settings / se1_settings
///
///*************************** FILE INFO ****************************///
/// File Name: settings_body.dart
/// Purpose: Declares `SettingsBody` — the settings list every role shares,
///          on desktop and on the phone.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:manger_plus/core/constants/app_assets.dart';
import 'package:manger_plus/core/custom/11-custom_confirm_dialog.dart';
import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/custom/61-custom_color_picker.dart';
import 'package:manger_plus/core/helper/main_helper/platform_helper.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_padding.dart';
import 'package:manger_plus/core/theme/app_radius.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/core/theme/haptic_controller.dart';
import 'package:manger_plus/core/theme/theme_controller.dart';
import 'package:manger_plus/features/onboarding/o1_splash/presentation/ui/pages/splash_screen.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/user_role.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/presentation/controller/session_controller.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';
import 'package:manger_plus/core/custom/112-powered_by_footer.dart';

class SettingsBody extends StatelessWidget {
  const SettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final ThemeController theme = ThemeController.to;

    return Obx(() {
      final AppUser user = SessionController.to.current;
      final bool dark = theme.isDarkMode.value;
      final bool arabic = theme.languageCode.value == 'ar';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ── Account ─────────────────────────────────────────────────────
          Surface(
            padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 18.r),
            child: Row(
              children: <Widget>[
                AppAvatar(name: user.displayName, size: 56),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(user.displayName, style: StyleText.fontSize18Weight600),
                      Text(user.email,
                          style: StyleText.fontSize13Weight400
                              .copyWith(color: AppColors.secondaryText)),
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: AppRadius.buttonR,
                        ),
                        child: Text(
                          user.role.label(context),
                          style: StyleText.fontSize12Weight600.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // ── Appearance ──────────────────────────────────────────────────
          _Group(title: s.appearance, children: <Widget>[
            _Tile(
              icon: Icons.translate_rounded,
              color: const Color(0xff3B82F6),
              title: s.language,
              subtitle: arabic ? 'العربية' : 'English',
              trailing: TextButton(
                onPressed: theme.toggleLanguage,
                child: Text(arabic ? 'English' : 'العربية',
                    style: StyleText.fontSize13Weight600.copyWith(color: AppColors.primary)),
              ),
            ),
            _Tile(
              icon: dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: const Color(0xff6C63FF),
              title: s.darkMode,
              trailing: Switch.adaptive(
                value: dark,
                activeTrackColor: AppColors.primary,
                onChanged: theme.setDarkMode,
              ),
            ),
            if (PlatformHelper.isMobilePlatform)
              _Tile(
                icon: Icons.vibration_rounded,
                color: const Color(0xff10B981),
                title: s.haptics,
                trailing: Obx(() {
                  final HapticController h = Get.find<HapticController>();
                  return Switch.adaptive(
                    value: h.isHapticEnabled.value,
                    activeTrackColor: AppColors.primary,
                    onChanged: h.toggleHapticFeedback,
                  );
                }),
              ),
          ]),

          // ── Branding (admin) ────────────────────────────────────────────
          if (user.role == UserRole.admin) ...<Widget>[
            SizedBox(height: 16.h),
            _Group(title: s.branding, children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 14.r),
                child: CustomColorPickerSection(
                  primaryColor: theme.primaryColor.value,
                  secondaryColor: theme.secondaryColor.value,
                  onPrimaryColorSelected: (Color c) =>
                      theme.setBrandingColors(c, theme.secondaryColor.value),
                  onSecondaryColorSelected: (Color c) =>
                      theme.setBrandingColors(theme.primaryColor.value, c),
                ),
              ),
              _Tile(
                icon: Icons.restart_alt_rounded,
                color: AppColors.secondaryText,
                title: s.resetColors,
                subtitle: s.brandingLocalHint,
                onTap: theme.resetBrandingColors,
              ),
            ]),
          ],

          // ── Debug ───────────────────────────────────────────────────────
          if (kDebugMode && PlatformHelper.debugOverride != null) ...<Widget>[
            SizedBox(height: 16.h),
            _Group(title: s.developer, children: <Widget>[
              _Tile(
                icon: Icons.bug_report_outlined,
                color: AppColors.orange,
                title: s.clearDeviceOverride,
                subtitle: s.clearDeviceOverrideSub,
                onTap: () {
                  PlatformHelper.setDebugOverride(null);
                  AppRouter.signOut(context);
                },
              ),
            ]),
          ],

          SizedBox(height: 16.h),
          _Group(title: s.account, children: <Widget>[
            _Tile(
              icon: Icons.logout_rounded,
              color: AppColors.red,
              title: s.signOut,
              onTap: () => showConfirmDialog(
                context: context,
                title: s.signOutQuestion,
                subtitle: s.signOutBody,
                confirmLabel: s.signOut,
                cancelLabel: s.cancel,
                lottieAsset: AppAssets.lottieLogout,
                onConfirm: () => AppRouter.signOut(context),
              ),
            ),
          ]),
          SizedBox(height: 24.h),
          Center(
            child: Text(
              '${s.appName} · v1.0.0',
              style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
            ),
          ),
          SizedBox(height: 8.h),
          const PoweredByFooter(),
        ],
      );
    });
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsetsDirectional.only(start: AppPadding.h, bottom: 8.h),
          child: Text(title,
              style: StyleText.fontSize13Weight600.copyWith(color: AppColors.secondaryText)),
        ),
        Surface(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: TypeBadge(icon: icon, color: color, size: 38),
      title: Text(title, style: StyleText.fontSize14Weight600),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!,
              style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
      trailing: trailing ?? (onTap == null ? null : const AppIcon(Icons.chevron_right_rounded)),
    );
  }
}
