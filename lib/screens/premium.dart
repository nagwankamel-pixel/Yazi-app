import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state.dart';
import '../data/api.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _yearly = true;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final repo = context.watch<DataRepo>();
    final mo = repo.remoteNum('premium_price_monthly_egp', 99);
    final yr = repo.remoteNum('premium_price_yearly_egp', 999);
    return Scaffold(
      appBar: AppBar(title: Text(app.t('premium'))),
      body: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
        // crown hero
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            width: 110,
            height: 110,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                    center: Alignment(-.3, -.4),
                    colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)]),
                boxShadow: [
                  BoxShadow(
                      color: Yozi.amberBright.withValues(alpha: .55),
                      blurRadius: 50,
                      offset: const Offset(0, 20),
                      spreadRadius: -18)
                ]),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Image.asset('assets/icons3d/crown.png',
                  fit: BoxFit.contain),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 0),
          child: Column(children: [
            Text(app.t('premium'),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(app.t('premiumSub'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Yozi.muted, fontSize: 14)),
          ]),
        ),
        // headline perks — the reasons to subscribe
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: const [
              _Perk('b6', Icons.confirmation_number_rounded, Color(0xFF0E9F6E)),
              _Perk('b7', Icons.event_available_rounded, Color(0xFF0E7DC2)),
              _Perk('b8', Icons.card_giftcard_rounded, Color(0xFFDB2777)),
              _Perk('b9', Icons.auto_awesome_rounded, Color(0xFF8B3FD6)),
            ],
          ),
        ),
        SectionRow(app.t('perksTitle')),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: Yozi.surface,
              border: Border.all(color: Yozi.line),
              borderRadius: BorderRadius.circular(Yozi.rMd)),
          child: Column(
            children: ['b1', 'b2', 'b3', 'b4', 'b5']
                .map((k) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                size: 19, color: Yozi.mint),
                            const SizedBox(width: 11),
                            Expanded(
                                child: Text(app.t(k),
                                    style: const TextStyle(
                                        fontSize: 14, color: Yozi.ink2))),
                          ]),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        _plan(
            app: app,
            selected: !_yearly,
            name: app.t('monthly'),
            price: app.isArabic ? '$mo ج.م / شهر' : 'EGP $mo / month',
            onTap: () => setState(() => _yearly = false)),
        _plan(
            app: app,
            selected: _yearly,
            name: app.t('yearly'),
            price: app.isArabic ? '$yr ج.م / سنة' : 'EGP $yr / year',
            saveTag: app.t('save20'),
            onTap: () => setState(() => _yearly = true)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Column(children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Yozi.amberBright,
                foregroundColor: const Color(0xFF5B3A00),
              ),
              onPressed: app.premium
                  ? null
                  : () {
                      app.unlockPremium();
                      showToast(context, '${app.t('premiumOn')} 🎉');
                      Navigator.of(context).maybePop();
                    },
              icon: const Icon(Icons.workspace_premium_rounded, size: 19),
              label: Text(
                  app.premium ? app.t('alreadyPremium') : app.t('startTrial')),
            ),
            const SizedBox(height: 10),
            Text(app.t('trialNote'),
                style: const TextStyle(color: Yozi.muted, fontSize: 11.5)),
          ]),
        ),
      ]),
    );
  }

  Widget _plan(
      {required AppState app,
      required bool selected,
      required String name,
      required String price,
      String? saveTag,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Stack(clipBehavior: Clip.none, children: [
        Material(
          color: selected ? Yozi.amberWash : Yozi.surface,
          borderRadius: BorderRadius.circular(Yozi.rMd),
          child: InkWell(
            borderRadius: BorderRadius.circular(Yozi.rMd),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: selected ? Yozi.amberBright : Yozi.line,
                      width: 2),
                  borderRadius: BorderRadius.circular(Yozi.rMd)),
              child: Row(children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: selected ? Yozi.amberBright : Yozi.line,
                          width: 2)),
                  child: selected
                      ? Center(
                          child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                  color: Yozi.amberBright,
                                  shape: BoxShape.circle)))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                fontWeight: FontWeight.w800)),
                        Text(price,
                            style: const TextStyle(
                                fontSize: 13, height: 1.4, color: Yozi.muted)),
                      ]),
                ),
              ]),
            ),
          ),
        ),
        if (saveTag != null)
          PositionedDirectional(
            top: -9,
            end: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                  color: Yozi.coral,
                  borderRadius: BorderRadius.circular(999)),
              child: Text(saveTag,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800)),
            ),
          ),
      ]),
    );
  }
}

/// One highlighted subscriber perk (coupons, free sessions, gifts, Glow).
class _Perk extends StatelessWidget {
  const _Perk(this.textKey, this.icon, this.color);
  final String textKey;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
          color: Yozi.surface,
          border: Border.all(color: Yozi.line),
          borderRadius: BorderRadius.circular(Yozi.rMd)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: color),
            ),
            Text(app.t(textKey),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11.5, height: 1.3, fontWeight: FontWeight.w700)),
          ]),
    );
  }
}
