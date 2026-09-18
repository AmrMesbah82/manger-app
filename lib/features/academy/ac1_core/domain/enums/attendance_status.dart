/// Module: academy / ac1_core
///
///*************************** FILE INFO ****************************///
/// File Name: attendance_status.dart
/// Purpose: Declares `AttendanceStatus`.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/material.dart';

import 'package:manger_plus/generated/l10n.dart';

enum AttendanceStatus {
  present('present', Color(0xff10B981), Icons.check_circle_rounded),
  absent('absent', Color(0xffEF4444), Icons.cancel_rounded),
  lateArrival('late', Color(0xffF59E0B), Icons.schedule_rounded),
  excused('excused', Color(0xff3B82F6), Icons.verified_user_rounded);

  const AttendanceStatus(this.key, this.color, this.icon);

  final String key;
  final Color color;
  final IconData icon;

  static AttendanceStatus fromKey(String? key) {
    for (final AttendanceStatus s in AttendanceStatus.values) {
      if (s.key == key) return s;
    }
    return AttendanceStatus.present;
  }

  /// Counts as "was in the room" for the attendance rate.
  bool get attended =>
      this == AttendanceStatus.present || this == AttendanceStatus.lateArrival;

  String label(BuildContext context) {
    final S s = S.of(context);
    switch (this) {
      case AttendanceStatus.present:
        return s.present;
      case AttendanceStatus.absent:
        return s.absent;
      case AttendanceStatus.lateArrival:
        return s.lateStatus;
      case AttendanceStatus.excused:
        return s.excused;
    }
  }
}
