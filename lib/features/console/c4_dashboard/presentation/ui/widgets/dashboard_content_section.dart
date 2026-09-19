/// Module: console / c4_dashboard
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_content_section.dart
/// Purpose: Declares `ContentMixCard` and `RecentContentCard`.
/// Author: Manger Plus team
/// Created: 18/9/2026
///
/// Both cards came from the Overview page, which the dashboard replaced. They
/// answer "what is in the library", which belongs beside the attendance and
/// score cards rather than on a page of its own — that duplication was the
/// reason Overview went.
///
/// They take their items as a plain list rather than opening their own stream:
/// the dashboard's cubit is already watching `content`, and a second listener
/// on the same collection would double the reads for the same rows.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_padding.dart';
import 'package:manger_plus/core/theme/app_radius.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/content_type.dart';
import 'package:manger_plus/generated/l10n.dart';

/// One bar per content type, each against the busiest type rather than the
/// total — five slices of a total are unreadable when four of them are 1.
class ContentMixCard extends StatelessWidget {
  const ContentMixCard({super.key, required this.items});

  final List<LearningContent> items;

  @override
  Widget build(BuildContext context) {
    final int max = ContentType.values
        .map((ContentType t) => items.where((LearningContent c) => c.type == t).length)
        .fold<int>(1, (int a, int b) => a > b ? a : b);

    return Surface(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 20.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(S.of(context).contentLibrary, style: StyleText.fontSize16Weight600),
          SizedBox(height: 4.h),
          Text(
            S.of(context).itemsCount('${items.length}'),
            style: StyleText.fontSize13Weight400
                .copyWith(color: AppColors.secondaryText),
          ),
          SizedBox(height: 18.h),
          for (final ContentType type in ContentType.values) ...<Widget>[
            Row(
              children: <Widget>[
                ContentTypeIcon(type: type, size: 22.sp),
                SizedBox(width: 10.w),
                SizedBox(
                  width: 110.w,
                  child: Text(type.plural(context),
                      style: StyleText.fontSize13Weight500),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: AppRadius.containerR,
                    child: LinearProgressIndicator(
                      minHeight: 10.h,
                      value:
                          items.where((LearningContent c) => c.type == type).length /
                              max,
                      backgroundColor: type.color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(type.color),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: 28.w,
                  child: Text(
                    '${items.where((LearningContent c) => c.type == type).length}',
                    textAlign: TextAlign.end,
                    style: StyleText.fontSize13Weight600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
          ],
        ],
      ),
    );
  }
}

/// The six most recent pieces of content, newest first.
class RecentContentCard extends StatelessWidget {
  const RecentContentCard({super.key, required this.items});

  final List<LearningContent> items;

  @override
  Widget build(BuildContext context) {
    return Surface(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 20.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(S.of(context).recentlyAdded, style: StyleText.fontSize16Weight600),
          SizedBox(height: 12.h),
          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Text(
                S.of(context).noContentYet,
                textAlign: TextAlign.center,
                style: StyleText.fontSize13Weight400
                    .copyWith(color: AppColors.secondaryText),
              ),
            ),
          for (final LearningContent c in items.take(6))
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                children: <Widget>[
                  ContentTypeIcon(type: c.type, size: 36.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          c.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StyleText.fontSize13Weight600,
                        ),
                        Text(
                          c.teacherName,
                          style: StyleText.fontSize12Weight400
                              .copyWith(color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    AppDates.day(context, c.createdAt),
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
