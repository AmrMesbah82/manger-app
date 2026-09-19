/// Module: console / c3_settings
///
///*************************** FILE INFO ****************************///
/// File Name: permissions_card.dart
/// Purpose: Declares `PermissionsCard` — what the admin allowed this teacher.
/// Author: Manger Plus team
/// Created: 18/9/2026
///
/// Moved here from the Overview page when the Dashboard replaced it. It
/// answers "why is that button missing", which is a settings question, not a
/// front-page one.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_padding.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/teacher_permission.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

class PermissionsCard extends StatelessWidget {
  const PermissionsCard({super.key, required this.teacher});

  final AppUser teacher;

  @override
  Widget build(BuildContext context) {
    return Surface(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 20.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(S.of(context).yourPermissions,
              style: StyleText.fontSize16Weight600),
          SizedBox(height: 4.h),
          Text(
            S.of(context).yourPermissionsSub,
            style: StyleText.fontSize13Weight400
                .copyWith(color: AppColors.secondaryText),
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: <Widget>[
              for (final TeacherPermission p in teacher.permissions)
                Chip(
                  avatar: AppIcon(p.icon, size: 16.sp, color: AppColors.primary),
                  label: Text(p.label(context),
                      style: StyleText.fontSize12Weight600),
                  backgroundColor: AppColors.primary.withOpacity(0.08),
                  side: BorderSide.none,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
