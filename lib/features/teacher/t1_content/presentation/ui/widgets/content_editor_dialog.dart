/// Module: teacher / t1_content
///
///*************************** FILE INFO ****************************///
/// File Name: content_editor_dialog.dart
/// Purpose: Declares `ContentEditorDialog` — create or edit a video, PDF,
///          image, exam or quiz, and assign it to sections or students.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:dartz/dartz.dart' hide State;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:manger_plus/core/constants/app_constants.dart';
import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/custom/2-custom_textfield.dart';
import 'package:manger_plus/core/network/app_failure.dart';
import 'package:manger_plus/core/network/app_firebase.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/data/repository/academy_repository.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/base_repository/academy_base_repository.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/section.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/content_type.dart';
import 'package:manger_plus/features/console/c1_shell/presentation/ui/widgets/choice_widgets.dart';
import 'package:manger_plus/features/console/c1_shell/presentation/ui/widgets/console_page.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/teacher/t1_content/presentation/ui/widgets/question_editor.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

enum _FileSource { upload, link }

Future<bool?> showContentEditor({
  required BuildContext context,
  required AppUser author,
  required ContentType type,
  required List<Section> sections,
  required List<AppUser> students,
  LearningContent? existing,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ContentEditorDialog(
      author: author,
      type: type,
      sections: sections,
      students: students,
      existing: existing,
    ),
  );
}

class ContentEditorDialog extends StatefulWidget {
  const ContentEditorDialog({
    super.key,
    required this.author,
    required this.type,
    required this.sections,
    required this.students,
    this.existing,
  });

  /// Who is saving. A NEW item belongs to them; an edited one keeps its
  /// original teacher (the admin may edit anybody's).
  final AppUser author;
  final ContentType type;

  /// The sections this person may assign to.
  final List<Section> sections;

  /// The students in those sections, for assigning to single students.
  final List<AppUser> students;
  final LearningContent? existing;

  @override
  State<ContentEditorDialog> createState() => _ContentEditorDialogState();
}

class _ContentEditorDialogState extends State<ContentEditorDialog> {
  final ContentRepository _repository = ContentRepository();

  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _description =
      TextEditingController(text: widget.existing?.description ?? '');
  late final TextEditingController _subject = TextEditingController(
      text: widget.existing?.subject ?? widget.author.subject);
  late final TextEditingController _link = TextEditingController(
      text: widget.existing?.storagePath.isEmpty ?? false ? widget.existing!.fileUrl : '');
  late final TextEditingController _duration = TextEditingController(
      text: '${widget.existing?.durationMinutes ?? (widget.type == ContentType.quiz ? 10 : 30)}');

  late _FileSource _source = widget.existing != null &&
          widget.existing!.fileUrl.isNotEmpty &&
          widget.existing!.storagePath.isEmpty
      ? _FileSource.link
      : _FileSource.upload;

  PickedUpload? _picked;
  late List<Question> _questions = widget.existing?.questions ?? const <Question>[];
  late Set<String> _sectionIds = widget.existing?.sectionIds.toSet() ?? <String>{};
  late Set<String> _studentIds = widget.existing?.studentIds.toSet() ?? <String>{};
  late DateTime? _dueAt = widget.existing?.dueAt;
  late bool _published = widget.existing?.published ?? true;

  bool _saving = false;
  bool _submitted = false;
  double? _uploadProgress;
  String? _error;

  bool get _isCreate => widget.existing == null;
  ContentType get _type => widget.type;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _subject.dispose();
    _link.dispose();
    _duration.dispose();
    super.dispose();
  }

  // ── File ─────────────────────────────────────────────────────────────────

  Future<void> _pickFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _type.extensions,
      // The web has no file path; it needs the bytes in memory instead.
      withData: kIsWeb,
    );
    if (result == null || result.files.isEmpty) return;
    final PlatformFile f = result.files.first;

    if (f.size > AppConstants.maxUploadMb * 1024 * 1024) {
      setState(() => _error = S.of(context).fileTooLarge('${AppConstants.maxUploadMb}'));
      return;
    }
    setState(() {
      _error = null;
      _picked = PickedUpload(
        name: f.name,
        size: f.size,
        path: kIsWeb ? null : f.path,
        bytes: kIsWeb ? f.bytes : null,
      );
    });
  }

  String _sizeLabel(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ── Validation ───────────────────────────────────────────────────────────

  String? get _titleError =>
      _submitted && _title.text.trim().isEmpty ? S.of(context).enterTitle : null;

  String? get _fileError {
    if (!_submitted || !_type.hasFile) return null;
    if (_source == _FileSource.link) {
      final Uri? uri = Uri.tryParse(_link.text.trim());
      return uri == null || !uri.hasScheme || !uri.scheme.startsWith('http')
          ? S.of(context).enterValidLink
          : null;
    }
    final bool hasExisting =
        widget.existing != null && widget.existing!.storagePath.isNotEmpty;
    return _picked == null && !hasExisting ? S.of(context).chooseFile : null;
  }

  bool get _questionsValid =>
      !_type.isAssessment ||
      (_questions.isNotEmpty && _questions.every((Question q) => q.isValid));

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    setState(() {
      _submitted = true;
      _error = null;
    });
    if (_titleError != null || _fileError != null) return;
    if (!_questionsValid) {
      setState(() => _error = S.of(context).questionsIncomplete);
      return;
    }

    setState(() => _saving = true);
    final S s = S.of(context);

    String fileUrl = widget.existing?.fileUrl ?? '';
    String storagePath = widget.existing?.storagePath ?? '';
    String fileName = widget.existing?.fileName ?? '';
    final String oldStoragePath = storagePath;

    if (_type.hasFile && _source == _FileSource.link) {
      fileUrl = _link.text.trim();
      storagePath = '';
      fileName = Uri.parse(fileUrl).pathSegments.isEmpty
          ? fileUrl
          : Uri.parse(fileUrl).pathSegments.last;
    }

    if (_type.hasFile && _source == _FileSource.upload && _picked != null) {
      setState(() => _uploadProgress = 0);
      final Either<AppFailure, UploadedFile> upload = await _repository.upload(
        teacherId: widget.existing?.teacherId ?? widget.author.uid,
        file: _picked!,
        onProgress: (double p) {
          if (mounted) setState(() => _uploadProgress = p);
        },
      );
      if (!mounted) return;
      final UploadedFile? uploaded = upload.fold((AppFailure f) {
        setState(() {
          _saving = false;
          _uploadProgress = null;
          _error = f.message(context);
        });
        return null;
      }, (UploadedFile u) => u);
      if (uploaded == null) return;
      fileUrl = uploaded.url;
      storagePath = uploaded.storagePath;
      fileName = uploaded.fileName;
    }

    final LearningContent base = widget.existing ??
        LearningContent(
          id: '',
          type: _type,
          title: '',
          teacherId: widget.author.uid,
          teacherName: widget.author.displayName,
        );

    final LearningContent content = base.copyWith(
      title: _title.text,
      description: _description.text,
      subject: _subject.text,
      fileUrl: _type.hasFile ? fileUrl : '',
      storagePath: _type.hasFile ? storagePath : '',
      fileName: _type.hasFile ? fileName : '',
      questions: _type.isAssessment ? _questions : const <Question>[],
      durationMinutes: _type.isAssessment ? (int.tryParse(_duration.text.trim()) ?? 0) : 0,
      sectionIds: _sectionIds.toList(),
      studentIds: _studentIds.toList(),
      dueAt: _dueAt,
      clearDueAt: _dueAt == null,
      published: _published,
    );

    final Either<AppFailure, String> result = await _repository.save(content);
    if (!mounted) return;
    result.fold(
      (AppFailure f) => setState(() {
        _saving = false;
        _uploadProgress = null;
        _error = f.message(context);
      }),
      (_) {
        // The file was replaced: the old one is now nobody's.
        if (oldStoragePath.isNotEmpty && oldStoragePath != storagePath) {
          AppFirebase.storage.ref(oldStoragePath).delete().catchError((Object _) {});
        }
        showToast(context, s.saved);
        Navigator.of(context).pop(true);
      },
    );
  }

  Future<void> _pickDueDate() async {
    final DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _dueAt ?? now.add(const Duration(days: 7)),
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    // End of that day, so "due Sunday" means all of Sunday.
    setState(() => _dueAt = DateTime(date.year, date.month, date.day, 23, 59));
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<AppUser> assignable = widget.students;

    return ConsoleDialog(
      title: _isCreate ? s.newItem(_type.label(context)) : s.editItem(_type.label(context)),
      subtitle: _type.isAssessment ? s.assessmentHint : s.fileHint,
      width: _type.isAssessment ? 780 : 640,
      actions: <Widget>[
        AppButton(
          label: s.cancel,
          kind: AppButtonKind.outlined,
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: s.save,
          icon: Icons.check_rounded,
          loading: _saving,
          onPressed: _save,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (_error != null) ...<Widget>[
            InfoBanner.error(_error!),
            const SizedBox(height: 12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TypeBadge(icon: _type.icon, color: _type.color, size: 52, solid: true),
              const SizedBox(width: 14),
              Expanded(
                child: CustomTextField(
                  controller: _title,
                  label: s.title,
                  required: true,
                  errorText: _titleError,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 200,
                child: CustomTextField(controller: _subject, label: s.subject),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _description,
            label: s.description,
            hint: s.descriptionHint,
            maxLines: 3,
            minLines: 2,
          ),

          // ── File ────────────────────────────────────────────────────────
          if (_type.hasFile) ...<Widget>[
            FormLabel(s.file),
            ChoiceWrap<_FileSource>(
              multi: false,
              items: _FileSource.values,
              selected: <_FileSource>{_source},
              labelOf: (_FileSource x) => x == _FileSource.upload ? s.uploadFile : s.pasteLink,
              onChanged: (Set<_FileSource> v) {
                if (v.isNotEmpty) setState(() => _source = v.first);
              },
            ),
            const SizedBox(height: 10),
            if (_source == _FileSource.upload)
              _FileDropBox(
                type: _type,
                fileName: _picked?.name ??
                    (widget.existing?.storagePath.isNotEmpty ?? false
                        ? widget.existing!.fileName
                        : null),
                sizeLabel: _picked == null ? null : _sizeLabel(_picked!.size),
                progress: _uploadProgress,
                error: _fileError,
                onPick: _saving ? null : _pickFile,
              )
            else
              CustomTextField(
                controller: _link,
                label: s.link,
                hint: 'https://',
                keyboardType: TextInputType.url,
                errorText: _fileError,
              ),
          ],

          // ── Questions ───────────────────────────────────────────────────
          if (_type.isAssessment) ...<Widget>[
            FormLabel(s.timeLimit),
            SizedBox(
              width: 220,
              child: CustomTextField(
                controller: _duration,
                label: s.minutes,
                helperText: s.zeroUntimed,
                onlyDigits: true,
                keyboardType: TextInputType.number,
              ),
            ),
            FormLabel(s.questionsTotal(
              '${_questions.length}',
              _questions.fold<double>(0, (double a, Question q) => a + q.points).toStringAsFixed(0),
            )),
            QuestionListEditor(
              initial: widget.existing?.questions ?? const <Question>[],
              showErrors: _submitted,
              onChanged: (List<Question> q) => setState(() => _questions = q),
            ),
          ],

          // ── Assignment ──────────────────────────────────────────────────
          FormLabel(s.assignToSections),
          ChoiceWrap<String>(
            items: widget.sections.map((Section x) => x.id).toList(),
            selected: _sectionIds,
            labelOf: (String id) => widget.sections.firstWhere((Section x) => x.id == id).title,
            emptyText: s.noSectionsAssigned,
            onChanged: (Set<String> v) => setState(() => _sectionIds = v),
          ),
          FormLabel(s.assignToStudents),
          PeoplePicker(
            people: assignable,
            selected: _studentIds,
            maxHeight: 180,
            subtitleOf: (AppUser u) {
              final Iterable<Section> m =
                  widget.sections.where((Section x) => x.id == u.sectionId);
              return m.isEmpty ? u.email : m.first.title;
            },
            onChanged: (Set<String> v) => setState(() => _studentIds = v),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: Surface(
                  color: AppColors.background,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  onTap: _pickDueDate,
                  child: Row(
                    children: <Widget>[
                      AppIcon(Icons.event_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _dueAt == null ? s.noDueDate : s.dueOn(AppDates.day(context, _dueAt)),
                          style: StyleText.fontSize14Weight500,
                        ),
                      ),
                      if (_dueAt != null)
                        IconButton(
                          onPressed: () => setState(() => _dueAt = null),
                          icon: AppIcon(Icons.close_rounded, size: 18, color: AppColors.secondaryText),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SwitchRow(
                  icon: Icons.visibility_outlined,
                  title: s.published,
                  subtitle: s.publishedHint,
                  value: _published,
                  onChanged: (bool v) => setState(() => _published = v),
                ),
              ),
            ],
          ),
          if (_sectionIds.isEmpty && _studentIds.isEmpty) ...<Widget>[
            const SizedBox(height: 10),
            InfoBanner(message: s.notAssignedWarning, icon: Icons.info_outline_rounded),
          ],
        ],
      ),
    );
  }
}

/// The "choose a file" box, with the chosen file and upload progress.
class _FileDropBox extends StatelessWidget {
  const _FileDropBox({
    required this.type,
    required this.fileName,
    required this.sizeLabel,
    required this.progress,
    required this.error,
    required this.onPick,
  });

  final ContentType type;
  final String? fileName;
  final String? sizeLabel;
  final double? progress;
  final String? error;
  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Color border = error != null ? AppColors.red : type.color.withOpacity(0.5);

    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: type.color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                AppIcon(
                  fileName == null ? Icons.cloud_upload_outlined : type.icon,
                  color: type.color,
                  size: 30,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        fileName ?? s.chooseFile,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize14Weight600,
                      ),
                      Text(
                        sizeLabel ?? s.allowedTypes(type.extensions.join(', ')),
                        style: StyleText.fontSize12Weight400
                            .copyWith(color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
                Text(
                  fileName == null ? s.browse : s.replace,
                  style: StyleText.fontSize13Weight600.copyWith(color: type.color),
                ),
              ],
            ),
            if (progress != null) ...<Widget>[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: progress,
                  backgroundColor: type.color.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(type.color),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.uploadingPercent('${((progress ?? 0) * 100).round()}'),
                style: StyleText.fontSize12Weight500,
              ),
            ],
            if (error != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(error!, style: StyleText.fontSize12Weight500.copyWith(color: AppColors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
