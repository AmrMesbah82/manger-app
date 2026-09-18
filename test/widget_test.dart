// Pure-logic tests — no Firebase, no widgets. Run with `flutter test`.

import 'package:flutter_test/flutter_test.dart';

import 'package:manger_plus/core/helper/main_helper/platform_helper.dart';
import 'package:manger_plus/features/academy/ac1_core/data/utils/academy_utils.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/content_type.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/teacher_permission.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/user_role.dart';

void main() {
  const LearningContent exam = LearningContent(
    id: 'e1',
    type: ContentType.exam,
    title: 'Unit 1',
    teacherId: 't1',
    questions: <Question>[
      Question(text: 'a', options: <String>['1', '2'], correctIndex: 0, points: 2),
      Question(text: 'b', options: <String>['1', '2'], correctIndex: 1, points: 3),
    ],
  );

  test('ExamGrader adds the points of correct answers only', () {
    expect(ExamGrader.score(exam, <int>[0, 1]), 5);
    expect(ExamGrader.score(exam, <int>[0, 0]), 2);
    expect(ExamGrader.score(exam, <int>[-1, -1]), 0);
    expect(exam.totalPoints, 5);
  });

  test('DateKey is zero-padded yyyy-MM-dd', () {
    expect(DateKey.of(DateTime(2026, 3, 7)), '2026-03-07');
  });

  test('roles map to devices', () {
    expect(UserRole.admin.allowedOn, DeviceKind.desktop);
    expect(UserRole.teacher.allowedOn, DeviceKind.desktop);
    expect(UserRole.student.allowedOn, DeviceKind.mobile);
    expect(UserRole.parent.allowedOn, DeviceKind.mobile);
  });

  test('a teacher can only do what the admin switched on', () {
    const AppUser teacher = AppUser(
      uid: 't',
      email: 't@x.com',
      role: UserRole.teacher,
      permissions: <TeacherPermission>{TeacherPermission.video},
    );
    expect(teacher.can(TeacherPermission.video), isTrue);
    expect(teacher.can(TeacherPermission.exam), isFalse);
    const AppUser admin = AppUser(uid: 'a', email: 'a@x.com', role: UserRole.admin);
    expect(admin.can(TeacherPermission.exam), isTrue);
  });

  test('content is visible by section or by name', () {
    const LearningContent c = LearningContent(
      id: 'c',
      type: ContentType.pdf,
      title: 'x',
      teacherId: 't',
      sectionIds: <String>['s1'],
      studentIds: <String>['u9'],
    );
    const AppUser inSection =
        AppUser(uid: 'u1', email: 'a', role: UserRole.student, sectionId: 's1');
    const AppUser byName = AppUser(uid: 'u9', email: 'b', role: UserRole.student);
    const AppUser other =
        AppUser(uid: 'u2', email: 'c', role: UserRole.student, sectionId: 's2');
    expect(c.isAssignedTo(inSection), isTrue);
    expect(c.isAssignedTo(byName), isTrue);
    expect(c.isAssignedTo(other), isFalse);
  });
}
