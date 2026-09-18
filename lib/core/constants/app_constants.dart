/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: app_constants.dart
/// Purpose: Declares `AppConstants` — app-wide sizing, timing and copy that is
///          not tied to any one feature.
/// Author: Manger Plus team
/// Created: 18/9/2026 - Learning center edition.

import 'package:flutter/material.dart';

abstract class AppConstants {
  AppConstants._();

  /// The design canvas every `.sp` / `.h` / `.w` value is relative to on the
  /// mobile / tablet apps. The desktop console uses the live window size
  /// instead (see main.dart).
  static const Size designSize = Size(390, 844);

  /// English brand name. On screen use `S.of(context).appName`.
  static const String appName = 'Mostakbal';
  static const String appNameAr = 'مانجر بلس';

  static String appNameFor(String languageCode) =>
      languageCode == 'ar' ? appNameAr : appName;

  /// How long the splash holds on a cold start (the floor, not the length).
  static const Duration splashDuration = Duration(milliseconds: 2200);

  static const double pagePadding = 16;
  static const double cardRadius = 16;
  static const double sectionGap = 20;

  /// Minimum password length for accounts the admin creates.
  static const int minPasswordLength = 6;

  /// Password given to every account the demo-data button creates.
  static const String demoPassword = '123456';

  /// Email domain of demo accounts, so they are easy to spot and delete.
  static const String demoEmailDomain = 'demo.mangerplus.app';

  /// Max upload size accepted from the console, in megabytes.
  static const int maxUploadMb = 500;
}
