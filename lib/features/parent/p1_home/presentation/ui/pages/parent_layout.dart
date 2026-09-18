/// Module: parent / p1_home
///
///*************************** FILE INFO ****************************///
/// File Name: parent_layout.dart
/// Purpose: Declares `ParentLayout` — the parent app's shell (Home, Messages,
///          Profile) and `ParentHomeScreen`.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:manger_plus/core/constants/app_assets.dart';
import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/custom/32-custom_svg.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/submission.dart';
import 'package:manger_plus/features/onboarding/o1_splash/presentation/ui/pages/splash_screen.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/presentation/controller/session_controller.dart';
import 'package:manger_plus/features/parent/p1_home/presentation/controller/parent_cubit.dart';
import 'package:manger_plus/features/parent/p2_child/presentation/ui/pages/parent_messages_screen.dart';
import 'package:manger_plus/features/settings/se1_settings/presentation/ui/pages/mobile_settings_screen.dart';
import 'package:manger_plus/features/student/s1_home/presentation/controller/learner_cubit.dart';
import 'package:manger_plus/features/student/s2_library/presentation/ui/widgets/content_cards.dart';
import 'package:manger_plus/features/student/s3_viewer/presentation/ui/pages/content_viewers.dart';
import 'package:manger_plus/features/student/s5_results/presentation/ui/widgets/progress_widgets.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

class ParentLayout extends StatefulWidget {
  const ParentLayout({super.key});

  @override
  State<ParentLayout> createState() => _ParentLayoutState();
}

class _ParentLayoutState extends State<ParentLayout> {
  final ParentCubit _parent = ParentCubit();
  StreamSubscription<AppUser?>? _profileSub;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    SessionController.to.onDeactivated = () {
      if (mounted) AppRouter.signOut(context);
    };
    _parent.load(SessionController.to.current);
    // The admin linked or unlinked a child: reload the list.
    _profileSub = SessionController.to.user.listen((AppUser? u) {
      if (u != null) _parent.load(u);
    });
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    _parent.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocProvider<ParentCubit>.value(
      value: _parent,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _tab,
          children: const <Widget>[
            ParentHomeScreen(),
            ParentMessagesScreen(),
            MobileSettingsScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: AppColors.primary.withOpacity(0.14),
            labelTextStyle: WidgetStatePropertyAll<TextStyle>(StyleText.fontSize12Weight600),
          ),
          child: NavigationBar(
            height: 68.h,
            backgroundColor: AppColors.card,
            selectedIndex: _tab,
            onDestinationSelected: (int i) => setState(() => _tab = i),
            destinations: <NavigationDestination>[
              NavigationDestination(
                icon: const AppIcon(Icons.home_outlined),
                selectedIcon: AppIcon(Icons.home_rounded, color: AppColors.primary),
                label: s.home,
              ),
              NavigationDestination(
                icon: const AppIcon(Icons.chat_bubble_outline_rounded),
                selectedIcon: AppIcon(Icons.chat_bubble_rounded, color: AppColors.primary),
                label: s.messages,
              ),
              NavigationDestination(
                icon: const AppIcon(Icons.person_outline_rounded),
                selectedIcon: AppIcon(Icons.person_rounded, color: AppColors.primary),
                label: s.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocBuilder<ParentCubit, ParentState>(
      builder: (BuildContext context, ParentState state) {
        if (state.loading) return const AppLoading();
        final AppUser? child = state.selected;
        if (child == null) {
          return SafeArea(
            child: AppEmptyView(title: s.noChildrenLinked, subtitle: s.noChildrenLinkedSub),
          );
        }
        // One LearnerCubit per child, keyed so switching child starts fresh
        // listeners instead of showing the previous child's numbers.
        return BlocProvider<LearnerCubit>(
          key: ValueKey<String>(child.uid),
          create: (_) => LearnerCubit(learner: child),
          child: _ChildDashboard(children: state.children, child: child),
        );
      },
    );
  }
}

class _ChildDashboard extends StatelessWidget {
  const _ChildDashboard({required this.children, required this.child});

  final List<AppUser> children;
  final AppUser child;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final AppUser me = SessionController.to.current;

    return BlocBuilder<LearnerCubit, LearnerState>(
      builder: (BuildContext context, LearnerState state) {
        final List<LearningContent> assignments = state.content;
        return CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[AppColors.primary, AppColors.secondaryPrimary],
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
                ),
                padding: EdgeInsets.fromLTRB(
                    20.w, MediaQuery.of(context).padding.top + 16.h, 20.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(s.helloName(me.firstName),
                                  style: StyleText.fontSize14Weight500
                                      .copyWith(color: Colors.white70)),
                              Text(s.yourChildren,
                                  style: StyleText.fontSize24Weight600
                                      .copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 100.w,
                          height: 80.h,
                          child: const CustomSvgImage.natural(
                              assetPath: AppAssets.illustrationCalendar),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    // Child switcher.
                    SizedBox(
                      height: 44.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: children.length,
                        separatorBuilder: (_, __) => SizedBox(width: 8.w),
                        itemBuilder: (BuildContext ctx, int i) {
                          final AppUser k = children[i];
                          final bool on = k.uid == child.uid;
                          return GestureDetector(
                            onTap: () => context.read<ParentCubit>().select(k.uid),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              decoration: BoxDecoration(
                                color: on ? Colors.white : Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(22.r),
                              ),
                              child: Row(
                                children: <Widget>[
                                  AppAvatar(name: k.displayName, size: 28),
                                  SizedBox(width: 8.w),
                                  Text(
                                    k.firstName,
                                    style: StyleText.fontSize14Weight600.copyWith(
                                        color: on ? AppColors.primary : Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (state.section != null) ...<Widget>[
                      SizedBox(height: 10.h),
                      Text(
                        state.section!.title,
                        style: StyleText.fontSize13Weight500.copyWith(color: Colors.white),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(16.r),
              sliver: SliverList(
                delegate: SliverChildListDelegate(<Widget>[
                  if (state.failure != null) ...<Widget>[
                    InfoBanner.error(state.failure!.message(context)),
                    SizedBox(height: 12.h),
                  ],
                  SummaryCards(state: state),
                  SizedBox(height: 14.h),
                  AppButton(
                    label: s.messageATeacher,
                    icon: Icons.chat_bubble_outline_rounded,
                    kind: AppButtonKind.subtle,
                    expand: true,
                    onPressed: () => startParentConversation(
                      context,
                      parent: me,
                      child: child,
                      attachable: assignments,
                    ),
                  ),

                  // ── Assignments ───────────────────────────────────────────
                  _Title(s.assignments),
                  if (state.loading) const AppLoading(),
                  if (!state.loading && assignments.isEmpty)
                    Surface(
                      child: Text(s.nothingAssignedYet,
                          style: StyleText.fontSize13Weight400
                              .copyWith(color: AppColors.secondaryText)),
                    ),
                  for (final LearningContent c in assignments.take(12))
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: ContentRow(
                        content: c,
                        submission: state.submissions[c.id],
                        onTap: () => ContentOpener.open(
                          context,
                          content: c,
                          learner: child,
                          submission: state.submissions[c.id],
                          readOnly: true,
                        ),
                      ),
                    ),

                  // ── Grades ────────────────────────────────────────────────
                  _Title(s.grades),
                  if (state.results.isEmpty)
                    Surface(
                      child: Text(s.noResultsYet,
                          style: StyleText.fontSize13Weight400
                              .copyWith(color: AppColors.secondaryText)),
                    ),
                  for (final Submission x in state.results)
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: ResultTile(submission: x),
                    ),

                  // ── Attendance ────────────────────────────────────────────
                  _Title(s.attendance),
                  AttendanceCard(records: state.attendance),
                  SizedBox(height: 24.h),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 22.h, bottom: 10.h),
      child: Text(text, style: StyleText.fontSize18Weight600),
    );
  }
}
