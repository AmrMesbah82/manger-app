/// Module: student / s1_home
///
///*************************** FILE INFO ****************************///
/// File Name: student_layout.dart
/// Purpose: Declares `StudentLayout` — the student app's shell: four tabs
///          over one live [LearnerCubit].
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/content_type.dart';
import 'package:manger_plus/features/onboarding/o1_splash/presentation/ui/pages/splash_screen.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/presentation/controller/session_controller.dart';
import 'package:manger_plus/features/settings/se1_settings/presentation/ui/pages/mobile_settings_screen.dart';
import 'package:manger_plus/features/student/s1_home/presentation/controller/learner_cubit.dart';
import 'package:manger_plus/features/student/s1_home/presentation/ui/pages/student_home_screen.dart';
import 'package:manger_plus/features/student/s2_library/presentation/ui/pages/library_screen.dart';
import 'package:manger_plus/features/student/s5_results/presentation/ui/pages/results_screen.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

/// Which tab is showing, and which type the Library is filtered to — the
/// home screen's category tiles jump to the Library with a filter set.
class StudentTabState {
  final int index;
  final ContentType? libraryFilter;

  const StudentTabState({this.index = 0, this.libraryFilter});
}

class StudentTabCubit extends Cubit<StudentTabState> {
  StudentTabCubit() : super(const StudentTabState());

  void select(int index) => emit(StudentTabState(index: index, libraryFilter: state.libraryFilter));

  void openLibrary([ContentType? filter]) =>
      emit(StudentTabState(index: 1, libraryFilter: filter));
}

class StudentLayout extends StatelessWidget {
  const StudentLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LearnerCubit>(
          create: (_) => LearnerCubit(learner: SessionController.to.current),
        ),
        BlocProvider<StudentTabCubit>(create: (_) => StudentTabCubit()),
      ],
      child: const _StudentLayoutView(),
    );
  }
}

class _StudentLayoutView extends StatefulWidget {
  const _StudentLayoutView();

  @override
  State<_StudentLayoutView> createState() => _StudentLayoutViewState();
}

class _StudentLayoutViewState extends State<_StudentLayoutView> {
  StreamSubscription<AppUser?>? _profileSub;

  @override
  void dispose() {
    _profileSub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SessionController.to.onDeactivated = () {
      if (mounted) AppRouter.signOut(context);
    };
    // The admin moved this student to another section: follow them there.
    _profileSub = SessionController.to.user.listen((AppUser? user) {
      if (!mounted || user == null) return;
      context.read<LearnerCubit>().switchTo(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocBuilder<StudentTabCubit, StudentTabState>(
      builder: (BuildContext context, StudentTabState tab) {
        final StudentTabCubit tabs = context.read<StudentTabCubit>();
        return Scaffold(
          backgroundColor: AppColors.background,
          body: IndexedStack(
            index: tab.index,
            children: <Widget>[
              const StudentHomeScreen(),
              LibraryScreen(initialFilter: tab.libraryFilter),
              const ResultsScreen(),
              const MobileSettingsScreen(),
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
              selectedIndex: tab.index,
              onDestinationSelected: tabs.select,
              destinations: <NavigationDestination>[
                NavigationDestination(
                  icon: const AppIcon(Icons.home_outlined),
                  selectedIcon: AppIcon(Icons.home_rounded, color: AppColors.primary),
                  label: s.home,
                ),
                NavigationDestination(
                  icon: const AppIcon(Icons.video_library_outlined),
                  selectedIcon: AppIcon(Icons.video_library_rounded, color: AppColors.primary),
                  label: s.libraryTab,
                ),
                NavigationDestination(
                  icon: const AppIcon(Icons.insights_outlined),
                  selectedIcon: AppIcon(Icons.insights_rounded, color: AppColors.primary),
                  label: s.results,
                ),
                NavigationDestination(
                  icon: const AppIcon(Icons.person_outline_rounded),
                  selectedIcon: AppIcon(Icons.person_rounded, color: AppColors.primary),
                  label: s.profile,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
