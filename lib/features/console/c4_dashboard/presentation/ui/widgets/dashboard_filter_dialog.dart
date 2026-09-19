/// Module: console / c4_dashboard
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_filter_dialog.dart
/// Purpose: Declares `showDashboardFilters` — the toolbar's filter sheet.
/// Author: Manger Plus team
/// Created: 18/9/2026
///
/// Opened through [CustomDialogManager.showFilter], so it wears the same
/// shell, the same width and the same button order as every other dialog in
/// the app. The two booleans are drawn with `58-default_switch_button`, which
/// is the app's only switch.
///
/// WHY IT APPLIES LIVE
/// -------------------
/// Each control writes straight to the cubit as it is touched, so the page
/// behind the dialog updates while it is open. On a desktop console the
/// dialog covers a fraction of the screen and the tables and charts are still
/// visible, so "apply" that the user cannot see the effect of is worse than
/// no apply at all. The Apply button therefore only closes; Clear resets the
/// three fields this sheet owns and leaves the section chips and the search
/// box — which the user can see — alone.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:manger_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:manger_plus/core/custom/58-default_switch_button.dart';
import 'package:manger_plus/core/custom/9-filter_tab_with_container.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/console/c4_dashboard/presentation/controller/dashboard_cubit.dart';
import 'package:manger_plus/features/console/c4_dashboard/presentation/controller/dashboard_state.dart';
import 'package:manger_plus/generated/l10n.dart';

Future<void> showDashboardFilters({
  required BuildContext context,
  required DashboardCubit cubit,
}) {
  final S s = S.of(context);
  return CustomDialogManager.showFilter(
    context: context,
    title: s.filters,
    applyLabel: s.apply,
    clearLabel: s.clear,
    onClear: cubit.clearFilters,
    child: BlocProvider<DashboardCubit>.value(
      value: cubit,
      child: const _DashboardFilterForm(),
    ),
  );
}

class _DashboardFilterForm extends StatelessWidget {
  const _DashboardFilterForm();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final DashboardCubit cubit = context.read<DashboardCubit>();

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (BuildContext context, DashboardState state) {
        const List<DashboardPeriod> periods = DashboardPeriod.values;
        final List<String> periodLabels = <String>[
          s.period30,
          s.period90,
          s.periodAll,
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _Label(s.periodLabel),
            SizedBox(height: 8.h),
            CustomSegmentedTabs(
              tabs: periodLabels,
              equalWidth: true,
              selectedIndex: periods.indexOf(state.period),
              onTabSelected: (int i) => cubit.selectPeriod(periods[i]),
            ),
            SizedBox(height: 22.h),
            _SwitchRow(
              label: s.onlyBelowPass,
              value: state.onlyBelowPass,
              onChanged: cubit.toggleOnlyBelowPass,
            ),
            SizedBox(height: 14.h),
            _SwitchRow(
              label: s.onlyAbsences,
              value: state.onlyAbsences,
              onChanged: cubit.toggleOnlyAbsences,
            ),
            SizedBox(height: 14.h),
            _SwitchRow(
              label: s.charts,
              value: state.showCharts,
              onChanged: cubit.toggleCharts,
            ),
          ],
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: StyleText.fontSize13Weight600
            .copyWith(color: AppColors.secondaryText),
      );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(label, style: StyleText.fontSize14Weight500),
        ),
        SizedBox(width: 12.w),
        DefaultSwitchButton(value: value, onChanged: onChanged),
      ],
    );
  }
}
