/// Module: parent / p2_child
///
///*************************** FILE INFO ****************************///
/// File Name: parent_messages_screen.dart
/// Purpose: Declares `ParentMessagesScreen` and `startParentConversation` —
///          the parent's inbox and "message a teacher".
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/data/repository/academy_repository.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/messages/m1_conversations/data/repository/messages_repository.dart';
import 'package:manger_plus/features/messages/m1_conversations/domain/entities/conversation.dart';
import 'package:manger_plus/features/messages/m1_conversations/presentation/ui/pages/inbox_page.dart';
import 'package:manger_plus/features/messages/m1_conversations/presentation/ui/widgets/chat_view.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/data/repository/auth_repository.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/teacher_permission.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/presentation/controller/session_controller.dart';
import 'package:manger_plus/features/parent/p1_home/presentation/controller/parent_cubit.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

/// Opens (or creates) the thread with one of [child]'s teachers.
///
/// Shows the teachers of the child's section who have the Messages switch
/// on — a teacher the admin has not allowed to message is simply not
/// offered, rather than offered and then refused by the rules.
Future<void> startParentConversation(
  BuildContext context, {
  required AppUser parent,
  required AppUser child,
  List<LearningContent>? attachable,
}) async {
  final S s = S.of(context);
  final List<AppUser> teachers = (await UsersRepository().watchTeachersOf(child.sectionId).first)
      .where((AppUser t) => t.active && t.can(TeacherPermission.messages))
      .toList();
  if (!context.mounted) return;

  final AppUser? teacher = await showModalBottomSheet<AppUser>(
    context: context,
    backgroundColor: AppColors.card,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (BuildContext ctx) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 4.h),
            child: Text(s.chooseTeacher, style: StyleText.fontSize18Weight600),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
            child: Text(s.aboutChild(child.displayName),
                style: StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryText)),
          ),
          if (teachers.isEmpty)
            Padding(
              padding: EdgeInsets.all(20.r),
              child: Text(s.noTeachersToMessage,
                  style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText)),
            ),
          for (final AppUser t in teachers)
            ListTile(
              leading: AppAvatar(name: t.displayName, size: 42),
              title: Text(t.displayName, style: StyleText.fontSize15Weight600),
              subtitle: Text(t.subject.isEmpty ? s.roleTeacher : t.subject,
                  style: StyleText.fontSize12Weight500.copyWith(color: AppColors.primary)),
              trailing: const AppIcon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(ctx).pop(t),
            ),
        ],
      ),
    ),
  );
  if (teacher == null || !context.mounted) return;

  final Either<AppFailure, Conversation> opened = await MessagesRepository().open(Conversation(
    id: Conversation.idFor(teacherId: teacher.uid, parentId: parent.uid, studentId: child.uid),
    teacherId: teacher.uid,
    teacherName: teacher.displayName,
    parentId: parent.uid,
    parentName: parent.displayName,
    studentId: child.uid,
    studentName: child.displayName,
  ));
  if (!context.mounted) return;

  final List<LearningContent> tags =
      attachable ?? await ContentRepository().watchForStudent(child).first;
  if (!context.mounted) return;

  opened.fold(
    (AppFailure f) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(f.message(context)))),
    (Conversation c) => Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ChatScreen(conversation: c, me: parent, attachable: tags),
    )),
  );
}

class ParentMessagesScreen extends StatefulWidget {
  const ParentMessagesScreen({super.key});

  @override
  State<ParentMessagesScreen> createState() => _ParentMessagesScreenState();
}

class _ParentMessagesScreenState extends State<ParentMessagesScreen> {
  late final AppUser _me = SessionController.to.current;
  late final Stream<List<Conversation>> _inbox = MessagesRepository().watchInbox(_me.uid);

  Future<void> _newMessage(List<AppUser> children) async {
    AppUser? child = children.length == 1 ? children.first : null;
    if (child == null) {
      child = await showModalBottomSheet<AppUser>(
        context: context,
        backgroundColor: AppColors.card,
        builder: (BuildContext ctx) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                child: Text(S.of(ctx).whichChild, style: StyleText.fontSize18Weight600),
              ),
              for (final AppUser k in children)
                ListTile(
                  leading: AppAvatar(name: k.displayName, size: 40),
                  title: Text(k.displayName, style: StyleText.fontSize15Weight600),
                  onTap: () => Navigator.of(ctx).pop(k),
                ),
            ],
          ),
        ),
      );
    }
    if (child == null || !mounted) return;
    await startParentConversation(context, parent: _me, child: child);
  }

  Future<void> _open(Conversation c, List<AppUser> children) async {
    final AppUser? child = children.where((AppUser k) => k.uid == c.studentId).firstOrNull;
    final List<LearningContent> tags = child == null
        ? const <LearningContent>[]
        : await ContentRepository().watchForStudent(child).first;
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ChatScreen(conversation: c, me: _me, attachable: tags),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocBuilder<ParentCubit, ParentState>(
      builder: (BuildContext context, ParentState parent) {
        return Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: parent.children.isEmpty
              ? null
              : FloatingActionButton.extended(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  onPressed: () => _newMessage(parent.children),
                  icon: const AppIcon(Icons.edit_rounded),
                  label: Text(s.newMessage),
                ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 720.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                      child: Text(s.messages, style: StyleText.fontSize25Weight600),
                    ),
                    Expanded(
                      child: StreamBuilder<List<Conversation>>(
                        stream: _inbox,
                        builder: (BuildContext context, AsyncSnapshot<List<Conversation>> snap) {
                          if (snap.hasError) {
                            return AppErrorView(
                                message: AppFailure.from(snap.error!).message(context));
                          }
                          if (!snap.hasData) return const AppLoading();
                          if (snap.data!.isEmpty) {
                            return AppEmptyView(
                              title: s.noConversations,
                              subtitle: s.noConversationsParentSub,
                            );
                          }
                          return ListView.separated(
                            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 90.h),
                            itemCount: snap.data!.length,
                            separatorBuilder: (_, __) => SizedBox(height: 8.h),
                            itemBuilder: (BuildContext context, int i) => ConversationTile(
                              conversation: snap.data![i],
                              myUid: _me.uid,
                              onTap: () => _open(snap.data![i], parent.children),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
