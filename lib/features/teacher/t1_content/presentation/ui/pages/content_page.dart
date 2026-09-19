/// Module: teacher / t1_content
///
///*************************** FILE INFO ****************************///
/// File Name: content_page.dart
/// Purpose: Declares `ContentPage` — the content library: every video, PDF,
///          image, exam and quiz, with add / edit / delete / assign.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:manger_plus/core/custom/11-custom_confirm_dialog.dart';
import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_padding.dart';
import 'package:manger_plus/core/theme/app_radius.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/data/repository/academy_repository.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/section.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/content_type.dart';
import 'package:manger_plus/features/console/c1_shell/presentation/ui/widgets/choice_widgets.dart';
import 'package:manger_plus/features/console/c1_shell/presentation/ui/widgets/console_page.dart';
import 'package:manger_plus/features/console/c4_dashboard/presentation/ui/widgets/stat_tile.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/data/repository/auth_repository.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/user_role.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/presentation/controller/session_controller.dart';
import 'package:manger_plus/features/teacher/t1_content/presentation/ui/widgets/content_editor_dialog.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

class ContentPage extends StatelessWidget {
  const ContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => _ContentView(user: SessionController.to.current));
  }
}

class _ContentView extends StatefulWidget {
  const _ContentView({required this.user});

  final AppUser user;

  @override
  State<_ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<_ContentView> {
  final ContentRepository _repository = ContentRepository();

  late Stream<List<LearningContent>> _content;
  late Stream<List<AppUser>> _students;
  late final Stream<List<Section>> _sections = SectionsRepository().watchAll();

  ContentType? _typeFilter;
  String _query = '';

  bool get _isAdmin => widget.user.role == UserRole.admin;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(_ContentView old) {
    super.didUpdateWidget(old);
    if (old.user.uid != widget.user.uid ||
        old.user.sectionIds.join() != widget.user.sectionIds.join()) {
      _subscribe();
    }
  }

  void _subscribe() {
    _content = _isAdmin ? _repository.watchAll() : _repository.watchByTeacher(widget.user.uid);
    _students = _isAdmin
        ? UsersRepository().watchByRole(UserRole.student)
        : UsersRepository().watchStudentsIn(widget.user.sectionIds);
  }

  /// The types this person may create — the admin's switches, live.
  List<ContentType> get _allowedTypes =>
      ContentType.values.where((ContentType t) => widget.user.can(t.permission)).toList();

  List<Section> _mySections(List<Section> all) => _isAdmin
      ? all
      : all.where((Section s) => widget.user.sectionIds.contains(s.id)).toList();

  List<LearningContent> _filter(List<LearningContent> items) {
    final String q = _query.trim().toLowerCase();
    return items.where((LearningContent c) {
      if (_typeFilter != null && c.type != _typeFilter) return false;
      if (q.isEmpty) return true;
      return c.title.toLowerCase().contains(q) ||
          c.subject.toLowerCase().contains(q) ||
          c.teacherName.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _openEditor({
    required ContentType type,
    required List<Section> sections,
    required List<AppUser> students,
    LearningContent? existing,
  }) async {
    await showContentEditor(
      context: context,
      author: widget.user,
      type: type,
      sections: _mySections(sections),
      students: students,
      existing: existing,
    );
  }

  void _delete(LearningContent c) {
    final S s = S.of(context);
    showConfirmDialog(
      context: context,
      title: s.deleteQuestion(c.title),
      subtitle: c.type.isAssessment ? s.deleteAssessmentBody : s.deleteContentBody,
      confirmLabel: s.delete,
      cancelLabel: s.cancel,
      onConfirm: () async {
        final Either<AppFailure, Unit> r = await _repository.delete(c);
        if (!mounted) return;
        r.fold(
          (AppFailure f) => showToast(context, f.message(context), error: true),
          (_) => showToast(context, s.deleted),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<ContentType> allowed = _allowedTypes;

    return StreamBuilder<List<Section>>(
      stream: _sections,
      builder: (BuildContext context, AsyncSnapshot<List<Section>> sectionSnap) {
        final List<Section> sections = sectionSnap.data ?? const <Section>[];
        return StreamBuilder<List<AppUser>>(
          stream: _students,
          builder: (BuildContext context, AsyncSnapshot<List<AppUser>> studentSnap) {
            final List<AppUser> students = studentSnap.data ?? const <AppUser>[];
            return ConsolePage(
              title: s.content,
              subtitle: _isAdmin ? s.contentAdminSub : s.contentTeacherSub,
              actions: <Widget>[
                ConsoleSearchField(onChanged: (String v) => setState(() => _query = v)),
                if (allowed.isNotEmpty)
                  PopupMenuButton<ContentType>(
                    tooltip: s.add,
                    position: PopupMenuPosition.under,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.fieldR),
                    onSelected: (ContentType t) =>
                        _openEditor(type: t, sections: sections, students: students),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<ContentType>>[
                      for (final ContentType t in allowed)
                        PopupMenuItem<ContentType>(
                          value: t,
                          child: Row(
                            children: <Widget>[
                              ContentTypeIcon(type: t, size: 32.sp),
                              SizedBox(width: 10.w),
                              Text(t.label(context), style: StyleText.fontSize14Weight500),
                            ],
                          ),
                        ),
                    ],
                    child: IgnorePointer(
                      child: AppButton(
                        label: s.addContent,
                        icon: Icons.add_rounded,
                        dense: true,
                        onPressed: () {},
                      ),
                    ),
                  ),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  FilterChipRow<ContentType>(
                    items: ContentType.values,
                    selected: _typeFilter,
                    allLabel: s.all,
                    labelOf: (ContentType t) => t.plural(context),
                    onSelected: (ContentType? t) => setState(() => _typeFilter = t),
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: StreamBuilder<List<LearningContent>>(
                      stream: _content,
                      builder: (BuildContext context, AsyncSnapshot<List<LearningContent>> snap) {
                        if (snap.hasError) {
                          return AppErrorView(
                            message: AppFailure.from(snap.error!).message(context),
                          );
                        }
                        if (!snap.hasData) return const AppLoading();
                        final List<LearningContent> items = _filter(snap.data!);
                        if (items.isEmpty) {
                          return AppEmptyView(
                            title: s.noContentYet,
                            subtitle: allowed.isEmpty ? s.noContentPermission : s.noContentSub,
                          );
                        }
                        return SingleChildScrollView(
                          child: TileGrid(
                            minWidth: 320,
                            // The tallest card is header (56) + 3 meta rows
                            // (69) + footer (32) + gaps and padding.
                            tileHeight: 200,
                            children: <Widget>[
                              for (final LearningContent c in items)
                                _ContentCard(
                                  content: c,
                                  sections: sections,
                                  students: students,
                                  canEdit: widget.user.can(c.type.permission),
                                  showTeacher: _isAdmin,
                                  onEdit: () => _openEditor(
                                    type: c.type,
                                    sections: sections,
                                    students: students,
                                    existing: c,
                                  ),
                                  onDelete: () => _delete(c),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({
    required this.content,
    required this.sections,
    required this.students,
    required this.canEdit,
    required this.showTeacher,
    required this.onEdit,
    required this.onDelete,
  });

  final LearningContent content;
  final List<Section> sections;
  final List<AppUser> students;
  final bool canEdit;
  final bool showTeacher;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _assignedTo(S s) {
    final List<String> parts = <String>[
      for (final String id in content.sectionIds)
        sections.firstWhere((Section x) => x.id == id,
            orElse: () => Section(id: id, name: '—')).name,
    ];
    if (content.studentIds.isNotEmpty) {
      parts.add(s.studentsCount('${content.studentIds.length}'));
    }
    return parts.isEmpty ? s.notAssigned : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final LearningContent c = content;

    return Surface(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 16.sp),
      onTap: canEdit ? onEdit : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ContentTypeIcon(type: c.type, size: 46.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      c.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize15Weight600,
                    ),
                    Text(
                      <String>[
                        c.type.label(context),
                        if (c.subject.isNotEmpty) c.subject,
                        if (showTeacher && c.teacherName.isNotEmpty) c.teacherName,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize12Weight500.copyWith(color: c.type.color),
                    ),
                  ],
                ),
              ),
              if (!c.published) StatusPill(label: s.draft, color: AppColors.secondaryText),
            ],
          ),
          SizedBox(height: 12.h),
          // Every card is the same height (see TileGrid.tileHeight), and the
          // meta rows are the part that varies — a due date here, a question
          // count there. Giving them the leftover space is what lets the
          // footer sit on the bottom edge of EVERY card, so the dates and the
          // action buttons line up straight across the grid instead of
          // floating at whatever height their own card happened to be.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _Meta(icon: Icons.groups_2_outlined, text: _assignedTo(s)),
                if (c.type.isAssessment)
                  _Meta(
                    icon: Icons.help_outline_rounded,
                    text: s.questionsShort(
                      '${c.questions.length}',
                      c.durationMinutes == 0
                          ? s.untimed
                          : s.minutesShort('${c.durationMinutes}'),
                    ),
                  ),
                if (c.dueAt != null)
                  _Meta(
                    icon: Icons.event_outlined,
                    text: s.dueOn(AppDates.day(context, c.dueAt)),
                    color: c.isOverdue ? AppColors.red : null,
                  ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Text(
                AppDates.day(context, c.createdAt),
                style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
              ),
              const Spacer(),
              if (c.fileUrl.isNotEmpty)
                _CardAction(
                  tooltip: s.open,
                  icon: Icons.open_in_new_rounded,
                  color: AppColors.secondaryText,
                  onPressed: () => launchUrl(Uri.parse(c.fileUrl),
                      mode: LaunchMode.externalApplication),
                ),
              if (canEdit) ...<Widget>[
                _CardAction(
                  tooltip: s.edit,
                  icon: Icons.edit_outlined,
                  color: AppColors.primary,
                  onPressed: onEdit,
                ),
                _CardAction(
                  tooltip: s.delete,
                  icon: Icons.delete_outline_rounded,
                  color: AppColors.red,
                  onPressed: onDelete,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// A footer icon button that does not eat the card.
///
/// A default [IconButton] is 48 logical pixels square whatever icon it holds,
/// so three of them made the footer taller than the meta rows above it. This
/// is the same button at 32.
class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
      iconSize: 19.sp,
      icon: AppIcon(icon, color: color),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? AppColors.secondaryText;
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: <Widget>[
          AppIcon(icon, size: 15.sp, color: c),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: StyleText.fontSize12Weight500.copyWith(color: c),
            ),
          ),
        ],
      ),
    );
  }
}
