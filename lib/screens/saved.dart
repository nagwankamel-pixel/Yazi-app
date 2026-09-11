import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state.dart';
import '../core/theme.dart';
import '../data/mock.dart';
import '../widgets/common.dart';
import 'events.dart';
import 'explore.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final savedBiz =
        kBusinesses.where((b) => app.isSaved(b.id)).toList();
    final savedEv =
        kEvents.where((e) => app.isEventSaved(e.id)).toList();

    return SafeArea(
      bottom: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Text(app.t('savedTitle'),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
                color: Yozi.surface2, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              _seg(0, app.t('places')),
              _seg(1, app.t('eventsTab')),
              _seg(2, app.t('compare')),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        Expanded(child: _body(app, savedBiz, savedEv)),
      ]),
    );
  }

  Widget _body(AppState app, List<Business> biz, List<KidsEvent> ev) {
    if (_tab == 2) {
      // Inline compare — reuse the compare table for nurseries.
      return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(app.t('compareTitle'),
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 8),
        _CompareEmbed(),
      ]);
    }
    if (_tab == 0) {
      if (biz.isEmpty) return _empty(app);
      return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: biz.map((b) => BizCard(b)).toList());
    }
    if (ev.isEmpty) return _empty(app);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: ev
          .map((e) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Material(
                  color: Yozi.surface,
                  borderRadius: BorderRadius.circular(Yozi.rMd),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Yozi.rMd),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => EventScreen(eventId: e.id))),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(color: Yozi.line),
                          borderRadius: BorderRadius.circular(Yozi.rMd)),
                      child: Row(children: [
                        SizedBox(
                            width: 76,
                            height: 76,
                            child: GradThumb(
                                grad: e.grad, icon: Icons.event_rounded)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.name(app.lang),
                                    style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(height: 3),
                                Text(
                                    '${e.date(app.lang)} · ${e.time(app.lang)}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Yozi.muted)),
                                Text(kAreas[e.area].name(app.lang),
                                    style: const TextStyle(
                                        fontSize: 12, color: Yozi.muted)),
                              ]),
                        ),
                        HeartButton(id: e.id, isEvent: true),
                      ]),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _empty(AppState app) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.favorite_rounded, size: 44, color: Yozi.faint),
          const SizedBox(height: 12),
          Text(app.t('emptySaved'),
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(app.t('emptySavedSub'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Yozi.muted, fontSize: 13)),
          ),
        ]),
      );

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
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: on ? Yozi.ink : Yozi.muted)),
        ),
      ),
    );
  }
}

/// Embeds the nursery comparison table without its own Scaffold.
class _CompareEmbed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 420,
      child: CompareScreen(catId: 'nurseries'),
    );
  }
}
