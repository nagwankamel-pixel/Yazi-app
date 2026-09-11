import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state.dart';
import '../core/theme.dart';
import '../data/mock.dart';
import '../widgets/common.dart';
import 'explore.dart';
import 'videos.dart';

/// ---------- Glow tab: everything for the mother herself ----------
class GlowScreen extends StatelessWidget {
  const GlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final tiles = kSubcats['glow'] ?? const <Subcat>[];

    return SafeArea(
      bottom: false,
      child: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
        // ---- glowing hero ----
        Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Yozi.rLg),
            gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF7E8FF), Color(0xFFE9E2FF), Color(0xFFFFE7F1)]),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFFA855F7).withValues(alpha: .22),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                  spreadRadius: -10),
            ],
          ),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(app.t('mamaSpace'),
                          style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4A2A7A))),
                      const SizedBox(width: 6),
                      const Text('✨', style: TextStyle(fontSize: 24)),
                    ]),
                    const SizedBox(height: 4),
                    Text(app.t('glowSub'),
                        style: const TextStyle(
                            fontSize: 13.5, height: 1.4, color: Yozi.ink2)),
                  ]),
            ),
          ]),
        ),
        // ---- the eight Glow sections ----
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.45,
            children: tiles.map((s) => _GlowTile(sub: s)).toList(),
          ),
        ),
        // ---- videos for mama ----
        SectionRow(app.t('msVideos')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            borderRadius: BorderRadius.circular(Yozi.rLg),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const VideosScreen(asPage: true))),
              child: Ink(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFFFDE8ED), Color(0xFFEFE8FD)])),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(children: [
                    const Icon(Icons.play_circle_rounded,
                        color: Yozi.violet, size: 38),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(app.t('msVideos'),
                                style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text(app.t('msVideosSub'),
                                style: const TextStyle(
                                    fontSize: 12.5, color: Yozi.ink2)),
                          ]),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Yozi.muted),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _GlowTile extends StatelessWidget {
  const _GlowTile({required this.sub});
  final Subcat sub;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Material(
      color: Yozi.surface,
      borderRadius: BorderRadius.circular(Yozi.rMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(Yozi.rMd),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
                ResultsScreen(catId: 'glow', initialSubcat: sub.id))),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
              border: Border.all(color: Yozi.line),
              borderRadius: BorderRadius.circular(Yozi.rMd)),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 3D colourful artwork (admin can override from Icons & artwork)
                SizedBox(
                  width: 56,
                  height: 56,
                  child: SubcatIcon('glow', sub,
                      size: 56, iconSize: 26, color: const Color(0xFF8B3FD6)),
                ),
                Text(sub.name(app.lang),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13,
                        height: 1.3,
                        fontWeight: FontWeight.w800)),
              ]),
        ),
      ),
    );
  }
}
