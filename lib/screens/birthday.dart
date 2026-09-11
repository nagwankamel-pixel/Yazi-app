import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state.dart';
import '../core/theme.dart';
import '../data/mock.dart';
import '../widgets/common.dart';

/// ---------- Birthday Planner tab ----------
/// Collects the party details and suggests matching birthday places/services.
class BirthdayPlannerScreen extends StatefulWidget {
  const BirthdayPlannerScreen({super.key});

  @override
  State<BirthdayPlannerScreen> createState() => _BirthdayPlannerScreenState();
}

class _BirthdayPlannerScreenState extends State<BirthdayPlannerScreen> {
  int _age = 4;
  String _place = 'indoor'; // indoor | outdoor | pool
  bool _custom = false;
  final _budgetCtrl = TextEditingController();
  final Set<String> _extras = {};

  @override
  void initState() {
    super.initState();
    final kids = context.read<AppState>().children;
    if (kids.isNotEmpty) _age = kids.first.age.clamp(1, 16);
  }

  @override
  void dispose() {
    _budgetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final extras = {
      'clown': app.t('clown'),
      'decorations': app.t('decorationsA'),
      'puppet': app.t('puppet'),
      'magician': app.t('magician'),
      'facepaint': app.t('facePaint'),
    };
    final placeSubs = kSubcats['birthdays']!
        .where((s) => ['indoor', 'outdoor', 'pool'].contains(s.id))
        .toList();

    return SafeArea(
      bottom: false,
      child: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(app.t('bpTitle'),
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(app.t('bpSub'),
                style: const TextStyle(color: Yozi.muted, fontSize: 14)),
          ]),
        ),
        // child age
        _label(app.t('childAge')),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          decoration: _box(),
          child: Row(children: [
            const Icon(Icons.cake_rounded, color: Yozi.violet, size: 20),
            const SizedBox(width: 10),
            Text('$_age ${app.t('years')}',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const Spacer(),
            IconButton(
                onPressed: () =>
                    setState(() => _age = (_age - 1).clamp(1, 16)),
                icon: const Icon(Icons.remove_circle_outline_rounded,
                    color: Yozi.violet)),
            IconButton(
                onPressed: () =>
                    setState(() => _age = (_age + 1).clamp(1, 16)),
                icon: const Icon(Icons.add_circle_outline_rounded,
                    color: Yozi.violet)),
          ]),
        ),
        // place type
        _label(app.t('bpPlace')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: placeSubs
                .map((s) => YaziChip(
                      label: s.name(app.lang),
                      selected: _place == s.id,
                      onTap: () => setState(() => _place = s.id),
                    ))
                .toList(),
          ),
        ),
        // customised theme
        _label(app.t('bpCustom')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(spacing: 8, children: [
            YaziChip(
                label: app.t('yes'),
                selected: _custom,
                onTap: () => setState(() => _custom = true)),
            YaziChip(
                label: app.t('no'),
                selected: !_custom,
                onTap: () => setState(() => _custom = false)),
          ]),
        ),
        // budget
        _label(app.t('bpBudget')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _budgetCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: app.isArabic ? 'مثال: ٥٠٠٠' : 'e.g. 5000',
              hintStyle: const TextStyle(color: Yozi.faint, fontSize: 13.5),
              prefixIcon: const Icon(Icons.payments_rounded,
                  color: Yozi.muted, size: 20),
              filled: true,
              fillColor: Yozi.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Yozi.line)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: Yozi.violet, width: 1.5)),
            ),
          ),
        ),
        // extras
        _label(app.t('bpActivities')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: extras.entries
                .map((e) => YaziChip(
                      label: e.value,
                      selected: _extras.contains(e.key),
                      onTap: () => setState(() => _extras.contains(e.key)
                          ? _extras.remove(e.key)
                          : _extras.add(e.key)),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FilledButton.icon(
            onPressed: () => _showMatches(context),
            icon: const Icon(Icons.celebration_rounded, size: 19),
            label: Text(app.t('bpShow')),
          ),
        ),
      ]),
    );
  }

  void _showMatches(BuildContext context) {
    final app = context.read<AppState>();
    // venues matching the place type (untagged venues still count), plus
    // service providers (decor / cakes / programs…) when extras are picked
    final matches = kBusinesses.where((b) {
      if (b.cat != 'birthdays') return false;
      final isVenue = b.subcat.isEmpty ||
          ['indoor', 'outdoor', 'pool'].contains(b.subcat);
      if (isVenue) return b.subcat.isEmpty || b.subcat == _place;
      if (_extras.contains('decorations') && b.subcat == 'decoration') {
        return true;
      }
      return ['giveaways', 'cakes', 'programs'].contains(b.subcat) &&
          _extras.isNotEmpty;
    }).toList()
      ..sort((a, b) {
        final local = (b.area == app.areaIndex ? 1 : 0) -
            (a.area == app.areaIndex ? 1 : 0);
        return local != 0 ? local : b.rating.compareTo(a.rating);
      });

    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => Scaffold(
              appBar: AppBar(title: Text(app.t('bpResults'))),
              body: matches.isEmpty
                  ? Center(
                      child: Text(app.t('noResults'),
                          style: const TextStyle(
                              color: Yozi.muted, fontWeight: FontWeight.w700)))
                  : ListView(
                      padding: const EdgeInsets.only(top: 12, bottom: 24),
                      children: matches.map((b) => BizCard(b)).toList()),
            )));
  }

  BoxDecoration _box() => BoxDecoration(
      color: Yozi.surface,
      border: Border.all(color: Yozi.line),
      borderRadius: BorderRadius.circular(Yozi.rMd));

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
        child: Text(s,
            style: const TextStyle(
                fontSize: 13.5, fontWeight: FontWeight.w800, color: Yozi.ink2)),
      );
}
