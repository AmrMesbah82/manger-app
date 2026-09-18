/// Module: messages / m1_conversations
///
///*************************** FILE INFO ****************************///
/// File Name: messages_base_repository.dart
/// Purpose: Declares `MessagesBaseRepository`.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:dartz/dartz.dart';

import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/features/messages/m1_conversations/domain/entities/conversation.dart';

abstract class MessagesBaseRepository {
  /// Every thread [uid] takes part in, most recent first.
  Stream<List<Conversation>> watchInbox(String uid);

  Stream<List<ChatMessage>> watchMessages(String conversationId);

  /// Creates the thread if it does not exist yet, and returns it.
  Future<Either<AppFailure, Conversation>> open(Conversation conversation);

  Future<Either<AppFailure, Unit>> send({
    required Conversation conversation,
    required String senderId,
    required String senderName,
    required String text,
    String contentId = '',
    String contentTitle = '',
  });
}
