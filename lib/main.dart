/// Module: app entry
///
///*************************** FILE INFO ****************************///
/// File Name: main.dart
/// Purpose: App bootstrap — storage, Firebase, controllers, screen util,
///          splash.
/// Author: Manger Plus team
/// Created: 18/9/2026 - Ported from wash_application.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:manger_plus/core/constants/app_constants.dart';
import 'package:manger_plus/core/helper/main_helper/platform_helper.dart';
import 'package:manger_plus/core/network/app_firebase.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/core/theme/haptic_controller.dart';
import 'package:manger_plus/core/theme/theme_controller.dart';
import 'package:manger_plus/features/onboarding/o1_splash/presentation/ui/pages/splash_screen.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/presentation/controller/session_controller.dart';
import 'package:manger_plus/generated/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Storage first — the theme controller reads it during construction.
  await GetStorage.init();

  // Never throws: a Firebase that will not start sets `notConfigured`, and the
  // sign-in screen says so.
  await AppFirebase.initialize();

  Get.put(ThemeController(), permanent: true);
  Get.put(HapticController(), permanent: true);
  Get.put(SessionController(), permanent: true);

  runApp(const MangerPlusApp());
}

class MangerPlusApp extends StatelessWidget {
  const MangerPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width =
            constraints.maxWidth > 0 ? constraints.maxWidth : 1440;
        final double height =
            constraints.maxHeight > 0 ? constraints.maxHeight : 900;

        return _buildApp(_designSizeFor(width, height));
      },
    );
  }

  /// The ScreenUtil canvas, per device kind:
  ///
  ///  * Desktop console — the live window size, so the scale is exactly 1 and
  ///    `.sp` text matches the raw-pixel layout (the lesson wash_application
  ///    learned the hard way).
  ///  * Phone — the 390×844 canvas every `.sp` in core/custom was drawn on.
  ///  * Tablet — the window shrunk by 1.3, i.e. everything 30% larger than on
  ///    a desktop. A 390 canvas on a 1024-wide iPad would scale text 2.6×.
  static Size _designSizeFor(double width, double height) {
    if (PlatformHelper.kindForWidth(width) == DeviceKind.desktop) {
      return Size(width, height);
    }
    if (width >= PlatformHelper.tabletBreakpoint) {
      return Size(width / 1.3, height / 1.3);
    }
    return AppConstants.designSize;
  }

  Widget _buildApp(Size designSize) {
    final ThemeController theme = ThemeController.to;

    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return Obx(() {
          final bool isDark = theme.isDarkMode.value;
          final String language = theme.languageCode.value;

          AppTheme.isDark = isDark;
          AppColors.currentThemeColors =
              isDark ? AppTheme.darkThemeColors : AppTheme.lightThemeColors;

          return GetMaterialApp(
            onGenerateTitle: (BuildContext context) => S.of(context).appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            locale: Locale(language),
            fallbackLocale: const Locale('en'),
            localizationsDelegates: const <LocalizationsDelegate<Object>>[
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.supportedLocales,
            builder: (BuildContext context, Widget? widget) => Directionality(
              textDirection:
                  language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              child: widget ?? const SizedBox.shrink(),
            ),
            home: const SplashScreen(),
          );
        });
      },
    );
  }
}
