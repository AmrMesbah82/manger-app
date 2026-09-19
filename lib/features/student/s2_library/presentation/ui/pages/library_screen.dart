/// Module: student / s2_library
///
///*************************** FILE INFO ****************************///
/// File Name: library_screen.dart
/// Purpose: Declares `LibraryScreen` — everything assigned to the student,
///          searchable and filterable by type.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:manger_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/extensions/context_extensions.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_padding.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/content_type.dart';
import 'package:manger_plus/features/console/c1_shell/presentation/ui/widgets/console_page.dart';
import 'package:manger_plus/features/student/s1_home/presentation/controller/learner_cubit.dart';
import 'package:manger_plus/features/student/s2_library/presentation/ui/widgets/content_cards.dart';
import 'package:manger_plus/features/student/s3_viewer/presentation/ui/pages/content_viewers.dart';
import 'package:manger_plus/generated/l10n.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, this.initialFilter});

  /// Set when the student tapped a category on the home screen.
  final ContentType? initialFilter;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late ContentType? _type = widget.initialFilter;
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LibraryScreen old) {
    super.didUpdateWidget(old);
    if (old.initialFilter != widget.initialFilter) _type = widget.initialFilter;
  }

  List<LearningContent> _filter(List<LearningContent> all) {
    final String q = _query.trim().toLowerCase();
    return all.where((LearningContent c) {
      if (_type != null && c.type != _type) return false;
      if (q.isEmpty) return true;
      return c.title.toLowerCase().contains(q) ||
          c.subject.toLowerCase().contains(q) ||
          c.teacherName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool tablet = context.isTablet;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<LearnerCubit, LearnerState>(
          builder: (BuildContext context, LearnerState state) {
            final List<LearningContent> items = _filter(state.content);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(AppPadding.h, 16.h, AppPadding.h, 8.h),
                  child: Text(s.libraryTab, style: StyleText.fontSize25Weight600),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppPadding.h),
                  child: AppSearchTextField(
                    controller: _search,
                    expanded: false,
                    hintText: s.searchLessons,
                    onChanged: (String v) => setState(() => _query = v),
                  ),
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsetsDirectional.only(start: AppPadding.h),
                  child: FilterChipRow<ContentType>(
                    items: ContentType.values,
                    selected: _type,
                    allLabel: s.all,
                    labelOf: (ContentType t) => t.plural(context),
                    // The whole library is already in hand here, so these
                    // chips can carry their counts.
                    countOf: (ContentType t) => state.content
                        .where((LearningContent c) => c.type == t)
                        .length,
                    allCount: state.content.length,
                    onSelected: (ContentType? t) => setState(() => _type = t),
                  ),
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: state.loading
                      ? const AppLoading()
                      : items.isEmpty
                          ? AppEmptyView(title: s.nothingHere, subtitle: s.nothingHereSub)
                          : Align(
                              alignment: Alignment.topCenter,
                              // Tablets get a readable column, not a row
                              // stretched across 1200 points.
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: tablet ? 720.w : double.infinity),
                                child: ListView.separated(
                                  padding: EdgeInsets.fromLTRB(AppPadding.h, 0, AppPadding.h, 24.h),
                                  itemCount: items.length,
                                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                                  itemBuilder: (BuildContext context, int i) => ContentRow(
                                    content: items[i],
                                    submission: state.submissions[items[i].id],
                                    onTap: () => ContentOpener.open(
                                      context,
                                      content: items[i],
                                      learner: state.learner,
                                      submission: state.submissions[items[i].id],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
