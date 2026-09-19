/// Module: console / c3_settings
///
///*************************** FILE INFO ****************************///
/// File Name: console_settings_page.dart
/// Purpose: Declares `ConsoleSettingsPage` — [SettingsBody] in the console
///          frame, plus the two cards the retired Overview page used to hold.
/// Author: Manger Plus team
/// Created: 18/9/2026
/// Updated: 18/9/2026 — Overview was removed and the Dashboard took its place.
///          Its analytics moved to the Dashboard; the demo-data tool and the
///          teacher's permission list landed here, which is where an account
///          question and a destructive tool both belong.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:manger_plus/features/console/c1_shell/presentation/ui/widgets/console_page.dart';
import 'package:manger_plus/features/console/c3_settings/presentation/ui/widgets/demo_data_card.dart';
import 'package:manger_plus/features/console/c3_settings/presentation/ui/widgets/permissions_card.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/user_role.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/presentation/controller/session_controller.dart';
import 'package:manger_plus/features/settings/se1_settings/presentation/ui/widgets/settings_body.dart';
import 'package:manger_plus/generated/l10n.dart';

class ConsoleSettingsPage extends StatelessWidget {
  const ConsoleSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final AppUser user = SessionController.to.current;
      final bool isAdmin = user.role == UserRole.admin;

      return ConsolePage(
        title: S.of(context).settings,
        scrollable: true,
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 640.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SettingsBody(),
                SizedBox(height: 24.h),
                if (isAdmin)
                  const DemoDataCard()
                else
                  PermissionsCard(teacher: user),
              ],
            ),
          ),
        ),
      );
    });
  }
}
