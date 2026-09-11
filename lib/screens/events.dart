import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state.dart';
import '../core/theme.dart';
import '../data/mock.dart';
import '../widgets/common.dart';
import 'business.dart';

/// Weekend Plan — pushed page around the events list (the old Events tab).
class WeekendPlanScreen extends StatelessWidget {
  const WeekendPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
        appBar: AppBar(title: Text(app.t('weekendPlanT'))),
        body: const EventsScreen(showTitle: false));
  }
}

/// ---------- Events list ----------
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key, this.showTitle = true});
  final bool showTitle;

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    var list = kEvents;
    if (_tab == 1) list = list.where((e) => e.thisWeek).toList();
    if (_tab == 2) list = list.where((e) => e.price == 0).toList();

    return SafeArea(
      bottom: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (widget.showTitle)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(app.t('events'),
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
                color: Yozi.surface2, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                _seg(0, app.t('upcoming')),
                _seg(1, app.t('thisWeek')),
                _seg(2, app.t('freeTab')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: list.map((e) => _EventRow(event: e)).toList(),
          ),
        ),
      ]),
    );
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

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});
  final KidsEvent event;

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
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => EventScreen(eventId: event.id))),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: Yozi.line),
                borderRadius: BorderRadius.circular(Yozi.rMd)),
            child: Row(children: [
              SizedBox(
                width: 92,
                height: 92,
                child: Stack(children: [
                  Positioned.fill(
                      child: GradThumb(
                          grad: event.grad, icon: Icons.event_rounded)),
                  if (event.price == 0)
                    Positioned(
                        top: 6,
                        left: 6,
                        child: BadgePill(app.t('freeTab').toUpperCase(),
                            bg: Yozi.mintWash, fg: Yozi.mintDeep)),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.name(app.lang),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('${event.date(app.lang)} · ${event.time(app.lang)}',
                          style: const TextStyle(
                              fontSize: 12, color: Yozi.muted)),
                      const SizedBox(height: 2),
                      Text(
                          '${kAreas[event.area].name(app.lang)} · ${app.t('ages')} ${event.ages}',
                          style: const TextStyle(
                              fontSize: 12, color: Yozi.muted)),
                      const SizedBox(height: 5),
                      Text(
                          event.price == 0
                              ? app.t('freeEntry')
                              : (app.isArabic
                                  ? '${event.price} ج.م'
                                  : 'EGP ${event.price}'),
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: event.price == 0
                                  ? Yozi.mintDeep
                                  : Yozi.amber)),
                    ]),
              ),
              HeartButton(id: event.id, isEvent: true),
            ]),
          ),
        ),
      ),
    );
  }
}

/// ---------- Event detail ----------
class EventScreen extends StatelessWidget {
  const EventScreen({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final event = eventById(eventId);
    final org = bizByIdOrNull(event.orgId);

    return Scaffold(
      appBar: AppBar(
        title: Text(app.t('eventDetails')),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: Center(child: HeartButton(id: event.id, isEvent: true)),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 180,
            child: GradThumb(
                grad: event.grad,
                icon: Icons.event_rounded,
                size: 56,
                radius: Yozi.rLg),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(event.name(app.lang),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            _meta(Icons.event_rounded,
                '${event.date(app.lang)} · ${event.time(app.lang)}'),
            const SizedBox(height: 5),
            _meta(Icons.place_rounded,
                '${kAreas[event.area].name(app.lang)} · ${app.t('ages')} ${event.ages}'),
            const SizedBox(height: 8),
            Text(
                event.price == 0
                    ? app.t('freeEntry')
                    : (app.isArabic
                        ? '${event.price} ج.م'
                        : 'EGP ${event.price}'),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color:
                        event.price == 0 ? Yozi.mintDeep : Yozi.amber)),
          ]),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Yozi.surface,
              border: Border.all(color: Yozi.line),
              borderRadius: BorderRadius.circular(Yozi.rMd)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(app.t('about'),
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(event.desc(app.lang),
                style: const TextStyle(
                    fontSize: 13.5, height: 1.55, color: Yozi.ink2)),
          ]),
        ),
        if (org != null) Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          decoration: BoxDecoration(
              color: Yozi.surface,
              border: Border.all(color: Yozi.line),
              borderRadius: BorderRadius.circular(Yozi.rMd)),
          child: ListTile(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => BusinessScreen(bizId: org.id))),
            title: Text(app.t('organiser'),
                style: const TextStyle(
                    fontSize: 12, color: Yozi.muted, fontWeight: FontWeight.w700)),
            subtitle: Text(org.name(app.lang),
                style: const TextStyle(
                    fontSize: 14,
                    color: Yozi.violet,
                    fontWeight: FontWeight.w800)),
            trailing: const Icon(Icons.chevron_right_rounded, color: Yozi.muted),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(children: [
            FilledButton.icon(
              onPressed: () {
                app.saveEvent(event.id);
                showToast(context, app.t('savedEvent'));
              },
              icon: const Icon(Icons.favorite_rounded, size: 18),
              label: Text(app.t('saveEvent')),
            ),
            const SizedBox(height: 9),
            TextButton.icon(
              onPressed: () => showToast(context, app.t('calAdded')),
              icon: const Icon(Icons.event_available_rounded, size: 18),
              label: Text(app.t('addCal')),
              style: TextButton.styleFrom(
                  foregroundColor: Yozi.violetDeep,
                  backgroundColor: Yozi.violetSoft,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ]),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
              color: Yozi.skyWash,
              borderRadius: BorderRadius.circular(Yozi.rSm)),
          child: Row(children: [
            const Icon(Icons.favorite_rounded, size: 16, color: Yozi.sky),
            const SizedBox(width: 9),
            Expanded(
                child: Text(app.t('momsSavedEvent'),
                    style: const TextStyle(
                        color: Yozi.sky,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700))),
          ]),
        ),
      ]),
    );
  }

  Widget _meta(IconData icon, String text) => Row(children: [
        Icon(icon, size: 14, color: Yozi.muted),
        const SizedBox(width: 5),
        Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13.5, color: Yozi.muted))),
      ]);
}
