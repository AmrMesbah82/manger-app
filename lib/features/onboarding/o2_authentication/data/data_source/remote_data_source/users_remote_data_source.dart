/// Module: onboarding / o2_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: users_remote_data_source.dart
/// Purpose: Declares `UsersRemoteDataSource` — every read and write against
///          `users` and Firebase Auth.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:manger_plus/core/constants/firebase_collections.dart';
import 'package:manger_plus/core/network/app_firebase.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/data/models/user_model.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/user_role.dart';

class UsersRemoteDataSource {
  CollectionReference<Map<String, dynamic>> get _users =>
      AppFirebase.db.collection(FirebaseCollections.users);

  DocumentReference<Map<String, dynamic>> get _setup => AppFirebase.db
      .collection(FirebaseCollections.config)
      .doc(FirebaseCollections.setupDoc);

  // ── Auth ─────────────────────────────────────────────────────────────────

  Future<UserCredential> signIn(String email, String password) =>
      AppFirebase.auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

  Future<void> signOut() => AppFirebase.auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      AppFirebase.auth.sendPasswordResetEmail(email: email.trim());

  User? get currentUser => AppFirebase.auth.currentUser;

  // ── First-run setup ──────────────────────────────────────────────────────

  /// True once the first admin exists. `config/setup` is readable by anyone
  /// (firestore.rules) precisely so the sign-in screen can ask this before
  /// anybody is signed in.
  Future<bool> isSetupDone() async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _setup.get();
    return doc.exists;
  }

  /// Creates the first admin: the Auth account, then — in ONE batch — the
  /// admin's profile and the `config/setup` marker. The rules allow an admin
  /// profile to be self-created only in a batch that also creates the marker,
  /// and only while the marker does not exist yet, so this works exactly once
  /// per project.
  Future<AppUser> createFirstAdmin({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final UserCredential credential =
        await AppFirebase.auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final String uid = credential.user!.uid;

    final AppUser admin = AppUser(
      uid: uid,
      email: email.trim().toLowerCase(),
      fullName: fullName.trim(),
      role: UserRole.admin,
    );

    final WriteBatch batch = AppFirebase.db.batch();
    batch.set(_users.doc(uid), UserModel.toMap(admin, isCreate: true));
    batch.set(_setup, <String, dynamic>{
      'admin_uid': uid,
      FirebaseCollections.createdAtField: FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return admin;
  }

  // ── Profiles ─────────────────────────────────────────────────────────────

  Future<AppUser?> fetch(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromDoc(doc);
  }

  Stream<AppUser?> watch(String uid) => _users
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? UserModel.fromDoc(doc) : null);

  /// Several profiles by id, as individual GETs in parallel.
  ///
  /// Not a `whereIn(documentId)` query: a query is judged by the rules as a
  /// whole, and a rule like "a parent may read a profile whose parent_ids
  /// contains them" cannot be proven for a query on ids. Single gets are
  /// judged document by document, which is exactly what that rule needs. A
  /// profile the caller may not read is skipped rather than failing the list.
  Future<List<AppUser>> fetchMany(List<String> uids) async {
    final List<String> ids = uids.where((id) => id.isNotEmpty).toSet().toList();
    if (ids.isEmpty) return const <AppUser>[];

    final List<AppUser?> results = await Future.wait(
      ids.map((String id) async {
        try {
          return await fetch(id);
        } catch (_) {
          return null;
        }
      }),
    );
    return results.whereType<AppUser>().toList();
  }

  /// Every account with [role]. Sorted on the client so the query needs no
  /// composite index.
  Stream<List<AppUser>> watchByRole(UserRole role) => _users
      .where(FirebaseCollections.roleField, isEqualTo: role.key)
      .snapshots()
      .map((snap) => _sorted(snap.docs.map(UserModel.fromDoc)));

  /// Students sitting in any of [sectionIds].
  Stream<List<AppUser>> watchStudentsIn(List<String> sectionIds) {
    final List<String> ids = sectionIds.where((id) => id.isNotEmpty).toList();
    if (ids.isEmpty) return Stream<List<AppUser>>.value(const <AppUser>[]);
    return _users
        .where(FirebaseCollections.roleField, isEqualTo: UserRole.student.key)
        .where(FirebaseCollections.sectionIdField,
            whereIn: ids.length > 30 ? ids.sublist(0, 30) : ids)
        .snapshots()
        .map((snap) => _sorted(snap.docs.map(UserModel.fromDoc)));
  }

  /// Teachers who teach [sectionId] — who a parent may message.
  Stream<List<AppUser>> watchTeachersOf(String sectionId) {
    if (sectionId.isEmpty) return Stream<List<AppUser>>.value(const <AppUser>[]);
    return _users
        .where(FirebaseCollections.roleField, isEqualTo: UserRole.teacher.key)
        .where(FirebaseCollections.sectionIdsField, arrayContains: sectionId)
        .snapshots()
        .map((snap) => _sorted(snap.docs.map(UserModel.fromDoc)));
  }

  List<AppUser> _sorted(Iterable<AppUser> users) {
    final List<AppUser> list = users.toList()
      ..sort((a, b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
    return list;
  }

  // ── Admin writes ─────────────────────────────────────────────────────────

  /// Creates the Auth account on the side app (the admin stays signed in),
  /// then the profile, then links parents and children both ways.
  Future<AppUser> create(AppUser draft, String password) async {
    final String uid = await AppFirebase.createAccount(
      email: draft.email,
      password: password,
    );
    final AppUser user = draft.copyWith(uid: uid);
    final WriteBatch batch = AppFirebase.db.batch();
    batch.set(_users.doc(uid), UserModel.toMap(user, isCreate: true));
    _linkFamily(batch, user, previous: null);
    await batch.commit();
    return user;
  }

  Future<void> update(AppUser user, {AppUser? previous}) async {
    final WriteBatch batch = AppFirebase.db.batch();
    batch.update(_users.doc(user.uid), UserModel.toMap(user));
    _linkFamily(batch, user, previous: previous);
    await batch.commit();
  }

  Future<void> updateSelf(AppUser user) =>
      _users.doc(user.uid).update(UserModel.toSelfUpdateMap(user));

  Future<void> setActive(String uid, bool active) =>
      _users.doc(uid).update(<String, dynamic>{
        FirebaseCollections.activeField: active,
        FirebaseCollections.updatedAtField: FieldValue.serverTimestamp(),
      });

  /// Deletes the PROFILE. The Firebase Auth account stays (the client SDK
  /// cannot delete another user) but without a profile it cannot get past
  /// the splash. Remove it in the Firebase console if you need the email back.
  Future<void> delete(AppUser user) async {
    final WriteBatch batch = AppFirebase.db.batch();
    batch.delete(_users.doc(user.uid));
    // Unlink so no parent keeps a dangling child and vice versa.
    for (final String parentId in user.parentIds) {
      batch.update(_users.doc(parentId), <String, dynamic>{
        UserModel.childrenIds: FieldValue.arrayRemove(<String>[user.uid]),
      });
    }
    for (final String childId in user.childrenIds) {
      batch.update(_users.doc(childId), <String, dynamic>{
        UserModel.parentIds: FieldValue.arrayRemove(<String>[user.uid]),
      });
    }
    await batch.commit();
  }

  /// Keeps `parent.children_ids` and `student.parent_ids` mirrors of each
  /// other. Both directions are stored because the rules need each one: a
  /// parent reads a child's data by checking `children_ids`, and a child's
  /// profile is readable by uids in its `parent_ids`.
  void _linkFamily(WriteBatch batch, AppUser user, {AppUser? previous}) {
    if (user.role == UserRole.parent) {
      final Set<String> before = previous?.childrenIds.toSet() ?? <String>{};
      final Set<String> after = user.childrenIds.toSet();
      for (final String id in after.difference(before)) {
        batch.update(_users.doc(id), <String, dynamic>{
          UserModel.parentIds: FieldValue.arrayUnion(<String>[user.uid]),
        });
      }
      for (final String id in before.difference(after)) {
        batch.update(_users.doc(id), <String, dynamic>{
          UserModel.parentIds: FieldValue.arrayRemove(<String>[user.uid]),
        });
      }
    }
    if (user.role == UserRole.student) {
      final Set<String> before = previous?.parentIds.toSet() ?? <String>{};
      final Set<String> after = user.parentIds.toSet();
      for (final String id in after.difference(before)) {
        batch.update(_users.doc(id), <String, dynamic>{
          UserModel.childrenIds: FieldValue.arrayUnion(<String>[user.uid]),
        });
      }
      for (final String id in before.difference(after)) {
        batch.update(_users.doc(id), <String, dynamic>{
          UserModel.childrenIds: FieldValue.arrayRemove(<String>[user.uid]),
        });
      }
    }
  }
}
