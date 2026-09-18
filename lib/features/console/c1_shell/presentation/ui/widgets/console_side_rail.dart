/// Module: console / c1_shell
///
///*************************** FILE INFO ****************************///
/// File Name: console_side_rail.dart
/// Purpose: Declares `ConsoleSideRail` — the console's left navigation.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/material.dart';

import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/console/c1_shell/presentation/controller/console_section.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/user_role.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/presentation/ui/widgets/brand_mark.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

class ConsoleSideRail extends StatelessWidget {
  const ConsoleSideRail({
    super.key,
    required this.user,
    required this.sections,
    required this.current,
    required this.collapsed,
    required this.onSelected,
    required this.onToggle,
    required this.onSignOut,
  });

  final AppUser user;
  final List<ConsoleSection> sections;
  final ConsoleSection current;
  final bool collapsed;
  final ValueChanged<ConsoleSection> onSelected;
  final VoidCallback onToggle;
  final VoidCallback onSignOut;

  static const double expandedWidth = 248;
  static const double collapsedWidth = 76;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: collapsed ? collapsedWidth : expandedWidth,
      decoration: BoxDecoration(
        color: AppColors.card,
        border: BorderDirectional(
          end: BorderSide(color: AppColors.borderGrey.withOpacity(0.35)),
        ),
      ),
      // The width animates, but `collapsed` flips at once: laid out at the
      // container's in-between width, the expanded rows overflowed (by ~9px)
      // for the length of the animation. Laying out at the target width and
      // clipping keeps every frame clean.
      child: ClipRect(
        child: OverflowBox(
          alignment: AlignmentDirectional.topStart,
          // -1 for the end border drawn inside the container.
          minWidth: (collapsed ? collapsedWidth : expandedWidth) - 1,
          maxWidth: (collapsed ? collapsedWidth : expandedWidth) - 1,
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(collapsed ? 16 : 20, 24, 12, 20),
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(12),
              child: collapsed
                  ? const BrandMark(size: 42, showName: false)
                  : const BrandMark(size: 40),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: <Widget>[
                for (final ConsoleSection section in sections)
                  _RailItem(
                    section: section,
                    active: section == current,
                    collapsed: collapsed,
                    onTap: () => onSelected(section),
                  ),
              ],
            ),
          ),
          _UserCard(user: user, collapsed: collapsed, onSignOut: onSignOut),
        ],
      ),
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.section,
    required this.active,
    required this.collapsed,
    required this.onTap,
  });

  final ConsoleSection section;
  final bool active;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg = active ? AppColors.primary : AppColors.secondaryText;
    final Widget tile = Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: active ? AppColors.primary.withOpacity(0.1) : AppColors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            height: 46,
            child: Row(
              mainAxisAlignment:
                  collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: <Widget>[
                if (!collapsed) const SizedBox(width: 14),
                AppIcon(active ? section.activeIcon : section.icon, color: fg, size: 22),
                if (!collapsed) ...<Widget>[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      section.label(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: (active
                              ? StyleText.fontSize14Weight600
                              : StyleText.fontSize14Weight500)
                          .copyWith(color: active ? AppColors.text : fg),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    return collapsed
        ? Tooltip(message: section.label(context), child: tile)
        : tile;
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.collapsed,
    required this.onSignOut,
  });

  final AppUser user;
  final bool collapsed;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final Widget signOut = IconButton(
      tooltip: S.of(context).signOut,
      onPressed: onSignOut,
      icon: AppIcon(Icons.logout_rounded, color: AppColors.red, size: 20),
    );

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: collapsed
          ? Column(
              children: <Widget>[
                AppAvatar(name: user.displayName, size: 36),
                signOut,
              ],
            )
          : Row(
              children: <Widget>[
                AppAvatar(name: user.displayName, size: 38),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        user.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize13Weight600,
                      ),
                      Text(
                        user.role.label(context),
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                signOut,
              ],
            ),
    );
  }
}
