import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/location.dart';
import '../core/state.dart';
import '../data/api.dart';
import '../core/theme.dart';
import '../data/mock.dart';
import '../widgets/common.dart';
import 'business.dart';
import 'events.dart';
import 'explore.dart';
import 'offers.dart';
import 'premium.dart';

/// Bottom-sheet area picker shared by home & profile.
void showAreaPicker(BuildContext context) {
  final app = context.read<AppState>();
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
              Text(app.t('changeArea'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              // detect the area instead of picking it by hand
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _useMyLocation(context);
                },
                icon: const Icon(Icons.near_me_rounded, size: 17),
                label: Text(app.t('useMyLocationShort')),
                style: TextButton.styleFrom(
                    foregroundColor: Yozi.violetDeep,
                    backgroundColor: Yozi.violetSoft,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: List.generate(kAreas.length, (i) {
                  final on = app.areaIndex == i;
                  return YaziChip(
                    label: kAreas[i].name(app.lang),
                    selected: on,
                    onTap: () {
                      app.setArea(i);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ),
            ]),
      ),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final repo = context.watch<DataRepo>();
    final weekendEvents = kEvents.where((e) => e.thisWeek).toList();
    final upcomingEvents = weekendEvents.isNotEmpty ? weekendEvents : kEvents.take(6).toList();
    final sponsored = kBusinesses
        .where((b) => b.sponsored && b.area == app.areaIndex)
        .toList();
    final season = repo.remoteMap('season_banner');
    final seasonOn = season.isEmpty || season['enabled'] != false;
    final seasonCat = (season['cat'] ?? 'schools').toString();
    final seasonImg = absUrl(season['image']?.toString());
    final seasonEmoji = (season['emoji'] ?? '🏫').toString();

    return RefreshIndicator(
      color: Yozi.violet,
      onRefresh: () => repo.refresh(),
      child: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      // ---- gradient hero: header + greeting (light pink -> light blue) ----
      Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/header.jpg'),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          bottom: false,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                Image.asset('assets/logo.png', width: 30, height: 30),
                const SizedBox(width: 7),
                const Text('YAZI',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const Spacer(),
                Material(
                  color: Colors.white,
                  shape:
                      const StadiumBorder(side: BorderSide(color: Yozi.line)),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: () => showAreaPicker(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.place_rounded,
                            size: 14, color: Yozi.violet),
                        const SizedBox(width: 4),
                        Text(kAreas[app.areaIndex].name(app.lang),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700)),
                        const Icon(Icons.expand_more_rounded,
                            size: 16, color: Yozi.muted),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const _BellButton(),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${repo.remoteText('greeting', app.lang, app.t('hello'))} 💗',
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text.rich(TextSpan(children: [
                        TextSpan(
                            text: app.t('helloSubPre'),
                            style: const TextStyle(
                                color: Yozi.ink2, fontSize: 14.5)),
                        TextSpan(
                            text: app.t('littleOnes'),
                            style: const TextStyle(
                                color: Yozi.coral,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800)),
                      ])),
                    ]),
              ),
            ),
            const SizedBox(height: 18),
          ]),
        ),
      ),
      // ---- search ----
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Material(
          color: Yozi.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SearchScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                  border: Border.all(color: Yozi.line),
                  borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                const Icon(Icons.search_rounded, size: 20, color: Yozi.muted),
                const SizedBox(width: 10),
                Text(app.t('searchPh'),
                    style: const TextStyle(color: Yozi.faint, fontSize: 14.5)),
                const Spacer(),
                const Icon(Icons.tune_rounded, size: 18, color: Yozi.violet),
              ]),
            ),
          ),
        ),
      ),
      // ---- quick chips ----
      SizedBox(
        height: 52,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          children: [
            _QuickChip(
                icon: Icons.near_me_rounded,
                label: app.t('nearMe'),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ResultsScreen()))),
            _QuickChip(
                icon: Icons.event_rounded,
                label: app.t('weekendPlanT'),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const WeekendPlanScreen()))),
            _QuickChip(
                icon: Icons.local_activity_rounded,
                label: app.t('hasOffer'),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const OffersScreen()))),
          ],
        ),
      ),
      // ---- categories (3D emoji icons) ----
      SectionRow(app.t('categories'), action: app.t('seeAll'),
          onAction: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const CategoriesScreen()))),
      GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: .8,
        children: browseCats(home: true)
            .map((c) => Material(
                  color: Yozi.surface,
                  borderRadius: BorderRadius.circular(Yozi.rMd),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Yozi.rMd),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ResultsScreen(catId: c.id))),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Yozi.line),
                          borderRadius: BorderRadius.circular(Yozi.rMd)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CategoryIcon(c, size: 54),
                            ),
                            const SizedBox(height: 6),
                            // roomy label so tall glyphs never clip on Android
                            SizedBox(
                              height: 18,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(c.name(app.lang),
                                    maxLines: 1,
                                    style: const TextStyle(
                                        fontSize: 11.5,
                                        height: 1.3,
                                        fontWeight: FontWeight.w700,
                                        color: Yozi.ink2)),
                              ),
                            ),
                          ]),
                    ),
                  ),
                ))
            .toList(),
      ),
      // ---- Season banner (title / subtitle / target category / image all
      //      come from the admin panel → Season banner) ----
      if (seasonOn)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Material(
            borderRadius: BorderRadius.circular(Yozi.rLg),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ResultsScreen(catId: seasonCat))),
              child: Ink(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFFFDF3E0), Color(0xFFE6DCFB)])),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(app.t('seasonK').toUpperCase(),
                                style: const TextStyle(
                                    color: Yozi.violetDeep,
                                    fontSize: 11,
                                    letterSpacing: 1.4,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(
                                repo.remoteText('season_banner',
                                    'title_${app.lang}', app.t('seasonT')),
                                style: const TextStyle(
                                    color: Yozi.ink,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(
                                repo.remoteText('season_banner',
                                    'sub_${app.lang}', app.t('seasonP')),
                                style: const TextStyle(
                                    color: Yozi.ink2, fontSize: 12.5)),
                          ]),
                    ),
                    const SizedBox(width: 10),
                    if (seasonImg != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(seasonImg,
                            width: 64, height: 64, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Text(seasonEmoji,
                                style: const TextStyle(fontSize: 44))),
                      )
                    else
                      Text(seasonEmoji, style: const TextStyle(fontSize: 44)),
                  ]),
                ),
              ),
            ),
          ),
        ),
      // ---- events carousel (hidden when there are none) ----
      if (upcomingEvents.isNotEmpty) ...[
        SectionRow(app.t('weekend'), action: app.t('viewAll'),
            onAction: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const WeekendPlanScreen()))),
        SizedBox(
          height: 236,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: upcomingEvents.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => EventCard(upcomingEvents[i]),
          ),
        ),
      ],
      // ---- offers (hidden when there are none) ----
      if (kOffers.isNotEmpty) ...[
        SectionRow(app.t('offersNear'), action: app.t('viewAll'),
            onAction: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OffersScreen()))),
        ...kOffers.take(2).map((o) => OfferCard(o)),
      ],
      // ---- sponsored & new entities (admin → Sponsors & New) ----
      if (kFeatured.isNotEmpty || sponsored.isNotEmpty) ...[
        SectionRow(app.t('sponsoredNew')),
        if (kFeatured.isNotEmpty)
          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: kFeatured.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => _FeaturedCard(kFeatured[i]),
            ),
          ),
        if (kFeatured.isNotEmpty) const SizedBox(height: 10),
        ...sponsored.take(3).map((b) => BizCard(b)),
      ],
      // ---- premium strip ----
      if (!app.premium)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Material(
            color: Yozi.goldWash,
            borderRadius: BorderRadius.circular(Yozi.rMd),
            child: InkWell(
              borderRadius: BorderRadius.circular(Yozi.rMd),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PremiumScreen())),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(children: [
                  Image.asset('assets/icons3d/crown.png',
                      width: 30, height: 30),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('YAZI Premium',
                              style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800)),
                          Text(app.t('premiumStrip'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11, color: Yozi.ink2)),
                        ]),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 8),
                    decoration: BoxDecoration(
                        color: Yozi.amberBright,
                        borderRadius: BorderRadius.circular(999)),
                    child: Text(app.t('goPremium'),
                        style: const TextStyle(
                            color: Color(0xFF5B3A00),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800)),
                  ),
                ]),
              ),
            ),
          ),
        ),
      Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Center(
            child: Text('${app.t('protoNote')} · v$kAppVersion',
                style: const TextStyle(fontSize: 11, color: Yozi.faint))),
      ),
    ]),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap, this.dot = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: Yozi.line)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Stack(alignment: Alignment.center, children: [
            Icon(icon, size: 20, color: Yozi.ink2),
            if (dot)
              Positioned(
                  top: 9,
                  right: 10,
                  child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: Yozi.coral,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 1.5)))),
          ]),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({this.icon, required this.label, required this.onTap});
  final IconData? icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Center(child: YaziChip(icon: icon, label: label, onTap: onTap)),
    );
  }
}

/// Tiny ChangeNotifier the shell exposes so children can switch tabs.
class ShellIndex extends ChangeNotifier {
  int value = 0;
  void set(int v) {
    value = v;
    notifyListeners();
  }
}


/// Real GPS: detect position, snap to the nearest area, update the app.
Future<void> _useMyLocation(BuildContext context) async {
  final app = context.read<AppState>();
  showToast(context, '📍 ${app.t('locating')}');
  try {
    final res = await detectNearestArea();
    if (!context.mounted) return;
    if (res.off) {
      showToast(context, app.t('locationOff'));
      showAreaPicker(context);
    } else if (res.denied) {
      showToast(context, app.t('locationDenied'));
      showAreaPicker(context);
    } else if (res.areaIndex != null) {
      app.setArea(res.areaIndex!);
      showToast(context,
          '📍 ${app.t('locationSet')}: ${kAreas[res.areaIndex!].name(app.lang)}');
    }
  } catch (_) {
    if (!context.mounted) return;
    showToast(context, app.t('locationOff'));
    showAreaPicker(context);
  }
}


/// Card in the Home "Sponsored & New" strip.
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard(this.f);
  final Featured f;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final biz = f.bizId != null ? bizByIdOrNull(f.bizId!) : null;
    final img = f.image ?? biz?.logo ?? biz?.photoUrl(width: 300);
    return SizedBox(
      width: 250,
      child: Material(
        color: Yozi.surface,
        borderRadius: BorderRadius.circular(Yozi.rMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(Yozi.rMd),
          onTap: () {
            if (biz != null) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => BusinessScreen(bizId: biz.id)));
            } else if (f.link != null) {
              openUrl(context, f.link!);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: Yozi.line),
                borderRadius: BorderRadius.circular(Yozi.rMd)),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 78,
                  height: 78,
                  child: img != null
                      ? Image.network(img,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => GradThumb(
                              grad: biz?.grad ?? 'violet',
                              icon: Icons.star_rounded))
                      : GradThumb(
                          grad: biz?.grad ?? 'violet',
                          icon: Icons.star_rounded),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BadgePill(
                          (f.isNew ? app.t('newBadge') : app.t('sponsored'))
                              .toUpperCase(),
                          bg: f.isNew ? Yozi.mintWash : Yozi.coralWash,
                          fg: f.isNew ? Yozi.mintDeep : Yozi.coral),
                      const SizedBox(height: 5),
                      Text(f.title(app.lang),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.25,
                              fontWeight: FontWeight.w800)),
                      if (f.sub(app.lang).isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(f.sub(app.lang),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11.5, color: Yozi.muted)),
                      ],
                    ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet listing "admissions open" alerts for subscribed schools.
Future<void> showAdmissionAlerts(BuildContext context) async {
  final app = context.read<AppState>();
  final repo = context.read<DataRepo>();
  showToast(context, '🔔 ${app.t('alertsTitle')}…');
  final alerts = await repo.admissionAlerts(app.deviceId);
  if (!context.mounted) return;
  app.markAlertsSeen(alerts.map((a) => a.id.toString()));
  showModalBottomSheet(
    context: context,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(app.t('alertsTitle'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              if (alerts.isEmpty)
                Text(app.t('noAlerts'),
                    style: const TextStyle(color: Yozi.muted, fontSize: 13.5))
              else
                ...alerts.take(8).map((a) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.school_rounded,
                          color: Yozi.violet),
                      title: Text(a.name(app.lang),
                          style:
                              const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text(
                          '${app.t('admissionsNowOpen')}${a.intake != null ? ' · ${a.intake}' : ''}'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => BusinessScreen(bizId: a.bizId)));
                      },
                    )),
            ]),
      ),
    ),
  );
}


/// Bell with a red dot while there are unseen "admissions open" alerts.
class _BellButton extends StatefulWidget {
  const _BellButton();
  @override
  State<_BellButton> createState() => _BellButtonState();
}

class _BellButtonState extends State<_BellButton> {
  bool _unseen = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final app = context.read<AppState>();
    if (app.admissionSubs.isEmpty) return;
    final alerts = await context.read<DataRepo>().admissionAlerts(app.deviceId);
    if (!mounted) return;
    setState(() => _unseen =
        alerts.any((a) => !app.seenAlerts.contains(a.id.toString())));
  }

  @override
  Widget build(BuildContext context) {
    return _CircleBtn(
        icon: Icons.notifications_none_rounded,
        dot: _unseen,
        onTap: () async {
          await showAdmissionAlerts(context);
          if (mounted) setState(() => _unseen = false);
        });
  }
}
