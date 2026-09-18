/// Module: student / s2_library
///
///*************************** FILE INFO ****************************///
/// File Name: content_cards.dart
/// Purpose: Declares `FeatureCard`, `ContentRow` and `CategoryTile` — how a
///          piece of content looks on the phone.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/submission.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/content_type.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

/// A big gradient card for the home screen's "Continue learning" strip.
class FeatureCard extends StatelessWidget {
  const FeatureCard({super.key, required this.content, required this.onTap, this.width});

  final LearningContent content;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final Color c = content.type.color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 240.w,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[c, Color.lerp(c, Colors.black, 0.25)!],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(color: c.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 8)),
          ],
        ),
        child: Stack(
          children: <Widget>[
            // A large faded glyph behind the text — texture, not information.
            PositionedDirectional(
              end: -18.w,
              bottom: -18.h,
              child: AppIcon(content.type.icon, size: 110.sp, color: Colors.white.withOpacity(0.15)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AppIcon(content.type.icon, color: Colors.white, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text(content.type.label(context),
                          style: StyleText.fontSize11Weight600.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  content.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize16Weight700.copyWith(color: Colors.white),
                ),
                SizedBox(height: 4.h),
                Text(
                  <String>[
                    if (content.subject.isNotEmpty) content.subject,
                    if (content.teacherName.isNotEmpty) content.teacherName,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize12Weight500.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A list row: badge, title, meta, and the state on the right (score, due,
/// "new").
class ContentRow extends StatelessWidget {
  const ContentRow({
    super.key,
    required this.content,
    required this.onTap,
    this.submission,
  });

  final LearningContent content;
  final Submission? submission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final LearningContent c = content;
    final Submission? sub = submission;

    Widget trailing;
    if (sub != null) {
      trailing = _Pill(text: '${sub.percent.round()}%', color: const Color(0xff10B981));
    } else if (c.type.isAssessment && c.isOverdue) {
      trailing = _Pill(text: s.overdue, color: const Color(0xffEF4444));
    } else if (c.type.isAssessment) {
      trailing = _Pill(text: s.startNow, color: c.type.color);
    } else {
      trailing = AppIcon(Icons.chevron_right_rounded, color: AppColors.secondaryText);
    }

    return Surface(
      onTap: onTap,
      padding: EdgeInsets.all(12.r),
      child: Row(
        children: <Widget>[
          ContentTypeIcon(type: c.type, size: 50),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(c.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize14Weight600),
                SizedBox(height: 2.h),
                Text(
                  <String>[
                    c.type.label(context),
                    if (c.subject.isNotEmpty) c.subject,
                    if (c.type.isAssessment) s.questionsCount('${c.questions.length}'),
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize12Weight500.copyWith(color: AppColors.secondaryText),
                ),
                if (c.dueAt != null && sub == null) ...<Widget>[
                  SizedBox(height: 2.h),
                  Row(
                    children: <Widget>[
                      AppIcon(Icons.event_rounded,
                          size: 13.sp, color: c.isOverdue ? const Color(0xffEF4444) : c.type.color),
                      SizedBox(width: 4.w),
                      Text(
                        s.dueOn(AppDates.day(context, c.dueAt)),
                        style: StyleText.fontSize11Weight600.copyWith(
                            color: c.isOverdue ? const Color(0xffEF4444) : c.type.color),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          trailing,
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(text, style: StyleText.fontSize12Weight700.copyWith(color: color)),
    );
  }
}

/// A category shortcut on the home screen: icon, name, count.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.type,
    required this.count,
    required this.onTap,
  });

  final ContentType type;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
          // The grid cell has a fixed aspect ratio; scaleDown means the
          // content shrinks a hair instead of overflowing when text scaling
          // or a larger icon would not fit.
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ContentTypeIcon(type: type, size: 40.r),
                  SizedBox(height: 8.h),
                  Text(
                    type.plural(context),
                    maxLines: 1,
                    style: StyleText.fontSize12Weight600,
                  ),
                  Text('$count',
                      style: StyleText.fontSize12Weight500.copyWith(color: type.color)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
