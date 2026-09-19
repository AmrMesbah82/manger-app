/// Module: console / c3_settings
///
///*************************** FILE INFO ****************************///
/// File Name: demo_data_card.dart
/// Purpose: Declares `DemoDataCard` — "Fill demo data" / "Remove demo data".
/// Author: Manger Plus team
/// Created: 18/9/2026
///
/// Moved here from the Overview page when the Dashboard replaced it. Settings
/// is the right home anyway: one of these two buttons WRITES several dozen
/// Auth accounts and the other DELETES them, which is not something that
/// belongs one click from the front door.
///
/// Admin only — [DemoSeeder] writes to `users`, and `firestore.rules` refuses
/// that for anyone else, so showing the button to a teacher would only produce
/// a permission error.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:manger_plus/core/constants/app_constants.dart';
import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_padding.dart';
import 'package:manger_plus/core/theme/app_radius.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/console/c1_shell/presentation/ui/widgets/console_page.dart';
import 'package:manger_plus/features/console/c3_settings/data/demo_seeder.dart';
import 'package:manger_plus/generated/l10n.dart';

class DemoDataCard extends StatefulWidget {
  const DemoDataCard({super.key});

  @override
  State<DemoDataCard> createState() => _DemoDataCardState();
}

class _DemoDataCardState extends State<DemoDataCard> {
  bool _busy = false;
  String _step = '';
  double _progress = 0;

  Future<void> _run(
    Future<void> Function(DemoSeeder seeder) job,
    String doneMessage,
  ) async {
    setState(() {
      _busy = true;
      _progress = 0;
    });
    try {
      await job(DemoSeeder());
      if (!mounted) return;
      showToast(context, doneMessage);
    } catch (error) {
      if (!mounted) return;
      CustomDialogManager.showError(
        context: context,
        title: S.of(context).demoFailed,
        subtitle: AppFailure.from(error).message(context),
        closeLabel: S.of(context).close,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _onProgress(String step, double fraction) {
    if (mounted) {
      setState(() {
        _step = step;
        _progress = fraction;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Surface(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 22.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              TypeBadge(
                icon: Icons.auto_awesome_rounded,
                color: Color(0xffEC4899),
                size: 56,
              ),
              SizedBox(width: 18.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(s.demoTitle, style: StyleText.fontSize16Weight600),
                    SizedBox(height: 4.h),
                    Text(
                      s.demoBody(AppConstants.demoPassword),
                      style: StyleText.fontSize13Weight400
                          .copyWith(color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_busy) ...<Widget>[
            SizedBox(height: 14.h),
            ClipRRect(
              borderRadius: AppRadius.containerR,
              child: LinearProgressIndicator(
                minHeight: 8.h,
                value: _progress,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            SizedBox(height: 6.h),
            Text(_step, style: StyleText.fontSize12Weight500),
          ],
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              AppButton(
                label: s.removeDemo,
                icon: Icons.delete_sweep_outlined,
                kind: AppButtonKind.danger,
                onPressed: _busy
                    ? null
                    : () => CustomDialogManager.showConfirm(
                          context: context,
                          title: s.removeDemoQuestion,
                          subtitle: s.removeDemoBody,
                          confirmLabel: s.removeDemo,
                          cancelLabel: s.cancel,
                          onConfirm: () => _run(
                            (DemoSeeder d) => d.clear(onProgress: _onProgress),
                            s.demoRemoved,
                          ),
                        ),
              ),
              SizedBox(width: 10.w),
              AppButton(
                label: s.fillDemo,
                icon: Icons.auto_awesome_rounded,
                loading: _busy,
                onPressed: _busy
                    ? null
                    : () => _run(
                          (DemoSeeder d) => d.seed(onProgress: _onProgress),
                          s.demoFilled,
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
