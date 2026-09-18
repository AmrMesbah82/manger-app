/// Module: core/helper
///
///*************************** FILE INFO ****************************///
/// File Name: platform_helper.dart
/// Purpose: Declares `DeviceKind` and `PlatformHelper` — which kind of device
///          this build is running on, and which roles may use it.
/// Author: Manger Plus team
/// Created: 18/9/2026
///
/// THE RULE
/// --------
///   * Students and parents  -> phone or tablet ONLY.
///   * Teachers and admins   -> desktop OR tablet (never a phone).
///
/// A tablet is a phone-or-tablet build whose SHORTEST side is at least
/// [tabletBreakpoint], so an iPad counts in either orientation and a phone in
/// landscape never does.
///
/// "Phone or tablet" is decided by the PLATFORM, not the width: an iPad in
/// landscape is 1366pt wide and is still a tablet. Android and iOS are always
/// mobile; macOS, Windows and Linux are always desktop. The web has no
/// platform to ask, so there the width decides (>= [webDesktopWidth]).
///
/// The rule itself — which role may use which kind — lives on `UserRole`
/// (`allowedOn`). This file only answers "what am I running on".

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_storage/get_storage.dart';

import 'package:manger_plus/core/constants/app_keys.dart';

enum DeviceKind {
  /// Phone or tablet.
  mobile,

  /// macOS / Windows / Linux, or a wide browser window.
  desktop,
}

abstract final class PlatformHelper {
  const PlatformHelper._();

  /// Below this width a web build counts as a phone/tablet.
  static const double webDesktopWidth = 1100;

  /// Width from which the MOBILE apps switch to their tablet layout
  /// (two-column grids, wider cards). Same figure as `context.isTablet`.
  static const double tabletBreakpoint = 600;

  static bool get isWeb => kIsWeb;

  static bool get isMobilePlatform {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  static bool get isDesktopPlatform {
    if (kIsWeb) return false;
    try {
      return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
    } catch (_) {
      return false;
    }
  }

  /// What this build is, for the width in [context] (only the web needs it).
  static DeviceKind kindOf(BuildContext context) {
    final DeviceKind? forced = debugOverride;
    if (forced != null) return forced;

    if (isMobilePlatform) return DeviceKind.mobile;
    if (isDesktopPlatform) return DeviceKind.desktop;
    return MediaQuery.of(context).size.width >= webDesktopWidth
        ? DeviceKind.desktop
        : DeviceKind.mobile;
  }

  /// Same answer from a raw width, for code above `MediaQuery` (main.dart).
  static DeviceKind kindForWidth(double width) {
    final DeviceKind? forced = debugOverride;
    if (forced != null) return forced;

    if (isMobilePlatform) return DeviceKind.mobile;
    if (isDesktopPlatform) return DeviceKind.desktop;
    return width >= webDesktopWidth ? DeviceKind.desktop : DeviceKind.mobile;
  }

  /// True on an iPad / Android tablet (or a narrow-but-not-phone browser).
  static bool isTablet(BuildContext context) =>
      kindOf(context) == DeviceKind.mobile &&
      MediaQuery.sizeOf(context).shortestSide >= tabletBreakpoint;

  /// Where the admin / teacher console may run: a desktop, or a tablet.
  static bool canRunConsole(BuildContext context) =>
      kindOf(context) == DeviceKind.desktop || isTablet(context);

  // ── Debug override ───────────────────────────────────────────────────────
  //
  // Testing the student app normally needs a phone. In DEBUG builds only, the
  // "wrong device" screen offers a button that pretends this machine is the
  // other kind, so the whole system can be clicked through on one Mac.
  // Release builds ignore the stored value completely.

  static DeviceKind? get debugOverride {
    if (!kDebugMode) return null;
    try {
      final String? value = GetStorage().read(AppKeys.debugDeviceOverride);
      if (value == DeviceKind.mobile.name) return DeviceKind.mobile;
      if (value == DeviceKind.desktop.name) return DeviceKind.desktop;
    } catch (_) {}
    return null;
  }

  static void setDebugOverride(DeviceKind? kind) {
    if (!kDebugMode) return;
    try {
      if (kind == null) {
        GetStorage().remove(AppKeys.debugDeviceOverride);
      } else {
        GetStorage().write(AppKeys.debugDeviceOverride, kind.name);
      }
    } catch (_) {}
  }
}
