/// Module: console / c3_settings
///
///*************************** FILE INFO ****************************///
/// File Name: demo_seeder.dart
/// Purpose: Declares `DemoSeeder` — the "Fill demo data" button's engine.
/// Author: Manger Plus team
/// Created: 18/9/2026
///
/// WHAT IT WRITES
/// --------------
/// Two sections, two teachers, six students, three parents (one with two
/// children), seven pieces of content across all five types, exam and quiz
/// results, ten school days of attendance, and one parent–teacher thread.
///
/// Every account uses [AppConstants.demoPassword] and an email under
/// [AppConstants.demoEmailDomain], so you can sign in as any of them:
///
///   sara@demo.mangerplus.app     teacher (every switch on)
///   omar@demo.mangerplus.app     teacher (no exams, grades or messages)
///   youssef@demo.mangerplus.app  student      mona@…  parent of two
///
/// Every document carries `demo: true` and a `demo_` id, so running it twice
/// overwrites rather than duplicates, and [clear] finds all of it.
///
/// The media files are public sample URLs — the button fills FIRESTORE. Real
/// lessons are uploaded from the Content page into Cloud Storage.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:manger_plus/core/constants/app_constants.dart';
import 'package:manger_plus/core/constants/firebase_collections.dart';
import 'package:manger_plus/core/network/app_firebase.dart';
import 'package:manger_plus/features/academy/ac1_core/data/models/academy_models.dart';
import 'package:manger_plus/features/academy/ac1_core/data/utils/academy_utils.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/attendance_record.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/section.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/submission.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/attendance_status.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/content_type.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/data/models/user_model.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/teacher_permission.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/user_role.dart';

/// Reports what the seeder is doing, for the progress dialog.
typedef SeedProgress = void Function(String step, double fraction);

class DemoSeeder {
  DemoSeeder({FirebaseFirestore? db}) : _db = db ?? AppFirebase.db;

  final FirebaseFirestore _db;

  // Public sample media. Chosen because they are small, stable, and served
  // with the right content type.
  static const String sampleVideo =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
  static const String sampleVideo2 =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
  static const String samplePdf =
      'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
  static const String sampleImage =
      'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg';

  static const String _secA = 'demo_sec_a';
  static const String _secB = 'demo_sec_b';

  String _email(String name) => '$name@${AppConstants.demoEmailDomain}';

  Future<void> seed({SeedProgress? onProgress}) async {
    void step(String s, double f) => onProgress?.call(s, f);

    // ── Sections ───────────────────────────────────────────────────────────
    step('Sections', 0.05);
    final List<Section> sections = <Section>[
      const Section(id: _secA, name: 'Grade 7 — A', level: 'Grade 7', demo: true),
      const Section(id: _secB, name: 'Grade 8 — B', level: 'Grade 8', demo: true),
    ];
    for (final Section s in sections) {
      await _db
          .collection(FirebaseCollections.sections)
          .doc(s.id)
          .set(SectionModel.toMap(s, isCreate: true));
    }

    // ── Accounts ───────────────────────────────────────────────────────────
    // Created one by one: each is an Auth call on the side app.
    step('Teachers', 0.15);
    final AppUser sara = await _account(
      key: 'sara',
      name: 'Sara Ahmed',
      role: UserRole.teacher,
      subject: 'Mathematics',
      sectionIds: <String>[_secA, _secB],
      permissions: TeacherPermission.values.toSet(),
    );
    final AppUser omar = await _account(
      key: 'omar',
      name: 'Omar Khaled',
      role: UserRole.teacher,
      subject: 'Science',
      sectionIds: <String>[_secB],
      permissions: <TeacherPermission>{
        TeacherPermission.video,
        TeacherPermission.pdf,
        TeacherPermission.image,
        TeacherPermission.quiz,
        TeacherPermission.attendance,
      },
    );

    step('Students', 0.3);
    final List<AppUser> students = <AppUser>[];
    const List<List<String>> studentSeed = <List<String>>[
      <String>['youssef', 'Youssef Mahmoud', _secA],
      <String>['laila', 'Laila Hassan', _secA],
      <String>['adam', 'Adam Tarek', _secA],
      <String>['nour', 'Nour Samir', _secB],
      <String>['karim', 'Karim Adel', _secB],
      <String>['hana', 'Hana Mostafa', _secB],
    ];
    for (final List<String> s in studentSeed) {
      students.add(await _account(
        key: s[0],
        name: s[1],
        role: UserRole.student,
        sectionId: s[2],
      ));
    }

    step('Parents', 0.45);
    // Mona has two children in different sections — the parent app's child
    // switcher needs someone to switch between.
    final AppUser mona = await _account(
      key: 'mona',
      name: 'Mona Mahmoud',
      role: UserRole.parent,
      childrenIds: <String>[students[0].uid, students[3].uid],
    );
    final AppUser hassan = await _account(
      key: 'hassan',
      name: 'Hassan Ali',
      role: UserRole.parent,
      childrenIds: <String>[students[1].uid],
    );
    final AppUser adel = await _account(
      key: 'adel',
      name: 'Adel Fathy',
      role: UserRole.parent,
      childrenIds: <String>[students[4].uid],
    );

    // Mirror children -> parents on the student documents.
    final WriteBatch family = _db.batch();
    for (final AppUser parent in <AppUser>[mona, hassan, adel]) {
      for (final String childId in parent.childrenIds) {
        family.update(
          _db.collection(FirebaseCollections.users).doc(childId),
          <String, dynamic>{
            UserModel.parentIds: FieldValue.arrayUnion(<String>[parent.uid]),
          },
        );
      }
    }
    await family.commit();

    // ── Content ────────────────────────────────────────────────────────────
    step('Content', 0.6);
    final DateTime now = DateTime.now();
    final List<LearningContent> content = <LearningContent>[
      LearningContent(
        id: 'demo_video_fractions',
        type: ContentType.video,
        title: 'Fractions made simple',
        description: 'A short lesson on adding and comparing fractions.',
        subject: 'Mathematics',
        teacherId: sara.uid,
        teacherName: sara.displayName,
        fileUrl: sampleVideo,
        fileName: 'fractions.mp4',
        sectionIds: const <String>[_secA, _secB],
      ),
      LearningContent(
        id: 'demo_pdf_worksheet',
        type: ContentType.pdf,
        title: 'Worksheet 3 — Decimals',
        description: 'Print it or solve it on paper, then bring it on Sunday.',
        subject: 'Mathematics',
        teacherId: sara.uid,
        teacherName: sara.displayName,
        fileUrl: samplePdf,
        fileName: 'worksheet-3.pdf',
        sectionIds: const <String>[_secA],
        dueAt: now.add(const Duration(days: 4)),
      ),
      LearningContent(
        id: 'demo_image_angles',
        type: ContentType.image,
        title: 'Angles cheat-sheet',
        subject: 'Mathematics',
        teacherId: sara.uid,
        teacherName: sara.displayName,
        fileUrl: sampleImage,
        fileName: 'angles.jpg',
        sectionIds: const <String>[_secB],
      ),
      LearningContent(
        id: 'demo_exam_unit2',
        type: ContentType.exam,
        title: 'Unit 2 exam',
        description: 'Five questions, thirty minutes. Read each one carefully.',
        subject: 'Mathematics',
        teacherId: sara.uid,
        teacherName: sara.displayName,
        durationMinutes: 30,
        sectionIds: const <String>[_secA],
        dueAt: now.add(const Duration(days: 2)),
        questions: const <Question>[
          Question(text: '1/2 + 1/4 = ?', options: <String>['3/4', '2/6', '1/6', '2/4'], correctIndex: 0, points: 2),
          Question(text: '0.5 is the same as…', options: <String>['1/5', '1/2', '5/1', '2/5'], correctIndex: 1, points: 2),
          Question(text: 'Which is largest?', options: <String>['0.35', '0.305', '0.4', '0.09'], correctIndex: 2, points: 2),
          Question(text: '3 × 0.2 = ?', options: <String>['0.6', '6', '0.06', '0.32'], correctIndex: 0, points: 2),
          Question(text: '25% of 80 is…', options: <String>['25', '20', '40', '16'], correctIndex: 1, points: 2),
        ],
      ),
      LearningContent(
        id: 'demo_quiz_warmup',
        type: ContentType.quiz,
        title: 'Warm-up quiz',
        subject: 'Mathematics',
        teacherId: sara.uid,
        teacherName: sara.displayName,
        durationMinutes: 5,
        // Assigned to one student by name, not to a section.
        studentIds: <String>[students[3].uid],
        questions: const <Question>[
          Question(text: '7 × 8 = ?', options: <String>['54', '56', '64'], correctIndex: 1),
          Question(text: '81 ÷ 9 = ?', options: <String>['8', '9', '7'], correctIndex: 1),
          Question(text: '12 + 19 = ?', options: <String>['31', '29', '32'], correctIndex: 0),
        ],
      ),
      LearningContent(
        id: 'demo_video_plants',
        type: ContentType.video,
        title: 'How plants make food',
        description: 'Photosynthesis in five minutes.',
        subject: 'Science',
        teacherId: omar.uid,
        teacherName: omar.displayName,
        fileUrl: sampleVideo2,
        fileName: 'plants.mp4',
        sectionIds: const <String>[_secB],
      ),
      LearningContent(
        id: 'demo_quiz_cells',
        type: ContentType.quiz,
        title: 'Cells quiz',
        subject: 'Science',
        teacherId: omar.uid,
        teacherName: omar.displayName,
        durationMinutes: 10,
        sectionIds: const <String>[_secB],
        questions: const <Question>[
          Question(text: 'The control centre of the cell is the…', options: <String>['Nucleus', 'Wall', 'Membrane'], correctIndex: 0),
          Question(text: 'Plants make food in the…', options: <String>['Roots', 'Chloroplasts', 'Stem'], correctIndex: 1),
        ],
      ),
    ];
    final WriteBatch contentBatch = _db.batch();
    for (final LearningContent c in content) {
      contentBatch.set(
        _db.collection(FirebaseCollections.content).doc(c.id),
        <String, dynamic>{
          ...ContentModel.toMap(c, isCreate: true),
          FirebaseCollections.demoField: true,
        },
      );
    }
    await contentBatch.commit();

    // ── Results ────────────────────────────────────────────────────────────
    step('Results', 0.72);
    final LearningContent exam = content[3];
    final LearningContent warmup = content[4];
    final LearningContent cells = content[6];
    final List<(AppUser, LearningContent, List<int>)> results =
        <(AppUser, LearningContent, List<int>)>[
      (students[0], exam, <int>[0, 1, 2, 0, 0]),
      (students[1], exam, <int>[0, 1, 1, 0, 1]),
      (students[3], warmup, <int>[1, 1, 0]),
      (students[3], cells, <int>[0, 1]),
      (students[4], cells, <int>[0, 0]),
    ];
    final WriteBatch resultBatch = _db.batch();
    for (final (AppUser student, LearningContent c, List<int> answers) in results) {
      final Submission sub = Submission(
        id: Submission.idFor(c.id, student.uid),
        contentId: c.id,
        contentTitle: c.title,
        contentType: c.type,
        teacherId: c.teacherId,
        studentId: student.uid,
        studentName: student.displayName,
        sectionId: student.sectionId,
        answers: answers,
        score: ExamGrader.score(c, answers),
        total: c.totalPoints,
        demo: true,
        submittedAt: now.subtract(const Duration(days: 1)),
      );
      resultBatch.set(
        _db.collection(FirebaseCollections.submissions).doc(sub.id),
        SubmissionModel.toMap(sub),
      );
    }
    await resultBatch.commit();

    // ── Attendance ─────────────────────────────────────────────────────────
    step('Attendance', 0.84);
    final WriteBatch attendance = _db.batch();
    int day = 0;
    int written = 0;
    while (written < 10) {
      day++;
      final DateTime date = now.subtract(Duration(days: day));
      // Friday and Saturday off.
      if (date.weekday == DateTime.friday || date.weekday == DateTime.saturday) {
        continue;
      }
      for (int i = 0; i < students.length; i++) {
        final AppUser s = students[i];
        // Deterministic spread: most present, a few absences and late days.
        final int roll = (written * 7 + i * 3) % 10;
        final AttendanceStatus status = roll == 0
            ? AttendanceStatus.absent
            : roll == 1
                ? AttendanceStatus.lateArrival
                : AttendanceStatus.present;
        final String key = DateKey.of(date);
        final AttendanceRecord record = AttendanceRecord(
          id: AttendanceRecord.idFor(key, s.uid),
          studentId: s.uid,
          studentName: s.displayName,
          sectionId: s.sectionId,
          date: key,
          status: status,
          teacherId: sara.uid,
          demo: true,
        );
        attendance.set(
          _db.collection(FirebaseCollections.attendance).doc(record.id),
          AttendanceModel.toMap(record),
        );
      }
      written++;
    }
    await attendance.commit();

    // ── A conversation ─────────────────────────────────────────────────────
    step('Messages', 0.94);
    final String threadId = '${sara.uid}_${mona.uid}_${students[0].uid}';
    final DocumentReference<Map<String, dynamic>> thread =
        _db.collection(FirebaseCollections.conversations).doc(threadId);
    final List<(AppUser, String, bool)> lines = <(AppUser, String, bool)>[
      (mona, 'Hello Ms. Sara, how is Youssef doing with fractions?', false),
      (sara, 'Hello! He is doing well — 8 out of 10 on the unit exam.', true),
      (mona, 'Great, thank you. Is there anything he should revise?', false),
    ];
    final WriteBatch chat = _db.batch();
    chat.set(thread, <String, dynamic>{
      FirebaseCollections.participantIdsField: <String>[sara.uid, mona.uid],
      FirebaseCollections.teacherIdField: sara.uid,
      'teacher_name': sara.displayName,
      'parent_id': mona.uid,
      'parent_name': mona.displayName,
      FirebaseCollections.studentIdField: students[0].uid,
      'student_name': students[0].displayName,
      'last_message': lines.last.$2,
      'last_sender_id': lines.last.$1.uid,
      FirebaseCollections.lastAtField: FieldValue.serverTimestamp(),
      FirebaseCollections.demoField: true,
    });
    for (int i = 0; i < lines.length; i++) {
      final (AppUser who, String text, bool aboutExam) = lines[i];
      chat.set(thread.collection(FirebaseCollections.messages).doc('demo_$i'), <String, dynamic>{
        'sender_id': who.uid,
        'sender_name': who.displayName,
        'text': text,
        FirebaseCollections.contentIdField: aboutExam ? exam.id : '',
        'content_title': aboutExam ? exam.title : '',
        FirebaseCollections.createdAtField:
            Timestamp.fromDate(now.subtract(Duration(minutes: 30 - i * 10))),
      });
    }
    await chat.commit();

    step('Done', 1);
  }

  /// Creates (or reuses) the Auth account, then writes the profile.
  Future<AppUser> _account({
    required String key,
    required String name,
    required UserRole role,
    String subject = '',
    String sectionId = '',
    List<String> sectionIds = const <String>[],
    List<String> childrenIds = const <String>[],
    Set<TeacherPermission> permissions = const <TeacherPermission>{},
  }) async {
    final String email = _email(key);
    final String uid = await AppFirebase.createOrFindAccount(
      email: email,
      password: AppConstants.demoPassword,
    );
    final AppUser user = AppUser(
      uid: uid,
      email: email,
      fullName: name,
      phone: '0100000000${key.length}',
      role: role,
      subject: subject,
      sectionId: sectionId,
      sectionIds: sectionIds,
      childrenIds: childrenIds,
      permissions: permissions,
      demo: true,
    );
    await _db
        .collection(FirebaseCollections.users)
        .doc(uid)
        .set(UserModel.toMap(user, isCreate: true));
    return user;
  }

  /// Deletes every document marked `demo: true`. Auth accounts stay (only
  /// the Admin SDK can delete another user); seeding again reuses them.
  Future<int> clear({SeedProgress? onProgress}) async {
    int deleted = 0;

    // Messages first — deleting a thread does not delete its sub-collection.
    onProgress?.call('Messages', 0.1);
    final QuerySnapshot<Map<String, dynamic>> threads = await _db
        .collection(FirebaseCollections.conversations)
        .where(FirebaseCollections.demoField, isEqualTo: true)
        .get();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> t in threads.docs) {
      final QuerySnapshot<Map<String, dynamic>> msgs =
          await t.reference.collection(FirebaseCollections.messages).get();
      deleted += await _deleteAll(msgs.docs);
    }

    const List<String> collections = <String>[
      FirebaseCollections.conversations,
      FirebaseCollections.attendance,
      FirebaseCollections.submissions,
      FirebaseCollections.content,
      FirebaseCollections.users,
      FirebaseCollections.sections,
    ];
    for (int i = 0; i < collections.length; i++) {
      onProgress?.call(collections[i], 0.2 + 0.8 * i / collections.length);
      final QuerySnapshot<Map<String, dynamic>> snap = await _db
          .collection(collections[i])
          .where(FirebaseCollections.demoField, isEqualTo: true)
          .get();
      deleted += await _deleteAll(snap.docs);
    }
    onProgress?.call('Done', 1);
    return deleted;
  }

  Future<int> _deleteAll(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    for (int i = 0; i < docs.length; i += 400) {
      final WriteBatch batch = _db.batch();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> d
          in docs.skip(i).take(400)) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
    return docs.length;
  }
}
