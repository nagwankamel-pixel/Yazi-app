import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state.dart';
import '../core/theme.dart';
import '../data/mock.dart';
import '../widgets/common.dart';
import 'premium.dart';

/// Offer list card — tapping opens redeem sheet, or the paywall when locked.
class OfferCard extends StatelessWidget {
  const OfferCard(this.offer, {super.key});
  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final biz = bizByIdOrNull(offer.bizId);
    final bizName = biz?.name(app.lang) ?? '';
    final locked = offer.premium && !app.premium;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Material(
        color: Yozi.surface,
        borderRadius: BorderRadius.circular(Yozi.rMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(Yozi.rMd),
          onTap: () {
            if (locked) {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PremiumScreen()));
            } else {
              showRedeemSheet(context, offer);
            }
          },
          child: Stack(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  border: Border.all(color: Yozi.line),
                  borderRadius: BorderRadius.circular(Yozi.rMd)),
              child: Row(children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        gradient: Yozi.grad(offer.grad),
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.all(9),
                    child: Image.asset('assets/icons3d/ticket.png',
                        fit: BoxFit.contain)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(offer.title(app.lang),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13.5,
                                height: 1.3,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text([bizName, offer.sub(app.lang)].where((x) => x.isNotEmpty).join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: Yozi.muted)),
                        const SizedBox(height: 4),
                        Row(children: [
                          if (offer.premium)
                            const Icon(Icons.workspace_premium_rounded,
                                size: 12, color: Yozi.gold),
                          if (offer.premium) const SizedBox(width: 3),
                          Text(
                              offer.premium
                                  ? app.t('premiumOnly')
                                  : offer.exp(app.lang),
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: offer.premium
                                      ? Yozi.gold
                                      : Yozi.coral)),
                        ]),
                      ]),
                ),
              ]),
            ),
            if (locked)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Yozi.rMd),
                  child: ColoredBox(
                    color: Yozi.ground.withValues(alpha: .72),
                    child: Center(
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.lock_rounded,
                            size: 16, color: Yozi.gold),
                        const SizedBox(width: 7),
                        Text(app.t('unlockPremium'),
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Yozi.gold)),
                      ]),
                    ),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

void showRedeemSheet(BuildContext context, Offer offer) {
  final app = context.read<AppState>();
  final biz = bizByIdOrNull(offer.bizId);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
              Text(offer.title(app.lang),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text([if (biz != null) biz.name(app.lang), offer.sub(app.lang)]
                      .where((x) => x.isNotEmpty).join(' · '),
                  style: const TextStyle(color: Yozi.muted, fontSize: 13)),
              const SizedBox(height: 16),
              // mock QR
              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: Yozi.cardShadow),
                  child: CustomPaint(painter: _QrPainter()),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text('YAZI-${offer.id.toUpperCase()}-2026',
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3)),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(app.t('redeemed'),
                    style: const TextStyle(color: Yozi.muted, fontSize: 13)),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (offer.saveEgp > 0) {
                    app.addSavings(offer.saveEgp);
                    showToast(context,
                        '${app.t('youSaved')} ${app.t('egp')} ${offer.saveEgp}! ${app.t('total')}: ${app.t('egp')} ${app.wallet}');
                  } else {
                    showToast(context, app.t('savedToast'));
                  }
                },
                icon: const Icon(Icons.check_rounded, size: 19),
                label: Text(app.t('redeem')),
              ),
            ]),
      ),
    ),
  );
}

/// Simple deterministic pseudo-QR pattern.
class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Yozi.ink;
    const n = 12;
    final cell = size.width / n;
    var seed = 42;
    int rnd() => seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        final corner = (x < 3 && y < 3) ||
            (x >= n - 3 && y < 3) ||
            (x < 3 && y >= n - 3);
        if (corner
            ? (x % 2 == 0 || y % 2 == 0)
            : rnd() % 5 < 2) {
          canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromLTWH(x * cell + 1, y * cell + 1, cell - 2, cell - 2),
                  const Radius.circular(2)),
              paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Wallet header used on the offers screen and profile.
class WalletHero extends StatelessWidget {
  const WalletHero({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Material(
        borderRadius: BorderRadius.circular(Yozi.rLg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
              Color(0xFF047857),
              Color(0xFF0E9F6E),
              Color(0xFF34D399)
            ])),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.account_balance_wallet_rounded,
                          color: Colors.white, size: 17),
                      const SizedBox(width: 8),
                      Text(app.t('wallet'),
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: .9),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800)),
                    ]),
                    const SizedBox(height: 4),
                    Text('${app.t('egp')} ${app.wallet}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.5)),
                    Text(app.t('walletSaved'),
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: .85),
                            fontSize: 12)),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------- Offers screen ----------
class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: Text(app.t('offers'))),
      body: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
        const WalletHero(),
        SectionRow(app.t('offersNear')),
        ...kOffers.map((o) => OfferCard(o)),
      ]),
    );
  }
}
