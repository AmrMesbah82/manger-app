/// Module: console / c4_dashboard
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_export.dart
/// Purpose: Declares `exportDashboard` — the toolbar's CSV export.
/// Author: Manger Plus team
/// Created: 18/9/2026
///
/// Exports EXACTLY what the table is showing: the same tab, the same section
/// chip, the same period, the same search text. A CSV that quietly held rows
/// the screen was hiding is the bug this shape avoids.
///
/// Opened through [CustomDialogManager.showExport] for the file name, then
/// `file_picker`'s save panel for the destination — so the user names the
/// file in the app's own dialog and places it in the OS one, which is where
/// each of those two questions belongs.
///
/// A UTF-8 BOM is written ahead of the rows. Without it Excel on Windows
/// reads the file as the legacy code page and every Arabic name comes out as
/// mojibake; the BOM costs three bytes and every other reader ignores it.
library;

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:manger_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/attendance_record.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/submission.dart';
import 'package:manger_plus/features/console/c1_shell/presentation/ui/widgets/console_page.dart';
import 'package:manger_plus/features/console/c4_dashboard/presentation/controller/dashboard_state.dart';
import 'package:manger_plus/generated/l10n.dart';

Future<void> exportDashboard({
  required BuildContext context,
  required DashboardState state,
}) async {
  final S s = S.of(context);
  final bool results = state.tab == DashboardTab.results;

  // Built BEFORE the dialog opens, off the state the table is showing right
  // now. Building it inside the dialog would read a state that the live
  // Firestore streams may have moved on from while the user typed a name.
  final String csv = results
      ? _resultsCsv(context, state.resultRows, state)
      : _attendanceCsv(context, state.attendanceRows, state);

  String? writtenTo;

  final String? name = await CustomDialogManager.showExport(
    context: context,
    title: s.exportTitle,
    fieldLabel: s.exportFileName,
    hint: s.enterFileName,
    exportLabel: s.exportCsv,
    discardLabel: s.discard,
    defaultFileName: _defaultName(results ? 'results' : 'attendance'),
    onExport: (String fileName) async {
      try {
        final String? path = await FilePicker.platform.saveFile(
          dialogTitle: s.exportTitle,
          fileName: '$fileName.csv',
          type: FileType.custom,
          allowedExtensions: <String>['csv'],
        );
        // The user backed out of the system save panel. Not a failure, so it
        // gets no message — the export dialog simply stays open.
        if (path == null) return false;

        final File file =
            File(path.toLowerCase().endsWith('.csv') ? path : '$path.csv');
        // The BOM is three bytes that stop Excel on Windows reading the file
        // as a legacy code page and turning every Arabic name into mojibake.
        await file.writeAsString('\uFEFF$csv', encoding: utf8);
        writtenTo = file.path;
        return true;
      } catch (error) {
        if (context.mounted) {
          await CustomDialogManager.showError(
            context: context,
            title: s.exportFailedTitle,
            subtitle: AppFailure.from(error).message(context),
            closeLabel: s.close,
          );
        }
        return false;
      }
    },
  );

  if (name == null || !context.mounted) return;
  showToast(context, s.exportSaved(writtenTo ?? name));
}

// ── Builders ────────────────────────────────────────────────────────────────

String _resultsCsv(
  BuildContext context,
  List<Submission> rows,
  DashboardState state,
) {
  final S s = S.of(context);
  return _rowsToCsv(<List<String>>[
    <String>[
      s.student,
      s.section,
      s.assessment,
      s.score,
      s.dateLabel,
    ],
    for (final Submission x in rows)
      <String>[
        x.studentName,
        state.sectionTitle(x.sectionId),
        x.contentTitle,
        '${x.percent.round()}%',
        x.submittedAt == null ? '' : _isoDay(x.submittedAt!),
      ],
  ]);
}

String _attendanceCsv(
  BuildContext context,
  List<AttendanceRecord> rows,
  DashboardState state,
) {
  final S s = S.of(context);
  return _rowsToCsv(<List<String>>[
    <String>[s.student, s.section, s.dateLabel, s.status],
    for (final AttendanceRecord x in rows)
      <String>[
        x.studentName,
        state.sectionTitle(x.sectionId),
        x.date,
        x.status.label(context),
      ],
  ]);
}

/// RFC 4180: a field containing a quote, a comma or a newline is wrapped in
/// quotes, and an inner quote is doubled. Arabic names carry none of those,
/// but an assessment title like `Unit 2 — "Fractions", part 1` does.
String _rowsToCsv(List<List<String>> rows) {
  String cell(String value) {
    final bool needsQuotes =
        value.contains(',') || value.contains('"') || value.contains('\n');
    if (!needsQuotes) return value;
    return '"${value.replaceAll('"', '""')}"';
  }

  return rows.map((List<String> r) => r.map(cell).join(',')).join('\r\n');
}

String _isoDay(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

String _defaultName(String prefix) => '${prefix}_${_isoDay(DateTime.now())}';
