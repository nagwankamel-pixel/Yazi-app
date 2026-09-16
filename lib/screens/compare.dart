import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state.dart';
import '../core/theme.dart';
import '../data/mock.dart';

/// Side-by-side comparison of up to three nurseries.
///
/// Only nurseries carry comparison data, so the picker is limited to them.
class NurseryCompareScreen extends StatefulWidget {
  const NurseryCompareScreen({super.key, this.initial});

  /// Nursery to start with, when opened from a listing.
  final Business? initial;

  @override
  State<NurseryCompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<NurseryCompareScreen> {
  static const _maxPicks = 3;
  late final List<String> _picked = [
    if (widget.initial != null) widget.initial!.id,
  ];

  List<Business> get _all => kBusinesses.where((b) => b.cat == 'nurseries').toList();

  List<Business> get _chosen =>
      _picked.map((id) => _all.firstWhere((b) => b.id == id)).toList();

  Future<void> _pick() async {
    final app = context.read<AppState>();
    // Nurseries with something recorded come first — comparing three blank
    // columns tells a parent nothing.
    final list = [..._all]..sort((a, b) {
        final ac = a.hasCompareData ? 0 : 1, bc = b.hasCompareData ? 0 : 1;
        return ac != bc ? ac - bc : a.nameEn.compareTo(b.nameEn);
      });

    // Search within the sheet — 120 nurseries is too many to scroll.
    final searchCtl = TextEditingController();
    var q = '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Yozi.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(Yozi.rLg)),
          ),
          child: Column(children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Yozi.faint, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${app.t('comparePick')}  (${_picked.length}/$_maxPicks)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: searchCtl,
                autofocus: false,
                onChanged: (v) => setSheet(() => q = v.trim().toLowerCase()),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: app.t('searchPh'),
                  prefixIcon: const Icon(Icons.search_rounded,
                      size: 20, color: Yozi.muted),
                  suffixIcon: q.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            searchCtl.clear();
                            setSheet(() => q = '');
                          }),
                  filled: true,
                  fillColor: Yozi.ground,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Yozi.rMd),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
            Expanded(
              child: Builder(builder: (_) {
                final shown = q.isEmpty
                    ? list
                    : list
                        .where((b) =>
                            b.nameEn.toLowerCase().contains(q) ||
                            b.nameAr.contains(q))
                        .toList();
                if (shown.isEmpty) {
                  return Center(
                    child: Text(app.t('noResults'),
                        style: const TextStyle(color: Yozi.muted)),
                  );
                }
                return ListView.builder(
                itemCount: shown.length,
                itemBuilder: (_, i) {
                  final b = shown[i];
                  final on = _picked.contains(b.id);
                  final full = _picked.length >= _maxPicks && !on;
                  return ListTile(
                    enabled: !full,
                    leading: Icon(
                      on ? Icons.check_circle_rounded : Icons.circle_outlined,
                      color: on ? Yozi.violet : (full ? Yozi.faint : Yozi.muted),
                    ),
                    title: Text(b.nameEn,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: full ? Yozi.faint : Yozi.ink)),
                    subtitle: Text(
                      b.hasCompareData
                          ? kAreas[b.area].name(app.lang)
                          : '${kAreas[b.area].name(app.lang)} · ${app.t('compareNoData')}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: full
                        ? null
                        : () {
                            setSheet(() => setState(() =>
                                on ? _picked.remove(b.id) : _picked.add(b.id)));
                          },
                  );
                },
              );
              }),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Yozi.violet),
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(app.t('done')),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final chosen = _chosen;

    return Scaffold(
      backgroundColor: Yozi.ground,
      appBar: AppBar(
        title: Text(app.t('compareTitle')),
        actions: [
          TextButton(
            onPressed: _pick,
            child: Text(app.t('compareChange'),
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      body: chosen.isEmpty
          ? _empty(app)
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  _headerRow(chosen),
                  const SizedBox(height: 8),
                  for (final f in Business.compareFields)
                    _row(f.$3, f.$2, chosen.map((b) => b.cmp[f.$1] == true).toList()),
                  _textRow(app.t('workingHours'), '⏱',
                      chosen.map((b) => b.workingHours ?? '—').toList()),
                  _textRow(app.t('ages'), '👶',
                      chosen.map((b) => b.ageLabel.isEmpty ? '—' : b.ageLabel).toList()),
                  const SizedBox(height: 16),
                  Text(app.t('compareNote'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, color: Yozi.muted)),
                ]),
              ),
            ),
    );
  }

  Widget _empty(AppState app) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.compare_arrows_rounded, size: 56, color: Yozi.faint),
            const SizedBox(height: 12),
            Text(app.t('compareEmpty'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Yozi.muted)),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Yozi.violet),
              onPressed: _pick,
              child: Text(app.t('comparePick')),
            ),
          ]),
        ),
      );

  Widget _headerRow(List<Business> chosen) => Row(children: [
        const SizedBox(width: 108),
        for (final b in chosen)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(children: [
                Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Yozi.violetGhost,
                    borderRadius: BorderRadius.circular(Yozi.rMd),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(b.nameEn,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                          color: Yozi.violet)),
                ),
              ]),
            ),
          ),
      ]);

  Widget _row(String emoji, String label, List<bool> values) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Yozi.surface,
          borderRadius: BorderRadius.circular(Yozi.rMd),
        ),
        child: Row(children: [
          SizedBox(
            width: 108,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text('$emoji  $label',
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w700)),
            ),
          ),
          for (final v in values)
            Expanded(
              child: Icon(
                v ? Icons.check_circle_rounded : Icons.remove_circle_outline,
                size: 20,
                color: v ? Yozi.mint : Yozi.faint,
              ),
            ),
        ]),
      );

  Widget _textRow(String label, String emoji, List<String> values) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Yozi.surface,
          borderRadius: BorderRadius.circular(Yozi.rMd),
        ),
        child: Row(children: [
          SizedBox(
            width: 108,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text('$emoji  $label',
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w700)),
            ),
          ),
          for (final v in values)
            Expanded(
              child: Text(v,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 11, height: 1.25)),
            ),
        ]),
      );
}
