/// Module: console / c4_dashboard
///
///*************************** FILE INFO ****************************///
/// File Name: stat_tile.dart
/// Purpose: Declares `StatTile` and `TileGrid` — one number on the dashboard.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_padding.dart';
import 'package:manger_plus/core/theme/app_theme.dart';

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.valueSuffix = '',
    this.caption,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;

  /// Null while loading — shows a dash rather than a misleading zero.
  final int? value;

  /// Appended to [value] when it is not null — '%' for a rate tile. Kept
  /// separate from [value] so the number itself stays an int and the tile
  /// still shows a dash rather than a bare '%' while loading.
  final String valueSuffix;
  final String? caption;
  final VoidCallback? onTap;

  /// Below this width the tile drops the badge beside the number and stacks
  /// instead — four tiles across one tablet row leave about 160pt each, and a
  /// 48pt badge plus "Attendance rate" does not fit in that beside each other.
  static const double _wideTile = 240;

  @override
  Widget build(BuildContext context) {
    final String shown = value == null ? '—' : '$value$valueSuffix';

    return Surface(
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 12.sp),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final bool wide = c.maxWidth >= _wideTile;

          final Widget label_ = Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (wide
                    ? StyleText.fontSize13Weight500
                    : StyleText.fontSize11Weight500)
                .copyWith(color: AppColors.secondaryText),
          );
          final Widget? caption_ = caption == null
              ? null
              : Text(
                  caption!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (wide
                          ? StyleText.fontSize12Weight400
                          : StyleText.fontSize10Weight400)
                      .copyWith(color: color),
                );

          if (wide) {
            return Row(
              children: <Widget>[
                SizedBox(width: 6.w),
                TypeBadge(icon: icon, color: color, size: 48),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // scaleDown, not a fixed size: a tile with a caption is
                      // three lines in the height a two-line tile was drawn
                      // for, and the number is the line that can afford to
                      // give way. This is what overflowed by 5px before.
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(shown, style: StyleText.fontSize26Weight600),
                        ),
                      ),
                      label_,
                      if (caption_ != null) caption_,
                    ],
                  ),
                ),
              ],
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(
                child: Row(
                  children: <Widget>[
                    TypeBadge(icon: icon, color: color, size: 26),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          shown,
                          maxLines: 1,
                          style: StyleText.fontSize20Weight600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              label_,
              if (caption_ != null) caption_,
            ],
          );
        },
      ),
    );
  }
}

/// The app's one card grid.
///
/// REBUILT 19/9/2026. This used to be a [Wrap] that divided its own width by
/// [minWidth]: every page that showed cards re-derived a column count, and a
/// tablet — whose window is as wide as a laptop's and whose cards must not be
/// as small — got the laptop answer. It is a `GridView` on
/// [CrossAxisCountHelper.gridDelegate] now, so the count, the gaps and the
/// cell height come from the same place the tables' card mode gets them.
///
/// [minWidth] survives as the floor: the window-wide count is brought down
/// when this grid is living in a narrow panel.
class TileGrid extends StatelessWidget {
  const TileGrid({
    super.key,
    required this.children,
    this.minWidth = 220,
    this.tileHeight,
    this.columns,
  });

  final List<Widget> children;
  final double minWidth;

  /// Pins the number of columns, ignoring both the window count and
  /// [minWidth]. For a row of tiles that BELONGS on one line — the four
  /// dashboard numbers — where the answer is "four", not "as many as fit".
  final int? columns;

  /// Every tile's height, in design pixels (scaled by `.h` here). Defaults to
  /// [defaultTileHeight] — a grid cell must have ONE height, which is the
  /// point of it: cards that line up rather than a ragged pile.
  final double? tileHeight;

  static const double defaultTileHeight = 120;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        return GridView.builder(
          // Every one of these grids lives inside a page that already
          // scrolls.
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: columns != null
              ? SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns! < 1 ? 1 : columns!,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  mainAxisExtent: (tileHeight ?? defaultTileHeight).h,
                )
              : CrossAxisCountHelper.gridDelegate(
                  context,
                  mainAxisExtent: tileHeight ?? defaultTileHeight,
                  minCellWidth: minWidth,
                  availableWidth: c.maxWidth,
                ),
          itemCount: children.length,
          itemBuilder: (BuildContext context, int index) => children[index],
        );
      },
    );
  }
}
