/// Module: academy / ac1_core
///
///*************************** FILE INFO ****************************///
/// File Name: sections_remote_data_source.dart
/// Purpose: Declares `SectionsRemoteDataSource`.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:manger_plus/core/constants/firebase_collections.dart';
import 'package:manger_plus/core/network/app_firebase.dart';
import 'package:manger_plus/features/academy/ac1_core/data/models/academy_models.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/section.dart';

class SectionsRemoteDataSource {
  CollectionReference<Map<String, dynamic>> get _sections =>
      AppFirebase.db.collection(FirebaseCollections.sections);

  Stream<List<Section>> watchAll() => _sections.snapshots().map((snap) {
        final List<Section> list = snap.docs.map(SectionModel.fromDoc).toList()
          ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        return list;
      });

  Future<String> save(Section section) async {
    if (section.id.isEmpty) {
      final DocumentReference<Map<String, dynamic>> ref =
          await _sections.add(SectionModel.toMap(section, isCreate: true));
      return ref.id;
    }
    await _sections.doc(section.id).set(
          SectionModel.toMap(section),
          SetOptions(merge: true),
        );
    return section.id;
  }

  Future<void> delete(String id) => _sections.doc(id).delete();
}
