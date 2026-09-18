/// Module: academy / ac1_core
///
///*************************** FILE INFO ****************************///
/// File Name: content_remote_data_source.dart
/// Purpose: Declares `ContentRemoteDataSource` — `content` documents and the
///          files behind them in Cloud Storage.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:manger_plus/core/constants/firebase_collections.dart';
import 'package:manger_plus/core/helper/main_helper/stream_combine.dart';
import 'package:manger_plus/core/network/app_firebase.dart';
import 'package:manger_plus/features/academy/ac1_core/data/models/academy_models.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/base_repository/academy_base_repository.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';

class ContentRemoteDataSource {
  CollectionReference<Map<String, dynamic>> get _content =>
      AppFirebase.db.collection(FirebaseCollections.content);

  // ── Reads ────────────────────────────────────────────────────────────────
  //
  // Every list is sorted newest-first ON THE CLIENT. Ordering in the query
  // would need a composite index per filter; these lists are a center's worth
  // of material, not millions of rows.

  Stream<List<LearningContent>> watchAll() =>
      _content.snapshots().map((snap) => _newestFirst(snap.docs));

  Stream<List<LearningContent>> watchByTeacher(String teacherId) => _content
      .where(FirebaseCollections.teacherIdField, isEqualTo: teacherId)
      .snapshots()
      .map((snap) => _newestFirst(snap.docs));

  /// Two queries — "assigned to my section" and "assigned to me by name" —
  /// merged and de-duplicated. Firestore cannot OR two array-contains filters
  /// in one query, and the rules check each shape separately.
  Stream<List<LearningContent>> watchForStudent(AppUser student) {
    final List<Stream<List<LearningContent>>> sources =
        <Stream<List<LearningContent>>>[
      _content
          .where('published', isEqualTo: true)
          .where(FirebaseCollections.studentIdsField, arrayContains: student.uid)
          .snapshots()
          .map((snap) => snap.docs.map(ContentModel.fromDoc).toList()),
      if (student.sectionId.isNotEmpty)
        _content
            .where('published', isEqualTo: true)
            .where(FirebaseCollections.sectionIdsField,
                arrayContains: student.sectionId)
            .snapshots()
            .map((snap) => snap.docs.map(ContentModel.fromDoc).toList()),
    ];

    return combineLatest<List<LearningContent>, List<LearningContent>>(
      sources,
      (List<List<LearningContent>> lists) {
        final Map<String, LearningContent> byId = <String, LearningContent>{
          for (final List<LearningContent> list in lists)
            for (final LearningContent c in list) c.id: c,
        };
        return _sortNewest(byId.values.toList());
      },
    );
  }

  Future<LearningContent?> fetch(String id) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _content.doc(id).get();
    if (!doc.exists) return null;
    return ContentModel.fromDoc(doc);
  }

  // ── Writes ───────────────────────────────────────────────────────────────

  Future<String> save(LearningContent content) async {
    if (content.id.isEmpty) {
      final DocumentReference<Map<String, dynamic>> ref =
          await _content.add(ContentModel.toMap(content, isCreate: true));
      return ref.id;
    }
    await _content.doc(content.id).update(ContentModel.toMap(content));
    return content.id;
  }

  Future<void> delete(LearningContent content) async {
    await _content.doc(content.id).delete();
    if (content.storagePath.isNotEmpty) {
      try {
        await AppFirebase.storage.ref(content.storagePath).delete();
      } catch (_) {
        // The document is gone, which is what the user asked for. An orphaned
        // file costs a little storage; failing the delete would be worse.
      }
    }
  }

  // ── Storage ──────────────────────────────────────────────────────────────

  Future<UploadedFile> upload({
    required String teacherId,
    required PickedUpload file,
    void Function(double progress)? onProgress,
  }) async {
    final String safeName =
        file.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final String path = '${FirebaseCollections.storageContent}/$teacherId/'
        '${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final Reference ref = AppFirebase.storage.ref(path);
    final SettableMetadata meta =
        SettableMetadata(contentType: _mimeFor(safeName));

    final UploadTask task = file.bytes != null
        ? ref.putData(file.bytes!, meta)
        : ref.putFile(File(file.path!), meta);

    final StreamSubscription<TaskSnapshot> progress =
        task.snapshotEvents.listen((TaskSnapshot snap) {
      if (snap.totalBytes > 0) {
        onProgress?.call(snap.bytesTransferred / snap.totalBytes);
      }
    });

    try {
      await task;
    } finally {
      await progress.cancel();
    }

    return UploadedFile(
      url: await ref.getDownloadURL(),
      storagePath: path,
      fileName: file.name,
    );
  }

  /// Sent as metadata so a browser opening the download URL plays or shows
  /// the file rather than downloading an octet-stream.
  static String _mimeFor(String name) {
    final String ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'mp4':
      case 'm4v':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'webm':
        return 'video/webm';
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }

  List<LearningContent> _newestFirst(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) =>
      _sortNewest(docs.map(ContentModel.fromDoc).toList());

  static List<LearningContent> _sortNewest(List<LearningContent> list) {
    // A document written a moment ago has no server timestamp yet; treat it
    // as the newest so it appears at the top straight away.
    final DateTime pending = DateTime(9999);
    list.sort((a, b) =>
        (b.createdAt ?? pending).compareTo(a.createdAt ?? pending));
    return list;
  }
}
