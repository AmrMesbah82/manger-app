/// Module: console / c4_dashboard
///
///*************************** FILE INFO ****************************///
/// File Name: stat_tile.dart
/// Purpose: Declares `StatTile` and `TileGrid` — one number on the dashboard.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/material.dart';

import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    return Surface(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: <Widget>[
          TypeBadge(icon: icon, color: color, size: 48),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  value == null ? '—' : '$value$valueSuffix',
                  style: StyleText.fontSize26Weight600,
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize13Weight500
                      .copyWith(color: AppColors.secondaryText),
                ),
                if (caption != null)
                  Text(
                    caption!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize12Weight400.copyWith(color: color),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lays tiles out in as many columns as fit, each at least [minWidth] wide.
class TileGrid extends StatelessWidget {
  const TileGrid({
    super.key,
    required this.children,
    this.minWidth = 220,
    this.tileHeight,
  });

  final List<Widget> children;
  final double minWidth;

  /// Gives every tile the same height.
  ///
  /// ADDED 18/9/2026. This is a [Wrap], and a Wrap sizes each child on its
  /// own — so a card carrying a due date came out taller than the one beside
  /// it and the grid read as a ragged pile rather than a grid. Set this and
  /// the cards line up, with each card free to pin its own footer to the
  /// bottom of the space.
  ///
  /// Leave it null where the tiles are already uniform, such as a row of
  /// [StatTile]s, so they keep sizing to their own content.
  final double? tileHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final int columns = (c.maxWidth / minWidth).floor().clamp(1, 6);
        const double gap = 16;
        final double width = (c.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final Widget child in children)
              SizedBox(width: width, height: tileHeight, child: child),
          ],
        );
      },
    );
  }
}
