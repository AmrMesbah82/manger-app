/// Module: student / s3_viewer
///
///*************************** FILE INFO ****************************///
/// File Name: content_viewers.dart
/// Purpose: Declares `ContentOpener` and the three file viewers —
///          `VideoViewerScreen`, `PdfViewerScreen`, `ImageViewerScreen`.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_padding.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/learning_content.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/entities/submission.dart';
import 'package:manger_plus/features/academy/ac1_core/domain/enums/content_type.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/features/student/s4_assessment/presentation/ui/pages/assessment_screens.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

/// Opens any piece of content in the right screen.
abstract final class ContentOpener {
  const ContentOpener._();

  /// [learner] is the student taking an exam. [readOnly] is the parent's
  /// view: lessons open normally, an exam shows its result (or "not taken
  /// yet") and can never be started.
  static void open(
    BuildContext context, {
    required LearningContent content,
    required AppUser learner,
    Submission? submission,
    bool readOnly = false,
  }) {
    final Widget screen;
    switch (content.type) {
      case ContentType.video:
        screen = VideoViewerScreen(content: content);
      case ContentType.pdf:
        screen = PdfViewerScreen(content: content);
      case ContentType.image:
        screen = ImageViewerScreen(content: content);
      case ContentType.exam:
      case ContentType.quiz:
        screen = submission != null
            ? AssessmentResultScreen(content: content, submission: submission)
            : readOnly
                ? AssessmentIntroScreen(content: content, learner: learner, readOnly: true)
                : AssessmentIntroScreen(content: content, learner: learner);
    }
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}

/// Title, teacher, description and due date under a viewer.
class _Details extends StatelessWidget {
  const _Details({required this.content});

  final LearningContent content;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final LearningContent c = content;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              ContentTypeIcon(type: c.type, size: 40.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(c.title, style: StyleText.fontSize18Weight600),
                    Text(
                      <String>[
                        if (c.subject.isNotEmpty) c.subject,
                        if (c.teacherName.isNotEmpty) c.teacherName,
                      ].join(' · '),
                      style: StyleText.fontSize13Weight500.copyWith(color: c.type.color),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (c.description.isNotEmpty) ...<Widget>[
            SizedBox(height: 14.h),
            Text(c.description, style: StyleText.fontSize14Weight400),
          ],
          if (c.dueAt != null) ...<Widget>[
            SizedBox(height: 12.h),
            InfoBanner(
              message: s.dueOn(AppDates.day(context, c.dueAt)),
              icon: Icons.event_rounded,
              color: c.isOverdue ? AppColors.red : c.type.color,
            ),
          ],
        ],
      ),
    );
  }
}

List<Widget> _externalAction(BuildContext context, LearningContent c) => <Widget>[
      IconButton(
        tooltip: S.of(context).openExternally,
        onPressed: () => launchUrl(Uri.parse(c.fileUrl), mode: LaunchMode.externalApplication),
        icon: const AppIcon(Icons.open_in_new_rounded),
      ),
    ];

// ── Video ───────────────────────────────────────────────────────────────────

class VideoViewerScreen extends StatefulWidget {
  const VideoViewerScreen({super.key, required this.content});

  final LearningContent content;

  @override
  State<VideoViewerScreen> createState() => _VideoViewerScreenState();
}

class _VideoViewerScreenState extends State<VideoViewerScreen> {
  late final VideoPlayerController _controller =
      VideoPlayerController.networkUrl(Uri.parse(widget.content.fileUrl));
  bool _failed = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controller.initialize().then((_) {
      if (mounted) setState(() {});
    }).catchError((Object _) {
      if (mounted) setState(() => _failed = true);
    });
    _controller.addListener(_tick);
  }

  void _tick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_tick);
    _controller.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final String m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerValue v = _controller.value;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.content.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: _externalAction(context, widget.content),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: v.isInitialized ? v.aspectRatio : 16 / 9,
              child: _failed
                  ? Center(
                      child: Text(S.of(context).videoFailed,
                          style: StyleText.fontSize14Weight500.copyWith(color: Colors.white70)),
                    )
                  : !v.isInitialized
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : GestureDetector(
                          onTap: () => setState(() => _showControls = !_showControls),
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              VideoPlayer(_controller),
                              AnimatedOpacity(
                                opacity: _showControls || !v.isPlaying ? 1 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  color: Colors.black26,
                                  child: Center(
                                    child: IconButton(
                                      iconSize: 64.sp,
                                      color: Colors.white,
                                      onPressed: () {
                                        v.isPlaying ? _controller.pause() : _controller.play();
                                        setState(() => _showControls = !v.isPlaying);
                                      },
                                      icon: AppIcon(v.isPlaying
                                          ? Icons.pause_circle_filled_rounded
                                          : Icons.play_circle_fill_rounded),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0.w,
                                right: 0.w,
                                bottom: 0.h,
                                child: Column(
                                  children: <Widget>[
                                    VideoProgressIndicator(
                                      _controller,
                                      allowScrubbing: true,
                                      colors: VideoProgressColors(
                                        playedColor: widget.content.type.color,
                                        bufferedColor: Colors.white38,
                                        backgroundColor: Colors.white12,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: AppPadding.h, vertical: 4.h),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            '${_fmt(v.position)} / ${_fmt(v.duration)}',
                                            style: StyleText.fontSize11Weight600
                                                .copyWith(color: Colors.white),
                                          ),
                                          const Spacer(),
                                          // Playback speed: 1× -> 1.5× -> 2× -> 1×.
                                          TextButton(
                                            onPressed: () {
                                              final double next = v.playbackSpeed >= 2
                                                  ? 1
                                                  : v.playbackSpeed + 0.5;
                                              _controller.setPlaybackSpeed(next);
                                            },
                                            child: Text(
                                              '${v.playbackSpeed}×',
                                              style: StyleText.fontSize12Weight700
                                                  .copyWith(color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ),
          _Details(content: widget.content),
        ],
      ),
    );
  }
}

// ── PDF ─────────────────────────────────────────────────────────────────────

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key, required this.content});

  final LearningContent content;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfViewerController _controller = PdfViewerController();
  int _page = 1;
  int _pages = 0;
  bool _failed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.text,
        elevation: 0,
        title: Text(widget.content.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: _externalAction(context, widget.content),
        bottom: _pages == 0
            ? null
            : PreferredSize(
                preferredSize: Size.fromHeight(28.h),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Text(s.pageOf('$_page', '$_pages'), style: StyleText.fontSize12Weight600),
                ),
              ),
      ),
      body: _failed
          ? AppErrorView(
              message: s.pdfFailed,
              onRetry: () => launchUrl(Uri.parse(widget.content.fileUrl),
                  mode: LaunchMode.externalApplication),
            )
          : SfPdfViewer.network(
              widget.content.fileUrl,
              controller: _controller,
              onDocumentLoaded: (PdfDocumentLoadedDetails d) =>
                  setState(() => _pages = d.document.pages.count),
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails _) =>
                  setState(() => _failed = true),
              onPageChanged: (PdfPageChangedDetails d) =>
                  setState(() => _page = d.newPageNumber),
            ),
    );
  }
}

// ── Image ───────────────────────────────────────────────────────────────────

class ImageViewerScreen extends StatelessWidget {
  const ImageViewerScreen({super.key, required this.content});

  final LearningContent content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.text,
        elevation: 0,
        title: Text(content.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: _externalAction(context, content),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            color: Colors.black,
            height: MediaQuery.of(context).size.height * 0.55,
            child: InteractiveViewer(
              maxScale: 5,
              child: Center(
                child: Image.network(
                  content.fileUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (BuildContext _, Widget child, ImageChunkEvent? p) =>
                      p == null
                          ? child
                          : const Center(child: CircularProgressIndicator(color: Colors.white)),
                  errorBuilder: (BuildContext _, Object __, StackTrace? ___) => Center(
                    child: AppIcon(Icons.broken_image_outlined, color: Colors.white54, size: 48.sp),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Center(
              child: Text(S.of(context).pinchToZoom,
                  style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
            ),
          ),
          _Details(content: content),
        ],
      ),
    );
  }
}
