/// Module: teacher / t1_content
///
///*************************** FILE INFO ****************************///
/// File Name: question_editor.dart
/// Purpose: Declares `QuestionListEditor` — build an exam or quiz one
///          multiple-choice question at a time.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/material.dart';

import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

/// Holds its own text controllers (one per question and per option) and
/// reports the whole list upward on every change.
class QuestionListEditor extends StatefulWidget {
  const QuestionListEditor({
    super.key,
    required this.initial,
    required this.onChanged,
    this.showErrors = false,
  });

  final List<Question> initial;
  final ValueChanged<List<Question>> onChanged;

  /// Outline incomplete questions in red (after the first save attempt).
  final bool showErrors;

  @override
  State<QuestionListEditor> createState() => _QuestionListEditorState();
}

class _Draft {
  _Draft(Question q)
      : text = TextEditingController(text: q.text),
        options = q.options.map((String o) => TextEditingController(text: o)).toList(),
        correct = q.correctIndex,
        points = TextEditingController(text: _fmt(q.points));

  final TextEditingController text;
  final List<TextEditingController> options;
  int correct;
  final TextEditingController points;

  static String _fmt(double v) => v == v.roundToDouble() ? '${v.toInt()}' : '$v';

  Question toQuestion() => Question(
        text: text.text,
        options: options.map((TextEditingController c) => c.text).toList(),
        correctIndex: correct,
        points: double.tryParse(points.text.trim()) ?? 1,
      );

  void dispose() {
    text.dispose();
    points.dispose();
    for (final TextEditingController c in options) {
      c.dispose();
    }
  }
}

class _QuestionListEditorState extends State<QuestionListEditor> {
  late final List<_Draft> _drafts = widget.initial.isEmpty
      ? <_Draft>[_Draft(Question.blank)]
      : widget.initial.map((Question q) => _Draft(q)).toList();

  @override
  void initState() {
    super.initState();
    // Report the starting list so the parent has something to save even if
    // the teacher changes nothing.
    WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
  }

  @override
  void dispose() {
    for (final _Draft d in _drafts) {
      d.dispose();
    }
    super.dispose();
  }

  void _emit() {
    if (mounted) widget.onChanged(_drafts.map((_Draft d) => d.toQuestion()).toList());
  }

  /// A removed field's TextField is still in this frame's tree; disposing its
  /// controller now would be "used after dispose". Next frame it is gone.
  void _disposeLater(VoidCallback dispose) =>
      WidgetsBinding.instance.addPostFrameCallback((_) => dispose());

  void _update(VoidCallback change) {
    setState(change);
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < _drafts.length; i++) _card(context, i),
        const SizedBox(height: 4),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppButton(
            label: s.addQuestion,
            icon: Icons.add_rounded,
            kind: AppButtonKind.subtle,
            dense: true,
            onPressed: () => _update(() => _drafts.add(_Draft(Question.blank))),
          ),
        ),
      ],
    );
  }

  Widget _card(BuildContext context, int index) {
    final S s = S.of(context);
    final _Draft d = _drafts[index];
    final bool invalid = widget.showErrors && !d.toQuestion().isValid;

    InputDecoration deco(String hint) => InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: StyleText.fontSize13Weight400.copyWith(color: AppColors.secondaryText),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        );

    return Container(
      key: ObjectKey(d),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: invalid ? AppColors.red : AppColors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary,
                child: Text('${index + 1}',
                    style: StyleText.fontSize12Weight700.copyWith(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: d.text,
                  onChanged: (_) => _emit(),
                  style: StyleText.fontSize14Weight600,
                  decoration: deco(s.questionText),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 76,
                child: TextField(
                  controller: d.points,
                  onChanged: (_) => _emit(),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: StyleText.fontSize13Weight500,
                  decoration: deco(s.points),
                ),
              ),
              IconButton(
                tooltip: s.delete,
                onPressed: _drafts.length == 1
                    ? null
                    : () => _update(() => _disposeLater(_drafts.removeAt(index).dispose)),
                icon: AppIcon(Icons.delete_outline_rounded, color: AppColors.red, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (int o = 0; o < d.options.length; o++)
            Padding(
              key: ObjectKey(d.options[o]),
              padding: const EdgeInsetsDirectional.only(start: 30, bottom: 6),
              child: Row(
                children: <Widget>[
                  // Drawn by hand rather than with Radio: Radio's groupValue
                  // API is being replaced by RadioGroup, and this is one line.
                  IconButton(
                    onPressed: () => _update(() => d.correct = o),
                    icon: AppIcon(
                      d.correct == o
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: d.correct == o
                          ? const Color(0xff10B981)
                          : AppColors.secondaryText,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: d.options[o],
                      onChanged: (_) => _emit(),
                      style: StyleText.fontSize13Weight500,
                      decoration: deco(s.optionN('${o + 1}')),
                    ),
                  ),
                  IconButton(
                    onPressed: d.options.length <= 2
                        ? null
                        : () => _update(() {
                              _disposeLater(d.options.removeAt(o).dispose);
                              if (d.correct >= d.options.length) d.correct = 0;
                            }),
                    icon: AppIcon(Icons.remove_circle_outline,
                        color: AppColors.secondaryText, size: 18),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 30),
            child: Row(
              children: <Widget>[
                if (d.options.length < 6)
                  TextButton.icon(
                    onPressed: () => _update(() => d.options.add(TextEditingController())),
                    icon: const AppIcon(Icons.add_rounded, size: 18),
                    label: Text(s.addOption),
                  ),
                const Spacer(),
                AppIcon(Icons.check_circle_rounded, size: 14, color: const Color(0xff10B981)),
                const SizedBox(width: 4),
                Text(
                  s.markCorrectHint,
                  style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
