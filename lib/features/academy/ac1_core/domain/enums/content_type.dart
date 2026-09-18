/// Module: academy / ac1_core
///
///*************************** FILE INFO ****************************///
/// File Name: content_type.dart
/// Purpose: Declares `ContentType` — the five kinds of learning material.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:manger_plus/features/onboarding/o2_authentication/domain/enums/teacher_permission.dart';
import 'package:manger_plus/generated/l10n.dart';

enum ContentType {
  video('video', Icons.play_circle_fill_rounded, Color(0xffFF6B6B)),
  pdf('pdf', Icons.picture_as_pdf_rounded, Color(0xffF59E0B)),
  image('image', Icons.photo_rounded, Color(0xff10B981)),
  exam('exam', Icons.assignment_rounded, Color(0xff6C63FF)),
  quiz('quiz', Icons.bolt_rounded, Color(0xff3B82F6));

  const ContentType(this.key, this.icon, this.color);

  /// Stored as `type` on the content document.
  final String key;
  final IconData icon;

  /// Each type keeps one accent colour everywhere — library chips, cards,
  /// the console table — so a student learns "red is a video" once.
  final Color color;

  static ContentType fromKey(String? key) {
    for (final ContentType type in ContentType.values) {
      if (type.key == key) return type;
    }
    return ContentType.pdf;
  }

  static const String _icons = 'assets/icons_assets/main_icons_assets/';

  /// The SVG drawn for this type wherever a content type is shown on its own
  /// (no tinted square behind it).
  String get svgAsset {
    switch (this) {
      case ContentType.video:
        return '${_icons}knowledgeVideo.svg';
      case ContentType.pdf:
        return '${_icons}assets_pdf.svg';
      case ContentType.image:
        return '${_icons}image_photo_rounded.svg';
      case ContentType.exam:
        return '${_icons}doc_file_blue.svg';
      case ContentType.quiz:
        return '${_icons}approval_badge_check.svg';
    }
  }

  /// False for the SVGs that already carry their own colours (the PDF and
  /// DOC files); the single-colour ones are tinted with [color].
  bool get tintSvg => this != ContentType.pdf && this != ContentType.exam;

  /// Exams and quizzes have questions and produce a submission. The other
  /// three are a file to open.
  bool get isAssessment => this == ContentType.exam || this == ContentType.quiz;
  bool get hasFile => !isAssessment;

  /// The switch on the teacher's account that allows publishing this type.
  TeacherPermission get permission {
    switch (this) {
      case ContentType.video:
        return TeacherPermission.video;
      case ContentType.pdf:
        return TeacherPermission.pdf;
      case ContentType.image:
        return TeacherPermission.image;
      case ContentType.exam:
        return TeacherPermission.exam;
      case ContentType.quiz:
        return TeacherPermission.quiz;
    }
  }

  /// File extensions the picker offers for this type.
  List<String> get extensions {
    switch (this) {
      case ContentType.video:
        return const <String>['mp4', 'mov', 'm4v', 'webm'];
      case ContentType.pdf:
        return const <String>['pdf'];
      case ContentType.image:
        return const <String>['jpg', 'jpeg', 'png', 'webp', 'gif'];
      case ContentType.exam:
      case ContentType.quiz:
        return const <String>[];
    }
  }

  String label(BuildContext context) {
    final S s = S.of(context);
    switch (this) {
      case ContentType.video:
        return s.typeVideo;
      case ContentType.pdf:
        return s.typePdf;
      case ContentType.image:
        return s.typeImage;
      case ContentType.exam:
        return s.typeExam;
      case ContentType.quiz:
        return s.typeQuiz;
    }
  }

  /// Plural, for the library tabs and home shortcuts.
  String plural(BuildContext context) {
    final S s = S.of(context);
    switch (this) {
      case ContentType.video:
        return s.typeVideos;
      case ContentType.pdf:
        return s.typePdfs;
      case ContentType.image:
        return s.typeImages;
      case ContentType.exam:
        return s.typeExams;
      case ContentType.quiz:
        return s.typeQuizzes;
    }
  }
}


/// A content type's SVG icon, with no background. [size] is the box it
/// occupies, so it drops in where a `TypeBadge` of the same size was.
class ContentTypeIcon extends StatelessWidget {
  const ContentTypeIcon({super.key, required this.type, this.size = 36});

  final ContentType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: SvgPicture.asset(
          type.svgAsset,
          width: size * 0.8,
          height: size * 0.8,
          colorFilter: type.tintSvg
              ? ColorFilter.mode(type.color, BlendMode.srcIn)
              : null,
        ),
      ),
    );
  }
}
