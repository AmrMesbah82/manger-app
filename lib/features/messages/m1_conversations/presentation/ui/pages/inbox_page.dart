/// Module: messages / m1_conversations
///
///*************************** FILE INFO ****************************///
/// File Name: inbox_page.dart
/// Purpose: Declares `InboxPage` (the console's two-pane messages page) and
///          `ChatScreen` (a thread full-screen, for the phone).
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/data/repository/academy_repository.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/console/c1_shell/presentation/ui/widgets/console_page.dart';
import 'package:manger_plus/features/messages/m1_conversations/data/repository/messages_repository.dart';
import 'package:manger_plus/features/messages/m1_conversations/domain/entities/conversation.dart';
import 'package:manger_plus/features/messages/m1_conversations/presentation/ui/widgets/chat_view.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/presentation/controller/session_controller.dart';
import 'package:manger_plus/generated/l10n.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => _InboxView(me: SessionController.to.current));
  }
}

class _InboxView extends StatefulWidget {
  const _InboxView({required this.me});

  final AppUser me;

  @override
  State<_InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<_InboxView> {
  late final Stream<List<Conversation>> _inbox =
      MessagesRepository().watchInbox(widget.me.uid);

  /// The teacher's own content, to tag messages with.
  late final Stream<List<LearningContent>> _content =
      ContentRepository().watchByTeacher(widget.me.uid);

  String? _openId;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return ConsolePage(
      title: s.messages,
      subtitle: s.messagesTeacherSub,
      child: StreamBuilder<List<LearningContent>>(
        stream: _content,
        builder: (BuildContext context, AsyncSnapshot<List<LearningContent>> contentSnap) {
          return StreamBuilder<List<Conversation>>(
            stream: _inbox,
            builder: (BuildContext context, AsyncSnapshot<List<Conversation>> snap) {
              if (snap.hasError) {
                return AppErrorView(message: AppFailure.from(snap.error!).message(context));
              }
              if (!snap.hasData) return const AppLoading();
              final List<Conversation> threads = snap.data!;
              if (threads.isEmpty) {
                return AppEmptyView(title: s.noConversations, subtitle: s.noConversationsTeacherSub);
              }
              final Conversation open = threads.firstWhere(
                (Conversation c) => c.id == _openId,
                orElse: () => threads.first,
              );
              // Narrower list on a tablet in portrait so the chat keeps room.
              final double listWidth =
                  MediaQuery.sizeOf(context).width < 1000 ? 270 : 340;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    width: listWidth,
                    child: ListView.separated(
                      itemCount: threads.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (BuildContext context, int i) => ConversationTile(
                        conversation: threads[i],
                        myUid: widget.me.uid,
                        selected: threads[i].id == open.id,
                        onTap: () => setState(() => _openId = threads[i].id),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        color: AppColors.chatBackground,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              color: AppColors.card,
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: <Widget>[
                                  AppAvatar(name: open.parentName, size: 40),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(open.parentName, style: StyleText.fontSize15Weight600),
                                        Text(
                                          s.parentOf(open.studentName),
                                          style: StyleText.fontSize12Weight500
                                              .copyWith(color: AppColors.secondaryText),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ChatView(
                                conversation: open,
                                me: widget.me,
                                attachable: contentSnap.data ?? const <LearningContent>[],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// A thread full-screen — the parent app, and the teacher's "message parent"
/// shortcut on a narrow window.
class ChatScreen extends StatelessWidget {
  const ChatScreen({
    super.key,
    required this.conversation,
    required this.me,
    this.attachable = const <LearningContent>[],
  });

  final Conversation conversation;
  final AppUser me;
  final List<LearningContent> attachable;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String other = conversation.otherName(me.uid);
    return Scaffold(
      backgroundColor: AppColors.chatBackground,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text),
        titleSpacing: 0,
        title: Row(
          children: <Widget>[
            AppAvatar(name: other, size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(other, style: StyleText.fontSize15Weight600),
                  Text(
                    s.aboutChild(conversation.studentName),
                    style: StyleText.fontSize12Weight500.copyWith(color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: ChatView(conversation: conversation, me: me, attachable: attachable),
    );
  }
}
