/// Module: messages / m1_conversations
///
///*************************** FILE INFO ****************************///
/// File Name: conversation.dart
/// Purpose: Declares `Conversation` and `ChatMessage`.
/// Author: Manger Plus team
/// Created: 18/9/2026

/// A thread between one parent and one teacher about one child.
///
/// The id is `{teacherId}_{parentId}_{studentId}`, so "message Ms. Sara about
/// Omar" always reopens the same thread instead of starting a new one.
class Conversation {
  final String id;

  /// `[teacherId, parentId]` — what the rules and the inbox query read.
  final List<String> participantIds;
  final String teacherId;
  final String teacherName;
  final String parentId;
  final String parentName;
  final String studentId;
  final String studentName;
  final String lastMessage;
  final String lastSenderId;
  final DateTime? lastAt;
  final bool demo;

  const Conversation({
    required this.id,
    required this.teacherId,
    required this.parentId,
    required this.studentId,
    this.participantIds = const <String>[],
    this.teacherName = '',
    this.parentName = '',
    this.studentName = '',
    this.lastMessage = '',
    this.lastSenderId = '',
    this.lastAt,
    this.demo = false,
  });

  static String idFor({
    required String teacherId,
    required String parentId,
    required String studentId,
  }) =>
      '${teacherId}_${parentId}_$studentId';

  /// The name of the other side, from [myUid]'s point of view.
  String otherName(String myUid) => myUid == teacherId ? parentName : teacherName;
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;

  /// Set when the message is ABOUT an assignment — the parent picked one when
  /// writing it. Shown as a chip above the text.
  final String contentId;
  final String contentTitle;
  final DateTime? createdAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.senderName = '',
    this.contentId = '',
    this.contentTitle = '',
    this.createdAt,
  });

  bool get isAboutContent => contentId.isNotEmpty;
}
