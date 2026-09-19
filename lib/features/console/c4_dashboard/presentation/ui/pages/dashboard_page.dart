/// Module: console / c4_dashboard
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_page.dart
/// Purpose: Declares `DashboardPage` — the console's front page, for admins
///          and for teachers.
/// Author: Manger Plus team
/// Created: 18/9/2026
/// Updated: 18/9/2026 — this page REPLACED Overview rather than sitting beside
///          it. Overview's content-library cards moved here (they belong with
///          the other numbers); its demo-data tool and permission list moved
///          to Settings.
///
/// ONE page for both roles, the way `ConsoleShell` runs one console for both.
/// The role changes what the cubit READS, never what this file draws — an
/// admin's chips list every section in the center and a teacher's list the
/// sections they teach, and nothing below the chip row knows the difference.
///
/// THE SHARED CONTROLS
/// -------------------
/// Every control here is one of the app's own, and the toolbar is knowticed's
/// role-management toolbar:
///
///   * `98-custom_search_filter_sort_bar`  search + Filters + Export in one row
///   * `35-custom_search_widget_custom`    the search box inside it
///   * `8-custom_filter_app`               the section chip row
///   * `57-custom_dialog_manager`          the filter sheet and the export sheet
///   * `58-default_switch_button`          every switch inside those sheets
///   * `10-custom_tabs`                    Results / Attendance
///   * `100-custom_data_table`             the rows
///   * `24 / 26 / 27 / 28`                 the four charts
///
/// LAYOUT
/// ------
/// Toolbar, chips, four tiles, charts, the content library, then the records —
/// the same descent from "how are we doing" to "which record" that the
/// services dashboard in knowticed uses. The page scrolls as one column; the
/// table shrink-wraps rather than scrolling inside a fixed box, so there is
/// never a scrollbar inside a scrollbar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:manger_plus/core/constants/app_assets.dart';
import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/custom/8-custom_filter_app.dart';
import 'package:manger_plus/core/custom/98-custom_search_filter_sort_bar.dart';
import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/section.dart';
import 'package:manger_plus/features/console/c1_shell/presentation/ui/widgets/console_page.dart';
import 'package:manger_plus/features/console/c4_dashboard/presentation/controller/dashboard_cubit.dart';
import 'package:manger_plus/features/console/c4_dashboard/presentation/controller/dashboard_state.dart';
import 'package:manger_plus/features/console/c4_dashboard/presentation/ui/widgets/dashboard_charts_section.dart';
import 'package:manger_plus/features/console/c4_dashboard/presentation/ui/widgets/dashboard_content_section.dart';
import 'package:manger_plus/features/console/c4_dashboard/presentation/ui/widgets/dashboard_export.dart';
import 'package:manger_plus/features/console/c4_dashboard/presentation/ui/widgets/dashboard_filter_dialog.dart';
import 'package:manger_plus/features/console/c4_dashboard/presentation/ui/widgets/dashboard_table_section.dart';
import 'package:manger_plus/features/console/c4_dashboard/presentation/ui/widgets/stat_tile.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/user_role.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/presentation/controller/session_controller.dart';
import 'package:manger_plus/generated/l10n.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final AppUser user = SessionController.to.current;
      // Keyed on what the cubit's QUERIES depend on. The admin moving a
      // teacher between sections must rebuild the cubit, because its
      // subscriptions were opened against the old list; a change of name or
      // phone must not, because that would drop five live listeners for
      // nothing.
      return BlocProvider<DashboardCubit>(
        key: ValueKey<String>('${user.uid}:${user.sectionIds.join(",")}'),
        create: (_) => DashboardCubit(user: user)..start(),
        child: _DashboardView(user: user),
      );
    });
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView({required this.user});

  final AppUser user;

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool isAdmin = widget.user.role == UserRole.admin;

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (BuildContext context, DashboardState state) {
        final DashboardCubit cubit = context.read<DashboardCubit>();

        return ConsolePage(
          title: s.dashboard,
          subtitle: isAdmin ? s.dashboardAdminSub : s.dashboardTeacherSub,
          scrollable: true,
          child: _body(context, s, state, cubit),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    S s,
    DashboardState state,
    DashboardCubit cubit,
  ) {
    // Both of these sit in the page's scroll view, where a bare Center
    // collapses to the height of its spinner and lands under the title
    // instead of in the middle of the empty page.
    if (state.loading) {
      return SizedBox(height: 360.h, child: AppLoading());
    }

    if (state.error != null) {
      return SizedBox(
        height: 360.h,
        child: AppErrorView(
          message: AppFailure.from(state.error!).message(context),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // ── Toolbar ─────────────────────────────────────────────────────
        // The whole row is the shared toolbar, so this page's search, filter
        // and export are the same three controls every list page gets.
        CustomSearchFilterSortBar<String, String>(
          searchController: _search,
          onSearchChanged: cubit.search,
          searchHint: s.dashboardSearchHint,
          showFilter: true,
          filterTitle: s.filters,
          isFilterActive: state.hasActiveFilters,
          onFilterTap: () =>
              showDashboardFilters(context: context, cubit: cubit),
          trailingChildren: <Widget>[
            ToolbarActionButton(
              title: s.exportTitle,
              iconPath: AppAssets.export,
              // Lit like role management's export, but only while there is
              // something to write — an always-primary button over an empty
              // table promises a file it cannot produce.
              isActive: state.rowsShown > 0,
              onTap: state.rowsShown == 0
                  ? null
                  : () => exportDashboard(context: context, state: state),
            ),
          ],
        ),
        SizedBox(height: 22.h),

        // ── Section chips ───────────────────────────────────────────────
        if (state.sections.length > 1) ...<Widget>[
          _SectionChips(state: state, onSelected: cubit.selectSection),
          SizedBox(height: 22.h),
        ],

        // ── Tiles ───────────────────────────────────────────────────────
        // FOUR NUMBERS, ONE ROW (19/9/2026). They are read as a set — 6
        // students, 89% attendance, 82% average, 7 published — so they belong
        // on one line at every width, smaller rather than wrapped. `StatTile`
        // stacks itself when its cell gets narrow.
        TileGrid(columns: 4, tileHeight: 110, children: <Widget>[
          StatTile(
            icon: Icons.backpack_rounded,
            color: const Color(0xff10B981),
            label: s.students,
            value: state.studentCount,
          ),
          StatTile(
            icon: Icons.fact_check_rounded,
            color: const Color(0xff3B82F6),
            label: s.attendanceRateLabel,
            value: state.attendanceRate,
            valueSuffix: '%',
            caption: s.daysRecorded('${state.recordedDays}'),
          ),
          StatTile(
            icon: Icons.grade_rounded,
            color: const Color(0xffF59E0B),
            label: s.averageScoreLabel,
            value: state.averageScore,
            valueSuffix: '%',
            caption: s.resultsCountLabel('${state.markedCount}'),
          ),
          StatTile(
            icon: Icons.video_library_rounded,
            color: const Color(0xff6C63FF),
            label: s.publishedContentLabel,
            value: state.publishedContentCount,
          ),
        ]),
        SizedBox(height: 24.h),

        // ── Charts ──────────────────────────────────────────────────────
        if (state.showCharts) ...<Widget>[
          if (state.isEmpty)
            const DashboardChartsEmpty()
          else
            DashboardChartsSection(state: state),
          SizedBox(height: 16.h),

          // Overview's two content cards. They read the cubit's `content`
          // list rather than opening a stream of their own.
          _ContentRow(state: state),
          SizedBox(height: 26.h),
        ],

        // ── Records ─────────────────────────────────────────────────────
        DashboardTableSection(
          state: state,
          onTabChanged: cubit.selectTab,
          onSort: cubit.sort,
        ),
      ],
    );
  }
}

/// Content mix beside recently-added, stacking under 1000px like the charts.
class _ContentRow extends StatelessWidget {
  const _ContentRow({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        if (c.maxWidth < 1000) {
          return Column(
            children: <Widget>[
              ContentMixCard(items: state.scopedContent),
              SizedBox(height: 16.h),
              RecentContentCard(items: state.scopedContent),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(flex: 3, child: ContentMixCard(items: state.scopedContent)),
            SizedBox(width: 16.w),
            Expanded(
                flex: 2, child: RecentContentCard(items: state.scopedContent)),
          ],
        );
      },
    );
  }
}

/// All + one chip per section, each carrying its head-count.
class _SectionChips extends StatelessWidget {
  const _SectionChips({required this.state, required this.onSelected});

  final DashboardState state;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final Map<String, int> counts = state.studentsPerSection;

    return StatusChipFilter(
      selectedKey: state.sectionKey,
      onSelected: onSelected,
      items: <StatusChipItem>[
        StatusChipItem(
          key: kAllChipKey,
          label: S.of(context).all,
          count: state.students.length,
        ),
        for (final Section x in state.sections)
          StatusChipItem(
            key: x.id,
            label: x.name,
            count: counts[x.id] ?? 0,
          ),
      ],
    );
  }
}
