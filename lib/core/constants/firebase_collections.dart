/// Module: core/constants
///
///*************************** FILE INFO ****************************///
/// File Name: firebase_collections.dart
/// Purpose: Single source of truth for Firestore collection, field and Storage
///          folder names.
/// Author: Manger Plus team
/// Created: 18/9/2026
///
/// Never type a collection name at a call site. A name typed inline is a name
/// that eventually drifts — `learning_content` in one screen and
/// `learningContent` in another, and one of them quietly reads nothing.
///
/// Layout is FLAT and top-level: one learning center per Firebase project.
///
///   users/{uid}                 every account (admin, teacher, student, parent)
///   sections/{id}               a class group students belong to
///   content/{id}                video / pdf / image / exam / quiz
///   submissions/{contentId_uid} a student's answers + score for an exam/quiz
///   attendance/{date_uid}       one row per student per day
///   conversations/{id}          parent <-> teacher thread
///     messages/{id}
///   config/setup                exists once the first admin was created

abstract final class FirebaseCollections {
  const FirebaseCollections._();

  // ── Collections ──────────────────────────────────────────────────────────
  static const String users = 'users';
  static const String sections = 'sections';
  static const String content = 'content';
  static const String submissions = 'submissions';
  static const String attendance = 'attendance';
  static const String conversations = 'conversations';
  static const String messages = 'messages';
  static const String config = 'config';

  /// `config/setup` — written in the same batch as the first admin. Its
  /// existence is what closes the first-run setup door in firestore.rules.
  static const String setupDoc = 'setup';

  // ── Shared field names (only fields that are queried / ordered by) ───────
  static const String createdAtField = 'created_at';
  static const String updatedAtField = 'updated_at';
  static const String roleField = 'role';
  static const String activeField = 'active';
  static const String sectionIdField = 'section_id';
  static const String sectionIdsField = 'section_ids';
  static const String studentIdField = 'student_id';
  static const String studentIdsField = 'student_ids';
  static const String teacherIdField = 'teacher_id';
  static const String teacherIdsField = 'teacher_ids';
  static const String contentIdField = 'content_id';
  static const String typeField = 'type';
  static const String dateField = 'date';
  static const String participantIdsField = 'participant_ids';
  static const String lastAtField = 'last_at';
  static const String demoField = 'demo';

  // ── Storage folders ──────────────────────────────────────────────────────
  /// `content/{teacherUid}/{timestamp}_{fileName}`
  static const String storageContent = 'content';
}
