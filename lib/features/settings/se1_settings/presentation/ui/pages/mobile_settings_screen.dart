/// Module: settings / se1_settings
///
///*************************** FILE INFO ****************************///
/// File Name: mobile_settings_screen.dart
/// Purpose: Declares `MobileSettingsScreen` — the Profile tab of the student
///          and parent apps.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_padding.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/settings/se1_settings/presentation/ui/widgets/settings_body.dart';
import 'package:manger_plus/generated/l10n.dart';

class MobileSettingsScreen extends StatelessWidget {
  const MobileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 640.w),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 16.r),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 16.h, top: 8.h),
                  child: Text(S.of(context).profile, style: StyleText.fontSize25Weight600),
                ),
                const SettingsBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
