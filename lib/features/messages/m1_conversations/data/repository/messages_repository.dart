/// Module: messages / m1_conversations
///
///*************************** FILE INFO ****************************///
/// File Name: messages_repository.dart
/// Purpose: Declares `ConversationModel`, `MessagesRemoteDataSource` and
///          `MessagesRepository`.
/// Author: Manger Plus team
/// Created: 18/9/2026
///
/// Model, data source and repository in one file: the feature is two
/// collections and a handful of calls, and three files of forty lines each
/// would be harder to follow than one.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:manger_plus/core/constants/firebase_collections.dart';
import 'package:manger_plus/core/helper/main_helper/firestore_mapper.dart';
import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/core/network/app_firebase.dart';
import 'package:manger_plus/core/network/guard.dart';
import 'package:manger_plus/features/messages/m1_conversations/domain/base_repository/messages_base_repository.dart';
import 'package:manger_plus/features/messages/m1_conversations/domain/entities/conversation.dart';

abstract final class ConversationModel {
  const ConversationModel._();

  static Conversation fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> d = doc.safeData;
    return Conversation(
      id: doc.id,
      participantIds: d.stringList(FirebaseCollections.participantIdsField),
      teacherId: d.str(FirebaseCollections.teacherIdField),
      teacherName: d.str('teacher_name'),
      parentId: d.str('parent_id'),
      parentName: d.str('parent_name'),
      studentId: d.str(FirebaseCollections.studentIdField),
      studentName: d.str('student_name'),
      lastMessage: d.str('last_message'),
      lastSenderId: d.str('last_sender_id'),
      lastAt: d.date(FirebaseCollections.lastAtField),
      demo: d.boolean(FirebaseCollections.demoField),
    );
  }

  /// The thread's identity — safe to `set(merge: true)` again and again.
  static Map<String, dynamic> toHeaderMap(Conversation c) => <String, dynamic>{
        FirebaseCollections.participantIdsField: <String>[c.teacherId, c.parentId],
        FirebaseCollections.teacherIdField: c.teacherId,
        'teacher_name': c.teacherName,
        'parent_id': c.parentId,
        'parent_name': c.parentName,
        FirebaseCollections.studentIdField: c.studentId,
        'student_name': c.studentName,
        FirebaseCollections.demoField: c.demo,
      };

  static ChatMessage messageFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> d = doc.safeData;
    return ChatMessage(
      id: doc.id,
      senderId: d.str('sender_id'),
      senderName: d.str('sender_name'),
      text: d.str('text'),
      contentId: d.str(FirebaseCollections.contentIdField),
      contentTitle: d.str('content_title'),
      createdAt: d.date(FirebaseCollections.createdAtField),
    );
  }
}

class MessagesRemoteDataSource {
  CollectionReference<Map<String, dynamic>> get _conversations =>
      AppFirebase.db.collection(FirebaseCollections.conversations);

  /// `array-contains uid` is exactly the shape the rules check
  /// (`request.auth.uid in resource.data.participant_ids`).
  Stream<List<Conversation>> watchInbox(String uid) => _conversations
          .where(FirebaseCollections.participantIdsField, arrayContains: uid)
          .snapshots()
          .map((snap) {
        final DateTime pending = DateTime(9999);
        return snap.docs.map(ConversationModel.fromDoc).toList()
          ..sort((a, b) => (b.lastAt ?? pending).compareTo(a.lastAt ?? pending));
      });

  Stream<List<ChatMessage>> watchMessages(String conversationId) => _conversations
      .doc(conversationId)
      .collection(FirebaseCollections.messages)
      .orderBy(FirebaseCollections.createdAtField)
      .limitToLast(300)
      .snapshots()
      .map((snap) => snap.docs.map(ConversationModel.messageFromDoc).toList());

  Future<Conversation> open(Conversation c) async {
    await _conversations
        .doc(c.id)
        .set(ConversationModel.toHeaderMap(c), SetOptions(merge: true));
    return c;
  }

  /// The message and the thread's "last message" preview in one batch, so
  /// the inbox never shows a preview for a message that failed to send.
  Future<void> send({
    required Conversation conversation,
    required String senderId,
    required String senderName,
    required String text,
    String contentId = '',
    String contentTitle = '',
  }) async {
    final DocumentReference<Map<String, dynamic>> thread =
        _conversations.doc(conversation.id);
    final WriteBatch batch = AppFirebase.db.batch();

    batch.set(
      thread,
      <String, dynamic>{
        ...ConversationModel.toHeaderMap(conversation),
        'last_message': text.trim(),
        'last_sender_id': senderId,
        FirebaseCollections.lastAtField: FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    batch.set(thread.collection(FirebaseCollections.messages).doc(), <String, dynamic>{
      'sender_id': senderId,
      'sender_name': senderName,
      'text': text.trim(),
      FirebaseCollections.contentIdField: contentId,
      'content_title': contentTitle,
      FirebaseCollections.createdAtField: FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}

class MessagesRepository implements MessagesBaseRepository {
  MessagesRepository({MessagesRemoteDataSource? remote})
      : _remote = remote ?? MessagesRemoteDataSource();

  final MessagesRemoteDataSource _remote;

  @override
  Stream<List<Conversation>> watchInbox(String uid) => _remote.watchInbox(uid);

  @override
  Stream<List<ChatMessage>> watchMessages(String conversationId) =>
      _remote.watchMessages(conversationId);

  @override
  Future<Either<AppFailure, Conversation>> open(Conversation conversation) =>
      guard(() => _remote.open(conversation));

  @override
  Future<Either<AppFailure, Unit>> send({
    required Conversation conversation,
    required String senderId,
    required String senderName,
    required String text,
    String contentId = '',
    String contentTitle = '',
  }) =>
      guardUnit(() => _remote.send(
            conversation: conversation,
            senderId: senderId,
            senderName: senderName,
            text: text,
            contentId: contentId,
            contentTitle: contentTitle,
          ));
}
