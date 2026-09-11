import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/state.dart';
import '../core/theme.dart';
import '../data/mock.dart';
import '../screens/business.dart';
import '../screens/events.dart';

/// Opens a URL (web / tel / mailto / whatsapp) outside the app.
Future<void> openUrl(BuildContext context, String url) async {
  final app = context.read<AppState>();
  final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)
      .then((v) => v, onError: (_) => false);
  if (!ok && context.mounted) showToast(context, app.t('opening'));
}

void showToast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded,
            color: Color(0xFF7EE2B8), size: 19),
        const SizedBox(width: 9),
        Expanded(child: Text(msg)),
      ]),
      duration: const Duration(milliseconds: 2200),
    ));
}

/// Clip-proof pill chip — Material Chip clips tall Arabic glyphs, this doesn't.
class YaziChip extends StatelessWidget {
  const YaziChip(
      {super.key,
      this.icon,
      required this.label,
      this.selected = false,
      required this.onTap});
  final IconData? icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Yozi.violet : Yozi.surface,
      shape: StadiumBorder(
          side: BorderSide(color: selected ? Yozi.violet : Yozi.line)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 15, color: selected ? Colors.white : Yozi.ink2),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : Yozi.ink2)),
          ]),
        ),
      ),
    );
  }
}

class SectionRow extends StatelessWidget {
  const SectionRow(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
      child: Row(children: [
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800))),
        if (action != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text(action!,
                  style: const TextStyle(
                      color: Yozi.violet,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800)),
            ),
          ),
      ]),
    );
  }
}

/// Gradient photo placeholder used everywhere instead of network images.
class GradThumb extends StatelessWidget {
  const GradThumb(
      {super.key,
      required this.grad,
      required this.icon,
      this.size = 34,
      this.radius = Yozi.rMd});
  final String grad;
  final IconData icon;
  final double size, radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          gradient: Yozi.grad(grad),
          borderRadius: BorderRadius.circular(radius)),
      child: Center(
          child:
              Icon(icon, size: size, color: Colors.white.withValues(alpha: .9))),
    );
  }
}

/// Real Google place photo with the gradient thumb as fallback while loading,
/// on error, or when the place has no photo at all.
class PlacePhoto extends StatelessWidget {
  const PlacePhoto(this.biz,
      {super.key, this.width = 400, this.radius = Yozi.rMd, this.iconSize = 34});
  final Business biz;
  final int width;
  final double radius, iconSize;

  @override
  Widget build(BuildContext context) {
    final fallback = GradThumb(
        grad: biz.grad,
        icon: catById(biz.cat).icon,
        size: iconSize,
        radius: radius);
    final url = biz.photoUrl(width: width);
    if (url == null) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => fallback,
        loadingBuilder: (ctx, child, progress) =>
            progress == null ? child : fallback,
      ),
    );
  }
}

class BadgePill extends StatelessWidget {
  const BadgePill(this.text, {super.key, required this.bg, required this.fg});
  final String text;
  final Color bg, fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text,
          style: TextStyle(
              color: fg,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: .4)),
    );
  }
}

class HeartButton extends StatelessWidget {
  const HeartButton({super.key, required this.id, this.isEvent = false});
  final String id;
  final bool isEvent;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final on = isEvent ? app.isEventSaved(id) : app.isSaved(id);
    return Material(
      color: Colors.white.withValues(alpha: .92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          final added =
              isEvent ? app.toggleEvent(id) : app.toggleBiz(id);
          showToast(context, added ? app.t('savedToast') : app.t('unsavedToast'));
        },
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(on ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 17, color: on ? Yozi.coral : Yozi.ink2),
        ),
      ),
    );
  }
}

class RatingRow extends StatelessWidget {
  const RatingRow(this.rating, {super.key, this.count});
  final double rating;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      ...List.generate(
          5,
          (i) => Icon(Icons.star_rounded,
              size: 14,
              color: i < rating.round()
                  ? Yozi.amberBright
                  : Yozi.amberBright.withValues(alpha: .25))),
      const SizedBox(width: 4),
      Text('$rating',
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
      if (count != null) ...[
        const SizedBox(width: 3),
        Text('($count)',
            style: const TextStyle(
                fontSize: 12, color: Yozi.muted, fontWeight: FontWeight.w600)),
      ],
    ]);
  }
}

/// Horizontal business result card.
class BizCard extends StatelessWidget {
  const BizCard(this.biz, {super.key});
  final Business biz;

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
              builder: (_) => BusinessScreen(bizId: biz.id))),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: Yozi.line),
                borderRadius: BorderRadius.circular(Yozi.rMd)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: 92,
                height: 92,
                child: Stack(children: [
                  Positioned.fill(child: PlacePhoto(biz, width: 200)),
                  if (biz.sponsored)
                    Positioned(
                        top: 6,
                        left: 6,
                        child: BadgePill(app.t('sponsored').toUpperCase(),
                            bg: Yozi.coralWash, fg: Yozi.coral))
                  else if (biz.offer)
                    Positioned(
                        top: 6,
                        left: 6,
                        child: BadgePill(app.t('hasOffer').toUpperCase(),
                            bg: Yozi.amberWash, fg: Yozi.amber)),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(
                            child: Text(biz.name(app.lang),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14.5,
                                    height: 1.25,
                                    fontWeight: FontWeight.w800))),
                        if (biz.verified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded,
                              size: 15, color: Yozi.sky),
                        ],
                      ]),
                      const SizedBox(height: 3),
                      RatingRow(biz.rating, count: biz.reviews),
                      const SizedBox(height: 3),
                      Row(children: [
                        const Icon(Icons.place_rounded,
                            size: 12, color: Yozi.muted),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                              '${kAreas[biz.area].name(app.lang)}'
                              '${biz.drive > 0 ? ' · ${biz.drive} ${app.t('min')} 🚗' : ''}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, color: Yozi.muted)),
                        ),
                      ]),
                      const SizedBox(height: 4),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(biz.price(app.lang),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: Yozi.mintDeep)),
                            ),
                            if (biz.hasHours)
                              Text(
                                  biz.isOpenNow
                                      ? app.t('openLbl')
                                      : app.t('closedLbl'),
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: biz.isOpenNow
                                          ? Yozi.mintDeep
                                          : Yozi.coral)),
                          ]),
                    ]),
              ),
              HeartButton(id: biz.id),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Vertical event card for horizontal carousels.
class EventCard extends StatelessWidget {
  const EventCard(this.event, {super.key});
  final KidsEvent event;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return SizedBox(
      width: 200,
      child: Material(
        color: Yozi.surface,
        borderRadius: BorderRadius.circular(Yozi.rMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(Yozi.rMd),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => EventScreen(eventId: event.id))),
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Yozi.line),
                borderRadius: BorderRadius.circular(Yozi.rMd)),
            clipBehavior: Clip.antiAlias,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 96,
                width: double.infinity,
                child: Stack(children: [
                  Positioned.fill(
                      child: GradThumb(
                          grad: event.grad,
                          icon: Icons.event_rounded,
                          radius: 0)),
                  if (event.price == 0)
                    Positioned(
                        top: 6,
                        left: 6,
                        child: BadgePill(app.t('freeTab').toUpperCase(),
                            bg: Yozi.mintWash, fg: Yozi.mintDeep)),
                  Positioned(
                      top: 6, right: 6, child: HeartButton(id: event.id, isEvent: true)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.name(app.lang),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13,
                              height: 1.3,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('${event.date(app.lang)} · ${event.time(app.lang)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11.5, height: 1.25, color: Yozi.muted)),
                      const SizedBox(height: 2),
                      Text(
                          '${kAreas[event.area].name(app.lang)} · ${app.t('ages')} ${event.ages}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11.5, height: 1.25, color: Yozi.muted)),
                      const SizedBox(height: 4),
                      Text(
                          event.price == 0
                              ? app.t('freeEntry')
                              : (app.isArabic
                                  ? '${event.price} ج.م'
                                  : 'EGP ${event.price}'),
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: event.price == 0
                                  ? Yozi.mintDeep
                                  : Yozi.amber)),
                    ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}


/// Category artwork: admin-uploaded icon → bundled 3D PNG → emoji.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon(this.cat, {super.key, this.size = 54});
  final Category cat;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget emoji() => Container(
        width: size,
        height: size,
        color: cat.wash,
        child: Center(
            child: Text(cat.emoji, style: TextStyle(fontSize: size * .48))));
    Widget bundled() => Image.asset('assets/icons3d/${cat.id}.png',
        width: size, height: size, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => emoji());
    if (cat.iconUrl != null) {
      return Image.network(cat.iconUrl!,
          width: size, height: size, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => bundled());
    }
    return bundled();
  }
}

/// Subcategory artwork: admin-uploaded icon → bundled 3D PNG → material icon.
class SubcatIcon extends StatelessWidget {
  const SubcatIcon(this.catId, this.sub,
      {super.key, this.size = 46, this.iconSize = 30, this.color = Yozi.violet});
  final String catId;
  final Subcat sub;
  final double size, iconSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget fallback() =>
        Icon(sub.icon ?? Icons.auto_awesome_rounded, size: iconSize, color: color);
    Widget bundled() => sub.asset != null
        ? Image.asset('assets/icons3d/${sub.asset}.png',
            width: size, height: size, fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => fallback())
        : fallback();
    final url = subcatIconUrl(catId, sub.id);
    if (url != null) {
      return Image.network(url,
          width: size, height: size, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => bundled());
    }
    return bundled();
  }
}
