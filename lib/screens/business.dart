import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state.dart';
import '../core/theme.dart';
import '../data/api.dart';
import '../data/mock.dart';
import '../widgets/common.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key, required this.bizId});
  final String bizId;

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  int _page = 0;
  bool _busy = false;

  /// Toggle the "notify me when admissions open" subscription.
  Future<void> _toggleNotify(Business biz) async {
    final app = context.read<AppState>();
    final repo = context.read<DataRepo>();
    final on = !app.isSubscribed(biz.id);
    setState(() => _busy = true);
    final ok = await repo.setAdmissionAlert(app.deviceId, biz.id, on, lang: app.lang);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      showToast(context, app.t('notifyFailed'));
      return;
    }
    app.setSubscribed(biz.id, on);
    showToast(context, on ? '🔔 ${app.t('notifyOn')}' : app.t('notifyOff'));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final bizId = widget.bizId;
    final biz = bizByIdOrNull(bizId);
    if (biz == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(app.t('noResults'))));
    }
    final offers = kOffers.where((o) => o.bizId == biz.id).toList();
    final reviews = kReviews[biz.id] ?? const <Review>[];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(slivers: [
          SliverAppBar(
            pinned: true,
            leading: const BackButton(),
            title: Text(biz.name(app.lang),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: Center(child: HeartButton(id: biz.id)),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // gallery
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 210,
                  width: double.infinity,
                  child: Stack(children: [
                    Positioned.fill(
                      child: biz.galleryUrls().length > 1
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(Yozi.rLg),
                              child: PageView(
                                onPageChanged: (i) =>
                                    setState(() => _page = i),
                                children: biz
                                    .galleryUrls()
                                    .map((u) => Image.network(u,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            GradThumb(
                                                grad: biz.grad,
                                                icon: catById(biz.cat).icon,
                                                size: 64,
                                                radius: Yozi.rLg)))
                                    .toList(),
                              ),
                            )
                          : PlacePhoto(biz,
                              width: 800, radius: Yozi.rLg, iconSize: 64),
                    ),
                    if (biz.sponsored)
                      Positioned(
                          top: 10,
                          left: 10,
                          child: BadgePill(app.t('sponsored').toUpperCase(),
                              bg: Yozi.coralWash, fg: Yozi.coral)),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                              biz.galleryUrls().length.clamp(1, 8),
                              (i) => Container(
                                    width: i == _page ? 16 : 6,
                                    height: 6,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 2.5),
                                    decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                            alpha: i == _page ? 1 : .5),
                                        borderRadius:
                                            BorderRadius.circular(4)),
                                  ))),
                    ),
                  ]),
                ),
              ),
              // header info
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(
                            child: Text(biz.name(app.lang),
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800))),
                        if (biz.verified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded,
                              size: 19, color: Yozi.sky),
                        ],
                      ]),
                      const SizedBox(height: 6),
                      RatingRow(biz.rating, count: biz.reviews),
                      const SizedBox(height: 6),
                      Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            const Icon(Icons.place_rounded,
                                size: 14, color: Yozi.muted),
                            Text(kAreas[biz.area].name(app.lang),
                                style: const TextStyle(
                                    fontSize: 13, color: Yozi.muted)),
                            if (biz.drive > 0) ...[
                              const Text('·',
                                  style: TextStyle(color: Yozi.muted)),
                              const Icon(Icons.directions_car_rounded,
                                  size: 14, color: Yozi.muted),
                              Text(
                                  '${biz.drive} ${app.t('min')} ${app.t('drive')}',
                                  style: const TextStyle(
                                      fontSize: 13, color: Yozi.muted)),
                            ],
                            if (biz.hasHours) ...[
                              const Text('·', style: TextStyle(color: Yozi.muted)),
                              Text(biz.isOpenNow ? app.t('openLbl') : app.t('closedLbl'),
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: biz.isOpenNow
                                          ? Yozi.mintDeep
                                          : Yozi.coral)),
                            ],
                          ]),
                      const SizedBox(height: 4),
                      Text.rich(TextSpan(children: [
                        TextSpan(
                            text: '${app.t('ages')}: ',
                            style: const TextStyle(
                                fontSize: 13, color: Yozi.muted)),
                        TextSpan(
                            text: biz.ages,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w800)),
                      ])),
                    ]),
              ),
              // actions — call / whatsapp / directions / facebook / instagram
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(children: [
                  _Action(
                      icon: Icons.call_rounded,
                      label: app.t('call'),
                      onTap: () => _phone(biz) == null
                          ? showToast(context, '📞 ${app.t('calling')}')
                          : openUrl(context, 'tel:${_phone(biz)}')),
                  _Action(
                      icon: Icons.chat_rounded,
                      label: '',
                      tooltip: app.t('whatsapp'),
                      color: Yozi.mint,
                      onTap: () => _phone(biz) == null
                          ? showToast(context, app.t('reqSent'))
                          : openUrl(context,
                              'https://wa.me/${_intl(_phone(biz)!)}')),
                  _Action(
                      icon: Icons.near_me_rounded,
                      label: app.t('directions'),
                      onTap: () => openUrl(
                          context,
                          biz.lat != null
                              ? 'https://www.google.com/maps/search/?api=1&query=${biz.lat},${biz.lng}'
                              : 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(biz.nameEn)}')),
                  _Action(
                      icon: Icons.facebook_rounded,
                      label: '',
                      tooltip: app.t('facebook'),
                      color: const Color(0xFF1877F2),
                      onTap: () => openUrl(
                          context,
                          biz.facebook?.isNotEmpty == true
                              ? biz.facebook!
                              : 'https://www.facebook.com/search/top?q=${Uri.encodeComponent(biz.nameEn)}')),
                  _Action(
                      icon: Icons.camera_alt_rounded,
                      label: '',
                      tooltip: app.t('instagram'),
                      color: const Color(0xFFE1306C),
                      onTap: () => openUrl(
                          context,
                          biz.instagram?.isNotEmpty == true
                              ? biz.instagram!
                              : 'https://www.instagram.com/explore/search/keyword/?q=${Uri.encodeComponent(biz.nameEn)}')),
                ]),
              ),
              // school admissions: notify-me + application link
              if (biz.cat == 'schools') _AdmissionsBlock(
                  biz: biz, busy: _busy, onNotify: () => _toggleNotify(biz)),
              if (biz.about(app.lang).isNotEmpty)
                _Block(title: app.t('about'),
                    child: Text(biz.about(app.lang),
                        style: const TextStyle(
                            fontSize: 13.5, height: 1.55, color: Yozi.ink2))),
              if (biz.prices.isNotEmpty)
                _Block(
                  title: app.t('prices'),
                  child: Column(
                      children: biz.prices
                          .map((p) => _kv(p.label(app.lang), p.value(app.lang),
                              valueColor: Yozi.mintDeep))
                          .toList()),
                ),
              if (offers.isNotEmpty) ...[
                SectionRow(app.t('offers')),
                ...offers.map((o) => Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: _InlineOffer(offer: o))),
              ],
              _Block(
                title: app.t('hours'),
                child: biz.hasHours
                    ? Column(
                        children: biz.hours.map((h) {
                          final i = h.indexOf(':');
                          final day = i > 0 ? h.substring(0, i) : h;
                          final val = i > 0 ? h.substring(i + 1).trim() : '';
                          return _kv(_dayLabel(day, app.lang), val,
                              valueColor: val.toLowerCase().contains('closed')
                                  ? Yozi.coral
                                  : null);
                        }).toList())
                    : Text(app.t('hoursUnknown'),
                        style: const TextStyle(color: Yozi.muted, fontSize: 13)),
              ),
              if (biz.amenities(app.lang).isNotEmpty)
              _Block(
                title: app.t('amenities'),
                child: Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: biz
                      .amenities(app.lang)
                      .map((a) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 11, vertical: 6),
                            decoration: BoxDecoration(
                                color: Yozi.violetGhost,
                                borderRadius: BorderRadius.circular(999)),
                            child: Text(a,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Yozi.violetDeep)),
                          ))
                      .toList(),
                ),
              ),
              if (reviews.isNotEmpty)
                _Block(
                  title: app.t('reviewsT'),
                  child: Column(
                      children: reviews
                          .map((r) => _ReviewTile(review: r, lang: app.lang))
                          .toList()),
                ),
              const SizedBox(height: 90),
            ]),
          ),
        ]),
      ),
    );
  }

  /// Cleaned phone number, or null when the business has none.
  String? _phone(Business biz) {
    final p = biz.phone?.replaceAll(RegExp(r'[^\d+]'), '');
    return (p == null || p.length < 7) ? null : p;
  }

  /// Egyptian local numbers -> international format for wa.me.
  String _intl(String p) =>
      p.startsWith('+') ? p.substring(1) : p.startsWith('0') ? '2$p' : p;

  Widget _kv(String k, String v, {Color? valueColor}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(children: [
          Expanded(
              child: Text(k,
                  style: const TextStyle(fontSize: 13.5, color: Yozi.muted))),
          Text(v,
              style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? Yozi.ink)),
        ]),
      );

}

class _Action extends StatelessWidget {
  const _Action(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color,
      this.tooltip});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  /// When [label] is empty the button shows the icon only. [tooltip] is then
  /// used for the accessibility label and the long-press tooltip.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Tooltip(
          message: tooltip ?? label,
          child: Semantics(
            button: true,
            label: tooltip ?? label,
            child: Material(
          color: Yozi.surface,
          borderRadius: BorderRadius.circular(Yozi.rSm),
          child: InkWell(
            borderRadius: BorderRadius.circular(Yozi.rSm),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                  border: Border.all(color: Yozi.line),
                  borderRadius: BorderRadius.circular(Yozi.rSm)),
              child: Column(children: [
                Icon(icon, size: label.isEmpty ? 22 : 19, color: color ?? Yozi.ink2),
                if (label.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(label,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 10.5,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                            color: color ?? Yozi.ink2)),
                  ),
                ],
              ]),
            ),
          ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Yozi.surface,
          border: Border.all(color: Yozi.line),
          borderRadius: BorderRadius.circular(Yozi.rMd)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review, required this.lang});
  final Review review;
  final String lang;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
              radius: 17,
              backgroundColor: review.color,
              child: Text(review.name(lang).characters.first,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800))),
          const SizedBox(width: 9),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(review.name(lang),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800)),
              Text(review.meta(lang),
                  style: const TextStyle(fontSize: 11, color: Yozi.muted)),
            ]),
          ),
          RatingRow(review.rating.toDouble()),
        ]),
        const SizedBox(height: 6),
        Text(review.text(lang),
            style: const TextStyle(
                fontSize: 13, height: 1.55, color: Yozi.ink2)),
      ]),
    );
  }
}

/// Inline offer row on the business page (locked if premium-only).
class _InlineOffer extends StatelessWidget {
  const _InlineOffer({required this.offer});
  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final locked = offer.premium && !app.premium;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Stack(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Yozi.surface,
              border: Border.all(color: Yozi.line),
              borderRadius: BorderRadius.circular(Yozi.rMd)),
          child: Row(children: [
            Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    gradient: Yozi.grad(offer.grad),
                    borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.local_activity_rounded,
                    color: Colors.white, size: 21)),
            const SizedBox(width: 11),
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
                    Text(offer.sub(app.lang),
                        style:
                            const TextStyle(fontSize: 11.5, color: Yozi.muted)),
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
                    const Icon(Icons.lock_rounded, size: 16, color: Yozi.gold),
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
    );
  }
}


const _dayAr = {
  'monday': 'الاثنين', 'tuesday': 'الثلاثاء', 'wednesday': 'الأربعاء',
  'thursday': 'الخميس', 'friday': 'الجمعة', 'saturday': 'السبت', 'sunday': 'الأحد',
};
String _dayLabel(String day, String lang) =>
    lang == 'ar' ? (_dayAr[day.toLowerCase()] ?? day) : day;

/// "Admissions" card on schools & nurseries: status, Notify me, Apply now.
class _AdmissionsBlock extends StatelessWidget {
  const _AdmissionsBlock(
      {required this.biz, required this.busy, required this.onNotify});
  final Business biz;
  final bool busy;
  final VoidCallback onNotify;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final subscribed = app.isSubscribed(biz.id);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFFDF3E0), Color(0xFFE6DCFB)]),
            borderRadius: BorderRadius.circular(Yozi.rLg)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.school_rounded, size: 18, color: Yozi.violetDeep),
            const SizedBox(width: 6),
            Text(app.t('admissions'),
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800)),
            const Spacer(),
            BadgePill(
                (biz.admissionsOpen
                        ? app.t('admissionsOpen')
                        : app.t('admissionsClosed'))
                    .toUpperCase(),
                bg: biz.admissionsOpen ? Yozi.mintWash : Colors.white,
                fg: biz.admissionsOpen ? Yozi.mintDeep : Yozi.muted),
          ]),
          if (biz.admissionsIntake != null) ...[
            const SizedBox(height: 4),
            Text(biz.admissionsIntake!,
                style: const TextStyle(fontSize: 12.5, color: Yozi.ink2)),
          ],
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: busy ? null : onNotify,
                icon: Icon(subscribed
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded, size: 18),
                label: Text(subscribed ? app.t('notifyOn') : app.t('notifyMe'),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12.5)),
                style: FilledButton.styleFrom(
                    backgroundColor:
                        subscribed ? Yozi.mintWash : Colors.white,
                    foregroundColor:
                        subscribed ? Yozi.mintDeep : Yozi.violetDeep,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 12)),
              ),
            ),
            if (biz.applicationUrl != null) ...[
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => openUrl(context, biz.applicationUrl!),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: Text(app.t('applyNow'),
                      style: const TextStyle(fontSize: 12.5)),
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 12)),
                ),
              ),
            ],
          ]),
        ]),
      ),
    );
  }
}
