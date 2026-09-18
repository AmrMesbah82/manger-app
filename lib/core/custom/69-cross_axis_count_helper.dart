/// Module: core / custom
///
///*************************** FILE INFO ****************************///
/// File Name: 69-cross_axis_count_helper.dart
/// Purpose: Declares `CrossAxisCountHelper` — how many cards fit in a row.
/// Author: Manger Plus team
/// Created: 3/9/2026
///
/// Ported from knowticed_plus with one deliberate change: the original branches
/// on `Platform.isMacOS || isWindows || isLinux`, which THROWS on web because
/// `dart:io` has no Platform there. Wash ships a web build of the console, so
/// this reads the window instead — the thing the layout actually depends on.

import 'package:flutter/material.dart';

abstract class CrossAxisCountHelper {
  /// Breakpoints, in logical pixels. Named so a change here reads as a design
  /// decision rather than a magic number edit.
  static const double phone = 600;
  static const double tablet = 900;
  static const double laptop = 1366;
  static const double desktop = 1920;

  /// Columns for a standard record card (~260–320 wide at every step).
  static int forCards(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    if (width >= desktop) return 5;
    if (width >= laptop) return 4;
    if (width >= tablet) return 3;
    if (width >= phone) return 2;
    return 1;
  }

  /// Columns for a compact tile — the stat row on the overview page, where the
  /// content is a number and a word rather than a paragraph.
  static int forTiles(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    if (width >= desktop) return 6;
    if (width >= laptop) return 4;
    if (width >= tablet) return 3;
    if (width >= phone) return 2;
    return 1;
  }

  /// Columns that keep every cell at least [minCellWidth] wide inside a box of
  /// [availableWidth]. Prefer this inside a `LayoutBuilder`: it measures the
  /// space the grid actually got, not the whole window, so a grid in a
  /// half-width panel does not lay out as if it owned the screen.
  static int forWidth(
    double availableWidth, {
    double minCellWidth = 280,
    double spacing = 16,
    int max = 6,
  }) {
    if (availableWidth <= 0) return 1;
    final int fits =
        ((availableWidth + spacing) / (minCellWidth + spacing)).floor();
    return fits.clamp(1, max);
  }
}
