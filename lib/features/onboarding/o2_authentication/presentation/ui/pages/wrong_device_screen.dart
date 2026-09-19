/// Module: onboarding / o2_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: wrong_device_screen.dart
/// Purpose: Declares `WrongDeviceScreen` — shown when an account signs in on
///          a device its role may not use.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:manger_plus/core/constants/app_assets.dart';
import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/custom/32-custom_svg.dart';
import 'package:manger_plus/core/helper/main_helper/platform_helper.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_padding.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/onboarding/o1_splash/presentation/ui/pages/splash_screen.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/data/repository/auth_repository.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/user_role.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/presentation/ui/pages/sign_in_screen.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

/// "Students and parents use the phone app; teachers and admins use the
/// desktop console." One sentence, one button to sign out.
///
/// In DEBUG builds a second button pretends this device is the other kind,
/// so the whole system can be tested on one computer. Release builds never
/// show it (see PlatformHelper.debugOverride).
class WrongDeviceScreen extends StatelessWidget {
  const WrongDeviceScreen({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool needsMobile = user.role.allowedOn == DeviceKind.mobile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 24.r),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 460.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 180.h,
                  child: const CustomSvgImage.natural(
                    assetPath: AppAssets.illustrationChecklist,
                  ),
                ),
                SizedBox(height: 24.h),
                AppIcon(
                  needsMobile ? Icons.phone_iphone_rounded : Icons.desktop_mac_rounded,
                  size: 40.sp,
                  color: AppColors.primary,
                ),
                SizedBox(height: 12.h),
                Text(
                  needsMobile ? s.wrongDeviceMobileTitle : s.wrongDeviceDesktopTitle,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize22Weight600,
                ),
                SizedBox(height: 8.h),
                Text(
                  needsMobile
                      ? s.wrongDeviceMobileBody(user.role.label(context))
                      : s.wrongDeviceDesktopBody(user.role.label(context)),
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight400
                      .copyWith(color: AppColors.secondaryText),
                ),
                SizedBox(height: 28.h),
                AppButton(
                  label: s.signOut,
                  icon: Icons.logout_rounded,
                  expand: true,
                  onPressed: () async {
                    final NavigatorState nav = Navigator.of(context);
                    await AuthRepository().signOut();
                    nav.pushAndRemoveUntil(
                      MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
                      (Route<dynamic> _) => false,
                    );
                  },
                ),
                if (kDebugMode) ...<Widget>[
                  SizedBox(height: 12.h),
                  AppButton(
                    label: s.debugPreviewAnyway,
                    icon: Icons.bug_report_outlined,
                    kind: AppButtonKind.subtle,
                    expand: true,
                    onPressed: () {
                      PlatformHelper.setDebugOverride(user.role.allowedOn);
                      AppRouter.go(context, user);
                    },
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    s.debugPreviewHint,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.secondaryText),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
