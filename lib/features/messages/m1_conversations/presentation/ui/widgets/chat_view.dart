/// Module: messages / m1_conversations
///
///*************************** FILE INFO ****************************///
/// File Name: chat_view.dart
/// Purpose: Declares `ChatView` (a thread and its composer) and
///          `ConversationTile` — shared by the console inbox and the parent
///          app.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_padding.dart';
import 'package:manger_plus/core/theme/app_radius.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/messages/m1_conversations/data/repository/messages_repository.dart';
import 'package:manger_plus/features/messages/m1_conversations/domain/entities/conversation.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/content_type.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

/// Messages, newest at the bottom, with a composer that can tag a message
/// with an assignment ("about: Unit 2 exam").
class ChatView extends StatefulWidget {
  const ChatView({
    super.key,
    required this.conversation,
    required this.me,
    this.attachable = const <LearningContent>[],
  });

  final Conversation conversation;
  final AppUser me;

  /// Items the sender may tag the message with — the child's assignments
  /// for a parent, the teacher's own content for a teacher.
  final List<LearningContent> attachable;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final MessagesRepository _repository = MessagesRepository();
  final TextEditingController _text = TextEditingController();
  final ScrollController _scroll = ScrollController();

  late Stream<List<ChatMessage>> _messages =
      _repository.watchMessages(widget.conversation.id);
  LearningContent? _about;
  bool _sending = false;

  @override
  void didUpdateWidget(ChatView old) {
    super.didUpdateWidget(old);
    if (old.conversation.id != widget.conversation.id) {
      _messages = _repository.watchMessages(widget.conversation.id);
      _about = null;
    }
  }

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final String text = _text.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    final Either<AppFailure, Unit> r = await _repository.send(
      conversation: widget.conversation,
      senderId: widget.me.uid,
      senderName: widget.me.displayName,
      text: text,
      contentId: _about?.id ?? '',
      contentTitle: _about?.title ?? '',
    );
    if (!mounted) return;
    setState(() => _sending = false);
    r.fold(
      (AppFailure f) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(f.message(context)))),
      (_) {
        _text.clear();
        setState(() => _about = null);
      },
    );
  }

  Future<void> _pickAbout() async {
    final LearningContent? picked = await showModalBottomSheet<LearningContent>(
      context: context,
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
      ),
      builder: (BuildContext ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(AppPadding.h, 4.h, AppPadding.h, 8.h),
              child: Text(S.of(ctx).aboutAssignment, style: StyleText.fontSize16Weight600),
            ),
            for (final LearningContent c in widget.attachable)
              ListTile(
                leading: ContentTypeIcon(type: c.type, size: 36.sp),
                title: Text(c.title, style: StyleText.fontSize14Weight600),
                subtitle: Text(c.type.label(ctx), style: StyleText.fontSize12Weight400),
                onTap: () => Navigator.of(ctx).pop(c),
              ),
          ],
        ),
      ),
    );
    if (picked != null && mounted) setState(() => _about = picked);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Column(
      children: <Widget>[
        Expanded(
          child: StreamBuilder<List<ChatMessage>>(
            stream: _messages,
            builder: (BuildContext context, AsyncSnapshot<List<ChatMessage>> snap) {
              if (snap.hasError) {
                return AppErrorView(message: AppFailure.from(snap.error!).message(context));
              }
              if (!snap.hasData) return const AppLoading();
              final List<ChatMessage> messages = snap.data!;
              if (messages.isEmpty) {
                return AppEmptyView(title: s.noMessagesYet, subtitle: s.noMessagesYetSub, size: 120.sp);
              }
              // reverse: the list grows from the bottom, and a new message
              // appears without any scroll bookkeeping.
              return ListView.builder(
                controller: _scroll,
                reverse: true,
                padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 16.r),
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int i) {
                  final ChatMessage m = messages[messages.length - 1 - i];
                  return _Bubble(message: m, mine: m.senderId == widget.me.uid);
                },
              );
            },
          ),
        ),
        _composer(context),
      ],
    );
  }

  Widget _composer(BuildContext context) {
    final S s = S.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(AppPadding.h, 8.h, AppPadding.h, 12.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.borderGrey.withOpacity(0.3))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (_about != null)
              Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: InputChip(
                  avatar: ContentTypeIcon(type: _about!.type, size: 18.sp),
                  label: Text(s.aboutTitle(_about!.title), style: StyleText.fontSize12Weight600),
                  onDeleted: () => setState(() => _about = null),
                ),
              ),
            Row(
              children: <Widget>[
                if (widget.attachable.isNotEmpty)
                  IconButton(
                    tooltip: s.aboutAssignment,
                    onPressed: _pickAbout,
                    icon: AppIcon(Icons.assignment_outlined, color: AppColors.primary),
                  ),
                Expanded(
                  child: TextField(
                    controller: _text,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    style: StyleText.fontSize14Weight500,
                    decoration: InputDecoration(
                      hintText: s.typeMessage,
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 10.h),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.fieldR,
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? SizedBox(
                            width: 18.r,
                            height: 18.r,
                            child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const AppIcon(Icons.send_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});

  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final Color bg = mine ? AppColors.primary : AppColors.card;
    final Color fg = mine ? Colors.white : AppColors.text;

    return Align(
      alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        child: Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 10.h),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(16.r),
              topEnd: Radius.circular(16.r),
              bottomStart: Radius.circular(mine ? 16.r : 4.r),
              bottomEnd: Radius.circular(mine ? 4.r : 16.r),
            ),
            boxShadow: mine
                ? null
                : <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6.sp,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (message.isAboutContent)
                Container(
                  margin: EdgeInsets.only(bottom: 6.h),
                  padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: (mine ? Colors.white : AppColors.primary).withOpacity(0.15),
                    borderRadius: AppRadius.containerR,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AppIcon(Icons.assignment_outlined, size: 14.sp, color: mine ? Colors.white : AppColors.primary),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          message.contentTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StyleText.fontSize12Weight600
                              .copyWith(color: mine ? Colors.white : AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              Text(message.text, style: StyleText.fontSize14Weight500.copyWith(color: fg)),
              SizedBox(height: 2.h),
              Text(
                AppDates.time(context, message.createdAt),
                style: StyleText.fontSize10Weight400.copyWith(color: fg.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One row in an inbox.
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.myUid,
    required this.onTap,
    this.selected = false,
  });

  final Conversation conversation;
  final String myUid;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Conversation c = conversation;
    final String other = c.otherName(myUid);
    final bool fromMe = c.lastSenderId == myUid;

    return Material(
      color: selected ? AppColors.primary.withOpacity(0.1) : AppColors.card,
      borderRadius: AppRadius.containerR,
      child: InkWell(
        borderRadius: AppRadius.containerR,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 12.r),
          child: Row(
            children: <Widget>[
              AppAvatar(name: other, size: 44),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(other,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: StyleText.fontSize14Weight600),
                        ),
                        Text(
                          AppDates.dateTime(context, c.lastAt),
                          style: StyleText.fontSize11Weight400
                              .copyWith(color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                    Text(
                      s.aboutChild(c.studentName),
                      style: StyleText.fontSize12Weight500.copyWith(color: AppColors.primary),
                    ),
                    Text(
                      c.lastMessage.isEmpty
                          ? s.noMessagesYet
                          : (fromMe ? '${s.you}: ' : '') + c.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
