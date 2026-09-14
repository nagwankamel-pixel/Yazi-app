import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state.dart';
import '../core/theme.dart';
import '../data/mock.dart';
import '../widgets/common.dart';
import 'videos.dart';

/// Pushed page wrapper around the category directory (the old Explore tab).
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
        appBar: AppBar(title: Text(app.t('categories'))),
        body: const ExploreScreen());
  }
}

/// ---------- Category directory ----------
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return SafeArea(
      bottom: false,
      child: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Text(app.t('explore'),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Material(
            color: Yozi.surface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen())),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                    border: Border.all(color: Yozi.line),
                    borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  const Icon(Icons.search_rounded, size: 20, color: Yozi.muted),
                  const SizedBox(width: 10),
                  Text(app.t('searchPh'),
                      style:
                          const TextStyle(color: Yozi.faint, fontSize: 14.5)),
                ]),
              ),
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.35,
          children: browseCats(home: false).map((c) {
            final n = kBusinesses
                .where((b) => b.cat == c.id && b.area == app.areaIndex)
                .length;
            return Material(
              color: Yozi.surface,
              borderRadius: BorderRadius.circular(Yozi.rMd),
              child: InkWell(
                borderRadius: BorderRadius.circular(Yozi.rMd),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ResultsScreen(catId: c.id))),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  decoration: BoxDecoration(
                      border: Border.all(color: Yozi.line),
                      borderRadius: BorderRadius.circular(Yozi.rMd)),
                  child: Row(children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: CategoryIcon(c, size: 52)),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(c.name(app.lang),
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700)),
                            ),
                            Text('$n ${app.t('results')}',
                                style: const TextStyle(
                                    fontSize: 11, color: Yozi.muted)),
                          ]),
                    ),
                  ]),
                ),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }
}

/// ---------- Search ----------
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final q = _q.trim().toLowerCase();
    final allHits = q.isEmpty
        ? const <Business>[]
        : kBusinesses.where((b) {
            final hay =
                '${b.nameEn} ${b.nameAr} ${b.keywords} ${catById(b.cat).en} ${catById(b.cat).ar}'
                    .toLowerCase();
            return hay.contains(q);
          }).toList();
    final inArea = allHits.where((b) => b.area == app.areaIndex).toList();
    final hits = inArea.isNotEmpty ? inArea : allHits;

    final recent =
        app.isArabic ? ['سباحة', 'حضانة', 'عيد ميلاد'] : ['Swimming', 'Nursery', 'Birthday'];
    final popular = app.isArabic
        ? ['مدارس IG', 'باليه', 'معسكر صيفي', '7adana']
        : ['IG schools', 'Ballet', 'Summer camp', '7adana'];

    return Scaffold(
      appBar: AppBar(
          title: Text('${app.t('searchIn')} ${kAreas[app.areaIndex].name(app.lang)}')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: TextField(
            controller: _ctrl,
            autofocus: true,
            onChanged: (v) => setState(() => _q = v),
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: app.t('searchPh'),
              hintStyle: const TextStyle(color: Yozi.faint),
              prefixIcon:
                  const Icon(Icons.search_rounded, color: Yozi.muted, size: 20),
              suffixIcon: _q.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          size: 18, color: Yozi.muted),
                      onPressed: () {
                        _ctrl.clear();
                        setState(() => _q = '');
                      })
                  : null,
              filled: true,
              fillColor: Yozi.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Yozi.line)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: Yozi.violet, width: 1.5)),
            ),
          ),
        ),
        Expanded(
          child: q.isEmpty
              ? ListView(children: [
                  SectionRow(app.t('recent')),
                  _chipsWrap(recent),
                  SectionRow(app.t('popular')),
                  _chipsWrap(popular),
                ])
              : hits.isEmpty
                  ? Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search_off_rounded,
                                size: 44, color: Yozi.faint),
                            const SizedBox(height: 10),
                            Text(app.t('noResults'),
                                style: const TextStyle(
                                    color: Yozi.muted,
                                    fontWeight: FontWeight.w700)),
                          ]))
                  : ListView(
                      padding: const EdgeInsets.only(top: 12, bottom: 24),
                      children: hits.map((b) => BizCard(b)).toList()),
        ),
      ]),
    );
  }

  Widget _chipsWrap(List<String> items) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((s) => YaziChip(
                    label: s,
                    onTap: () {
                      _ctrl.text = s;
                      setState(() => _q = s);
                    },
                  ))
              .toList(),
        ),
      );
}

/// ---------- Results ----------
class ResultsScreen extends StatefulWidget {
  const ResultsScreen(
      {super.key, this.catId, this.initialOpen = false, this.initialSubcat});
  final String? catId;
  final bool initialOpen;
  final String? initialSubcat;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

/// Age filter bands shown as choices: (label, min age, max age).
const _ageBands = <(String, int, int)>[
  ('0–2', 0, 2),
  ('3–5', 3, 5),
  ('6–9', 6, 9),
  ('10+', 10, 99),
];

/// School year levels, with the ages they normally cover. Schools filter by
/// these instead of raw ages, so a parent picks the stage their child is at.
const _schoolYears = <(String, int, int)>[
  ('Pre-K', 3, 3),
  ('FS1 / KG1', 4, 4),
  ('FS2 / KG2', 5, 5),
  ('Year 1', 6, 6),
  ('Year 2', 7, 7),
  ('Year 3', 8, 8),
  ('Year 4', 9, 9),
  ('Year 5', 10, 10),
  ('Year 6', 11, 11),
  ('Year 7', 12, 12),
  ('Year 8', 13, 13),
  ('Year 9', 14, 14),
  ('Year 10', 15, 15),
  ('Year 11', 16, 16),
  ('Year 12', 17, 18),
];

class _ResultsScreenState extends State<ResultsScreen> {
  late final Set<String> _filters = {if (widget.initialOpen) 'open'};
  late String? _catId = widget.catId;
  late final Set<String> _subcats = {
    if ((widget.initialSubcat ?? '').isNotEmpty) widget.initialSubcat!
  };
  int? _ageBand;
  int _areaSel = -1; // -1 = my area, -2 = all areas, >=0 = specific area
  String _sort = 'rec'; // rec | rating | near

  /// Schools hide the "Open now" / "Offers" chips and say "Year" not "Ages".
  bool get _isSchools => _catId == 'schools';

  /// Filters that do not exist on the Schools screen must not survive a
  /// category switch, or they keep filtering invisibly.
  void _dropFiltersMissingFrom(String? catId) {
    if (catId == 'schools') _filters.removeAll({'open', 'off'});
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final cat = _catId != null ? catById(_catId!) : null;
    final subs = kSubcats[_catId] ?? const <Subcat>[];
    final areaIdx = _areaSel == -1 ? app.areaIndex : _areaSel;

    var list = kBusinesses
        .where((b) => _catId == null || b.cat == _catId)
        .where((b) => _areaSel == -2 || b.area == areaIdx)
        // A listing matches if it carries ANY of the selected subcategories,
        // so "English+French" shows under both English and Français.
        .where((b) => _subcats.isEmpty || _subcats.any(b.hasSubcat))
        .where((b) {
          if (_ageBand == null) return true;
          final r = b.ageRange;
          if (r == null) return true; // unknown ages are never excluded
          final bands = _isSchools ? _schoolYears : _ageBands;
          final band = bands[_ageBand!];
          return r.$1 <= band.$3 && r.$2 >= band.$2;
        })
        .where((b) => !_filters.contains('ver') || b.verified)
        .where((b) => !_filters.contains('open') || b.isOpenNow)
        .where((b) =>
            !_filters.contains('off') ||
            b.offer ||
            kOffers.any((o) => o.bizId == b.id))
        // Item 11: drive == 0 means "not recorded", not "zero minutes away".
        .where((b) =>
            !_filters.contains('near') || (b.drive > 0 && b.drive <= 15))
        .toList()
      ..sort((a, b) {
        switch (_sort) {
          case 'rating':
            return b.rating.compareTo(a.rating);
          case 'near':
            // unknown durations sort last instead of first
            final ad = a.drive > 0 ? a.drive : 9999;
            final bd = b.drive > 0 ? b.drive : 9999;
            return ad.compareTo(bd);
          default:
            final s = (b.sponsored ? 1 : 0) - (a.sponsored ? 1 : 0);
            return s != 0 ? s : b.rating.compareTo(a.rating);
        }
      });

    final canCompare = _catId == 'nurseries' || _catId == 'schools';
    final sortLabels = {
      'rec': app.t('sortBy'),
      'rating': app.t('topRated'),
      'near': app.t('nearest'),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(_subcats.length == 1
            ? (subcatById(_catId ?? '', _subcats.first)?.name(app.lang)
                ?? cat?.name(app.lang)
                ?? app.t('results'))
            : (cat?.name(app.lang) ?? app.t('results'))),
        actions: [
          if (canCompare)
            IconButton(
                tooltip: app.t('compare'),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => CompareScreen(catId: _catId!))),
                icon: const Icon(Icons.table_rows_rounded, size: 20)),
        ],
      ),
      body: Column(children: [
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // area picker
              _chip(
                icon: Icons.place_rounded,
                label: _areaSel == -2
                    ? app.t('allAreas')
                    : kAreas[areaIdx].name(app.lang),
                selected: _areaSel != -2,
                onTap: _pickArea,
              ),
              // category picker (only when the screen isn't category-locked)
              if (widget.catId == null)
                _chip(
                  icon: Icons.category_rounded,
                  label: cat?.name(app.lang) ?? app.t('allCats'),
                  selected: _catId != null,
                  onTap: _pickCategory,
                ),
              // age filter
              _chip(
                icon: Icons.child_care_rounded,
                label: _ageBand == null
                    ? (_isSchools ? app.t('filterSchoolYear') : app.t('filterAge'))
                    : (_isSchools
                        ? _schoolYears[_ageBand!].$1
                        : '${app.t('ages')} ${_ageBands[_ageBand!].$1}'),
                selected: _ageBand != null,
                onTap: _pickAge,
              ),
              _filterChip('ver', Icons.verified_rounded, app.t('verifiedOnly')),
              // Item 7: "Open now" and "Offers" are not shown for Schools.
              if (!_isSchools) ...[
                _filterChip('open', Icons.schedule_rounded, app.t('openNow')),
                _filterChip('off', Icons.local_activity_rounded, app.t('hasOffer')),
              ],
              _filterChip('near', Icons.near_me_rounded, app.t('nearMe')),
            ],
          ),
        ),
        // subcategory picker — 3D artwork where we have it (languages, indoor…)
        if (subs.isNotEmpty)
          if (subs.any((s) => s.asset != null))
            SizedBox(
              height: 96,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                children: [
                  for (final s in subs)
                    _SubcatCard(
                      catId: _catId ?? '',
                      sub: s,
                      selected: _subcats.contains(s.id),
                      onTap: () => setState(() => _subcats.contains(s.id)
                          ? _subcats.remove(s.id)
                          : _subcats.add(s.id)),
                    ),
                ],
              ),
            )
          else
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _chip(
                      label: app.t('subcatAll'),
                      selected: _subcats.isEmpty,
                      onTap: () => setState(() => _subcats.clear())),
                  for (final s in subs)
                    _chip(
                        label: s.name(app.lang),
                        selected: _subcats.contains(s.id),
                        onTap: () => setState(() => _subcats.contains(s.id)
                            ? _subcats.remove(s.id)
                            : _subcats.add(s.id))),
                ],
              ),
            ),
        // decoration tutorials shortcut inside the Birthdays category
        if (_catId == 'birthdays') const _DecorVideosBanner(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(children: [
            Text('${list.length} ${app.t('results')}',
                style: const TextStyle(color: Yozi.muted, fontSize: 13)),
            const Spacer(),
            PopupMenuButton<String>(
              onSelected: (v) => setState(() => _sort = v),
              itemBuilder: (_) => sortLabels.entries
                  .map((e) => PopupMenuItem(
                      value: e.key,
                      child: Text(e.value,
                          style: TextStyle(
                              fontWeight: _sort == e.key
                                  ? FontWeight.w800
                                  : FontWeight.w500))))
                  .toList(),
              child: Text('${sortLabels[_sort]} ▾',
                  style: const TextStyle(
                      color: Yozi.violet,
                      fontSize: 13,
                      fontWeight: FontWeight.w800)),
            ),
          ]),
        ),
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Text(app.t('noResults'),
                      style: const TextStyle(
                          color: Yozi.muted, fontWeight: FontWeight.w700)))
              : ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: list.map((b) => BizCard(b)).toList()),
        ),
      ]),
    );
  }

  void _pickArea() {
    final app = context.read<AppState>();
    _optionsSheet(
      title: app.t('filterArea'),
      options: [
        (app.t('allAreas'), -2),
        for (var i = 0; i < kAreas.length; i++) (kAreas[i].name(app.lang), i),
      ],
      selected: _areaSel == -1 ? app.areaIndex : _areaSel,
      onPick: (v) => setState(() => _areaSel = v),
    );
  }

  void _pickCategory() {
    final app = context.read<AppState>();
    final cats = browseCats(home: false);
    _optionsSheet(
      title: app.t('filterCategory'),
      options: [
        (app.t('allCats'), -1),
        for (var i = 0; i < cats.length; i++) (cats[i].name(app.lang), i),
      ],
      selected: _catId == null ? -1 : cats.indexWhere((c) => c.id == _catId),
      onPick: (v) => setState(() {
        _catId = v == -1 ? null : cats[v].id;
        _subcats.clear();
        _dropFiltersMissingFrom(_catId);
      }),
    );
  }

  void _pickAge() {
    final app = context.read<AppState>();
    _optionsSheet(
      title: app.t('filterAge'),
      options: [
        (app.t('anyAge'), -1),
        if (_isSchools)
          for (var i = 0; i < _schoolYears.length; i++)
            (_schoolYears[i].$1, i)
        else
          for (var i = 0; i < _ageBands.length; i++)
            ('${app.t('ages')} ${_ageBands[i].$1}', i),
      ],
      selected: _ageBand ?? -1,
      onPick: (v) => setState(() => _ageBand = v == -1 ? null : v),
    );
  }

  void _optionsSheet(
      {required String title,
      required List<(String, int)> options,
      required int selected,
      required void Function(int) onPick}) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                          color: Yozi.line,
                          borderRadius: BorderRadius.circular(4))),
                ),
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: options
                      .map((o) => YaziChip(
                            label: o.$1,
                            selected: o.$2 == selected,
                            onTap: () {
                              onPick(o.$2);
                              Navigator.pop(ctx);
                            },
                          ))
                      .toList(),
                ),
              ]),
        ),
      ),
    );
  }

  Widget _chip(
      {IconData? icon,
      required String label,
      required bool selected,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Center(
          child:
              YaziChip(icon: icon, label: label, selected: selected, onTap: onTap)),
    );
  }

  Widget _filterChip(String id, IconData icon, String label) {
    final on = _filters.contains(id);
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Center(
        child: YaziChip(
          icon: icon,
          label: label,
          selected: on,
          onTap: () => setState(() {
            on ? _filters.remove(id) : _filters.add(id);
          }),
        ),
      ),
    );
  }
}

/// Subcategory card with its 3D artwork (languages, indoor / outdoor / pool).
class _SubcatCard extends StatelessWidget {
  const _SubcatCard(
      {required this.catId, required this.sub, required this.selected, required this.onTap});
  final String catId;
  final Subcat sub;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 10),
      child: SizedBox(
        width: 82,
        child: Material(
          color: selected ? Yozi.violetGhost : Yozi.surface,
          borderRadius: BorderRadius.circular(Yozi.rMd),
          child: InkWell(
            borderRadius: BorderRadius.circular(Yozi.rMd),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: selected ? Yozi.violet : Yozi.line,
                      width: selected ? 1.6 : 1),
                  borderRadius: BorderRadius.circular(Yozi.rMd)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                      width: 46, height: 46,
                      child: SubcatIcon(catId, sub, size: 46)),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 16,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(sub.name(app.lang),
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 11,
                            height: 1.3,
                            fontWeight: FontWeight.w800,
                            color: selected ? Yozi.violetDeep : Yozi.ink2)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Banner linking to birthday-decoration tutorial videos.
class _DecorVideosBanner extends StatelessWidget {
  const _DecorVideosBanner();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
      child: Material(
        color: Yozi.violetGhost,
        borderRadius: BorderRadius.circular(Yozi.rSm),
        child: InkWell(
          borderRadius: BorderRadius.circular(Yozi.rSm),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => Scaffold(
                  appBar: AppBar(title: Text(app.t('videosTab'))),
                  body: const VideosScreen(initialKind: 'birthday_decor')))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            child: Row(children: [
              const Icon(Icons.play_circle_rounded,
                  size: 19, color: Yozi.violet),
              const SizedBox(width: 9),
              Expanded(
                child: Text(app.t('decorVideosBanner'),
                    style: const TextStyle(
                        color: Yozi.violetDeep,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800)),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: Yozi.violetDeep),
            ]),
          ),
        ),
      ),
    );
  }
}

/// ---------- Compare ----------
class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key, required this.catId});
  final String catId;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final isSchools = catId == 'schools';
    final items = (kBusinesses.where((b) => b.cat == catId).toList()
          ..sort((a, b) => b.rating.compareTo(a.rating)))
        .take(3)
        .toList();
    final dash = items.map((_) => '—').toList();

    TableRow row(String label, List<String> values, {Color? valueColor}) =>
        TableRow(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(label,
                style: const TextStyle(
                    color: Yozi.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
          ...values.map((v) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Text(v,
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: valueColor ?? Yozi.ink)),
              )),
        ]);

    return Scaffold(
      appBar: AppBar(
          title:
              Text(app.t(isSchools ? 'compareSchools' : 'compareTitle'))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          decoration: BoxDecoration(
              color: Yozi.surface,
              borderRadius: BorderRadius.circular(Yozi.rMd),
              boxShadow: Yozi.cardShadow),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 430),
              child: Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                border: const TableBorder(
                    horizontalInside: BorderSide(color: Yozi.lineSoft)),
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Yozi.surface2),
                    children: [
                      const SizedBox(height: 40),
                      ...items.map((b) => Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(b.name(app.lang),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800)),
                          )),
                    ],
                  ),
                  row(app.t('fees'),
                      items.map((b) => b.price(app.lang).isEmpty ? '—' : b.price(app.lang)).toList(),
                      valueColor: Yozi.mintDeep),
                  row(app.t('ages'),
                      items.map((b) => b.ages.isEmpty ? '—' : b.ages).toList()),
                  if (isSchools) ...[
                    row(app.t('curriculum'), dash),
                    row(app.t('busSvc'), dash),
                  ] else ...[
                    row(app.t('ratio'), dash),
                    row(app.t('meals'), dash),
                    row(app.t('busSvc'), dash),
                  ],
                  row('⭐',
                      items.map((b) => '${b.rating} (${b.reviews})').toList()),
                  row(app.t('verified'),
                      items.map((b) => b.verified ? '✓' : '—').toList(),
                      valueColor: Yozi.sky),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
              color: Yozi.skyWash,
              borderRadius: BorderRadius.circular(Yozi.rSm)),
          child: Row(children: [
            const Icon(Icons.workspace_premium_rounded,
                size: 18, color: Yozi.sky),
            const SizedBox(width: 9),
            Expanded(
                child: Text('${app.t('b2')} — YAZI Premium',
                    style: const TextStyle(
                        color: Yozi.sky,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700))),
          ]),
        ),
      ]),
    );
  }
}
