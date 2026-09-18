/// Module: student / s5_results
///
///*************************** FILE INFO ****************************///
/// File Name: results_screen.dart
/// Purpose: Declares `ResultsScreen` — the student's grades and attendance.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/submission.dart';
import 'package:manger_plus/features/student/s1_home/presentation/controller/learner_cubit.dart';
import 'package:manger_plus/features/student/s3_viewer/presentation/ui/pages/content_viewers.dart';
import 'package:manger_plus/features/student/s5_results/presentation/ui/widgets/progress_widgets.dart';
import 'package:manger_plus/generated/l10n.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<LearnerCubit, LearnerState>(
          builder: (BuildContext context, LearnerState state) {
            final List<Submission> results = state.results;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 720.w),
                child: ListView(
                  padding: EdgeInsets.all(16.r),
                  children: <Widget>[
                    Text(s.myProgress, style: StyleText.fontSize25Weight600),
                    SizedBox(height: 16.h),
                    SummaryCards(state: state),
                    SizedBox(height: 22.h),
                    Text(s.results, style: StyleText.fontSize18Weight600),
                    SizedBox(height: 10.h),
                    if (results.isEmpty)
                      Surface(
                        child: Text(s.noResultsYet,
                            style: StyleText.fontSize13Weight400
                                .copyWith(color: AppColors.secondaryText)),
                      ),
                    for (final Submission x in results)
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: ResultTile(
                          submission: x,
                          onTap: () {
                            final LearningContent? c = state.content
                                .where((LearningContent item) => item.id == x.contentId)
                                .firstOrNull;
                            if (c != null) {
                              ContentOpener.open(context,
                                  content: c, learner: state.learner, submission: x);
                            }
                          },
                        ),
                      ),
                    SizedBox(height: 12.h),
                    Text(s.attendance, style: StyleText.fontSize18Weight600),
                    SizedBox(height: 10.h),
                    AttendanceCard(records: state.attendance),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
