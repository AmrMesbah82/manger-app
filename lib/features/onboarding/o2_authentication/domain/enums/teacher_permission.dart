/// Module: onboarding / o2_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: teacher_permission.dart
/// Purpose: Declares `TeacherPermission` — the switches the admin flips on a
///          teacher's account.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/material.dart';

import 'package:manger_plus/generated/l10n.dart';

/// Each value is one switch on the admin's "Edit teacher" dialog, stored as
/// `permissions.<key>: true|false` on the teacher's `users` document.
///
/// The first five gate which kinds of content the teacher may publish; the
/// last three gate whole console sections. `firestore.rules` checks the same
/// map, so turning a switch off stops the write on the server too — not just
/// the button.
enum TeacherPermission {
  video('video', Icons.play_circle_outline_rounded),
  pdf('pdf', Icons.picture_as_pdf_outlined),
  image('image', Icons.image_outlined),
  exam('exam', Icons.assignment_outlined),
  quiz('quiz', Icons.quiz_outlined),
  attendance('attendance', Icons.fact_check_outlined),
  grades('grades', Icons.grade_outlined),
  messages('messages', Icons.chat_bubble_outline_rounded);

  const TeacherPermission(this.key, this.icon);

  final String key;
  final IconData icon;

  static TeacherPermission? fromKey(String key) {
    for (final TeacherPermission p in TeacherPermission.values) {
      if (p.key == key) return p;
    }
    return null;
  }

  /// What a brand-new teacher gets. Everything on: the admin switches off
  /// what a particular teacher should not do, which is the rarer case.
  static const Set<TeacherPermission> defaults = <TeacherPermission>{
    ...TeacherPermission.values,
  };

  String label(BuildContext context) {
    final S s = S.of(context);
    switch (this) {
      case TeacherPermission.video:
        return s.typeVideo;
      case TeacherPermission.pdf:
        return s.typePdf;
      case TeacherPermission.image:
        return s.typeImage;
      case TeacherPermission.exam:
        return s.typeExam;
      case TeacherPermission.quiz:
        return s.typeQuiz;
      case TeacherPermission.attendance:
        return s.attendance;
      case TeacherPermission.grades:
        return s.grades;
      case TeacherPermission.messages:
        return s.messages;
    }
  }

  String description(BuildContext context) {
    final S s = S.of(context);
    switch (this) {
      case TeacherPermission.video:
      case TeacherPermission.pdf:
      case TeacherPermission.image:
      case TeacherPermission.exam:
      case TeacherPermission.quiz:
        return s.permissionPublishDesc(label(context));
      case TeacherPermission.attendance:
        return s.permissionAttendanceDesc;
      case TeacherPermission.grades:
        return s.permissionGradesDesc;
      case TeacherPermission.messages:
        return s.permissionMessagesDesc;
    }
  }
}
