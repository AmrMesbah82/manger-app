/// Module: console / c1_shell
///
///*************************** FILE INFO ****************************///
/// File Name: console_side_rail.dart
/// Purpose: Declares `ConsoleSideRail` — the console's left navigation.
/// Author: Manger Plus team
/// Created: 18/9/2026
/// Updated: 19/9/2026 - Tablet rail: icons only, responsive widths, and a
///          sign-out that is an ICON and nothing else.
///
/// THE TABLET RULE
/// ---------------
/// An iPad in landscape is 1366pt wide, so the rail's old "am I cramped"
/// test said no and drew the full 248pt rail with a name, a role and a
/// sign-out button in it — a quarter of an iPad's glass spent on navigation
/// chrome, and the user card at the bottom of it was the worst of it: an
/// avatar, two lines of text and an icon, squeezed.
///
/// A tablet LAYOUT is either: a real tablet at any width, or any window —
/// macOS included — under [PlatformHelper.desktopLayoutWidth].
///
/// On a tablet the rail is ICONS. The brand mark toggles nothing, each
/// section is a glyph with a tooltip, and the account is a single sign-out
/// icon — no avatar, no name, no role, no box around it.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/helper/main_helper/platform_helper.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_padding.dart';
import 'package:manger_plus/core/theme/app_radius.dart';
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

  /// Design widths. Responsive, so the rail grows with the rest of the UI on
  /// a tablet instead of staying at desktop pixels while the type around it
  /// scales up.
  static double get expandedWidth => 248.w;
  static double get collapsedWidth => 76.w;

  @override
  Widget build(BuildContext context) {
    // A real tablet, or any window narrower than the desktop breakpoint —
    // the console in a half-width Mac window has an iPad's room and gets an
    // iPad's rail. See [PlatformHelper.isTabletLayout].
    final bool tablet = PlatformHelper.isTabletLayout(context);
    // A tablet rail is never expanded — see the file header.
    final bool shut = collapsed || tablet;
    final double width = shut ? collapsedWidth : expandedWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: width,
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
          minWidth: width - 1,
          maxWidth: width - 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(AppPadding.h, 20.h, AppPadding.h, 16.h),
                child: InkWell(
                  // Nothing to toggle on a tablet: the rail has one shape
                  // there, and a logo that silently does nothing when tapped
                  // is worse than a logo that is not tappable.
                  onTap: tablet ? null : onToggle,
                  borderRadius: AppRadius.buttonR,
                  child: Center(
                    child: shut
                        ? BrandMark(size: 38, showName: false)
                        : BrandMark(size: 40),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: AppPadding.h),
                  children: <Widget>[
                    for (final ConsoleSection section in sections)
                      _RailItem(
                        section: section,
                        active: section == current,
                        collapsed: shut,
                        onTap: () => onSelected(section),
                      ),
                  ],
                ),
              ),
              _UserCard(
                user: user,
                collapsed: shut,
                onSignOut: onSignOut,
              ),
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
      padding: EdgeInsets.only(bottom: 4.h),
      child: Material(
        color:
            active ? AppColors.primary.withOpacity(0.1) : AppColors.transparent,
        borderRadius: AppRadius.buttonR,
        child: InkWell(
          borderRadius: AppRadius.buttonR,
          onTap: onTap,
          child: SizedBox(
            // A touch target, not a pointer target: 46 design pixels is 46 on
            // the desktop and ~60 on a tablet, where the finger is.
            height: 46.h,
            child: Row(
              mainAxisAlignment:
                  collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: <Widget>[
                if (!collapsed) SizedBox(width: 14.w),
                AppIcon(
                  active ? section.activeIcon : section.icon,
                  color: fg,
                  size: 22.sp,
                ),
                if (!collapsed) ...<Widget>[
                  SizedBox(width: 12.w),
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
      icon: AppIcon(Icons.logout_rounded, color: AppColors.red, size: 22.sp),
    );

    // COLLAPSED (every tablet, and a narrow desktop window): the sign-out
    // GLYPH alone. No avatar, no name, no role, and no panel behind it —
    // stacking those into a 76pt column was the thing that read as broken.
    if (collapsed) {
      return Padding(
        padding: EdgeInsets.fromLTRB(AppPadding.h, 4.h, AppPadding.h, 12.h),
        child: Center(child: signOut),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 12.sp),
      padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 10.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.containerR,
      ),
      child: Row(
        children: <Widget>[
          AppAvatar(name: user.displayName, size: 38),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
