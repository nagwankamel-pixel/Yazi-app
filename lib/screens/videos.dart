import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state.dart';
import '../core/theme.dart';
import '../data/mock.dart';
import '../widgets/common.dart';

/// ---------- Videos tab: tutorials & ideas (managed from the admin) ----------
class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key, this.initialKind, this.asPage = false});
  final String? initialKind;

  /// True when pushed as its own route (from Glow) instead of a tab.
  final bool asPage;

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

const _kinds = ['birthday_decor', 'cooking', 'home_activities'];

class _VideosScreenState extends State<VideosScreen> {
  late int _tab =
      widget.initialKind == null ? 0 : _kinds.indexOf(widget.initialKind!).clamp(0, 2);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final labels = [app.t('vidsDecor'), app.t('vidsCooking'), app.t('vidsHome')];
    final list = kVideos.where((v) => v.kind == _kinds[_tab]).toList();

    final body = SafeArea(
      bottom: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (!widget.asPage)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(app.t('videosTab'),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
                color: Yozi.surface2, borderRadius: BorderRadius.circular(12)),
            child: Row(children: List.generate(3, (i) => _seg(i, labels[i]))),
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.ondemand_video_rounded,
                      size: 44, color: Yozi.faint),
                  const SizedBox(height: 10),
                  Text(app.t('noVideos'),
                      style: const TextStyle(
                          color: Yozi.muted, fontWeight: FontWeight.w700)),
                ]))
              : ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: list.map((v) => VideoCard(v)).toList()),
        ),
      ]),
    );
    if (!widget.asPage) return body;
    return Scaffold(
        appBar: AppBar(title: Text(app.t('videosTab'))), body: body);
  }

  Widget _seg(int i, String label) {
    final on = _tab == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
              color: on ? Yozi.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: on ? Yozi.cardShadow : null),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: on ? Yozi.ink : Yozi.muted)),
          ),
        ),
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  const VideoCard(this.video, {super.key});
  final TipVideo video;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Material(
        color: Yozi.surface,
        borderRadius: BorderRadius.circular(Yozi.rMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(Yozi.rMd),
          onTap: () => openUrl(context, video.url),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: Yozi.line),
                borderRadius: BorderRadius.circular(Yozi.rMd)),
            child: Row(children: [
              SizedBox(
                width: 92,
                height: 64,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: video.thumb != null && video.thumb!.isNotEmpty
                      ? Image.network(video.thumb!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const _VideoThumb())
                      : const _VideoThumb(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(video.title(app.lang),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, height: 1.35, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.play_circle_rounded, color: Yozi.violet, size: 28),
            ]),
          ),
        ),
      ),
    );
  }
}

class _VideoThumb extends StatelessWidget {
  const _VideoThumb();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFF7C4DE8), Color(0xFFA78BFA)])),
      child: Center(
          child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30)),
    );
  }
}
