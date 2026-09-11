import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/location.dart';
import '../core/state.dart';
import '../core/theme.dart';
import '../data/mock.dart';
import '../widgets/common.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _step = 0;

  void _next() {
    if (_step < 2) {
      _page.nextPage(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic);
    }
  }

  void _finish(AppState app, {bool clearChildren = false}) {
    if (clearChildren) app.children.clear();
    app.completeOnboarding();
    showToast(context, app.t('notifToast'));
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _page,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (i) => setState(() => _step = i),
          children: [_langStep(app), _areaStep(app), _kidsStep(app)],
        ),
      ),
    );
  }

  Widget _pad(List<Widget> children) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));

  Widget _langStep(AppState app) {
    Widget card(String code, String label) {
      final on = app.lang == code;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: on ? Yozi.violetGhost : Yozi.surface,
          borderRadius: BorderRadius.circular(Yozi.rMd),
          child: InkWell(
            borderRadius: BorderRadius.circular(Yozi.rMd),
            onTap: () => app.setLang(code),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: on ? Yozi.violet : Yozi.line, width: 1.5),
                  borderRadius: BorderRadius.circular(Yozi.rMd)),
              child: Row(children: [
                Expanded(
                    child: Text(label,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800))),
                if (on)
                  const Icon(Icons.check_circle_rounded,
                      color: Yozi.violet, size: 22),
              ]),
            ),
          ),
        ),
      );
    }

    return _pad([
      Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Yozi.rLg),
          gradient: const LinearGradient(
              colors: [Color(0xFF5227B0), Color(0xFF7C4DE8), Color(0xFFC4B5FD)]),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/logo.png', width: 44, height: 44),
            ),
            const SizedBox(width: 10),
            const Text('YAZI',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1)),
          ]),
          const SizedBox(height: 4),
          Text('${app.t('onboardingT')} · ${app.t('onboardingSub')}',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: .85), fontSize: 13)),
        ]),
      ),
      const SizedBox(height: 26),
      Text('${app.t('chooseLang')} · Choose language',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 18),
      card('ar', 'العربية'),
      card('en', 'English'),
      const Spacer(),
      FilledButton(onPressed: _next, child: Text(app.t('cont'))),
    ]);
  }

  Widget _areaStep(AppState app) {
    return _pad([
      const Icon(Icons.place_rounded, color: Yozi.violet, size: 34),
      const SizedBox(height: 14),
      Text(app.t('chooseArea'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text(app.t('chooseAreaSub'),
          style: const TextStyle(color: Yozi.muted, fontSize: 14)),
      const SizedBox(height: 16),
      Wrap(
        spacing: 9,
        runSpacing: 9,
        children: List.generate(kAreas.length, (i) {
          final on = app.areaIndex == i;
          return YaziChip(
            label: kAreas[i].name(app.lang),
            selected: on,
            onTap: () => app.setArea(i),
          );
        }),
      ),
      const SizedBox(height: 12),
      TextButton.icon(
        onPressed: () async {
          showToast(context, '📍 ${app.t('locating')}');
          try {
            final res = await detectNearestArea();
            if (!mounted) return;
            if (res.areaIndex != null) {
              app.setArea(res.areaIndex!);
              showToast(context,
                  '📍 ${app.t('locationSet')}: ${kAreas[res.areaIndex!].name(app.lang)}');
            } else {
              showToast(context, app.t(res.off ? 'locationOff' : 'locationDenied'));
            }
          } catch (_) {
            if (mounted) showToast(context, app.t('locationOff'));
          }
        },
        icon: const Icon(Icons.near_me_rounded, size: 17),
        label: Text(app.t('useMyLocation')),
        style: TextButton.styleFrom(
            foregroundColor: Yozi.violetDeep,
            backgroundColor: Yozi.violetSoft,
            minimumSize: const Size.fromHeight(48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      const Spacer(),
      FilledButton(onPressed: _next, child: Text(app.t('cont'))),
    ]);
  }

  Widget _kidsStep(AppState app) {
    if (app.children.isEmpty) app.children.add(ChildProfile(age: 4));
    return _pad([
      const Icon(Icons.child_care_rounded, color: Yozi.violet, size: 34),
      const SizedBox(height: 14),
      Text(app.t('addKids'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text(app.t('addKidsSub'),
          style: const TextStyle(color: Yozi.muted, fontSize: 14)),
      const SizedBox(height: 16),
      Expanded(
        child: ListView(children: [
          ...List.generate(app.children.length, (i) {
            final c = app.children[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                  color: Yozi.surface,
                  border: Border.all(color: Yozi.line),
                  borderRadius: BorderRadius.circular(Yozi.rMd)),
              child: Row(children: [
                const Icon(Icons.child_care_rounded,
                    color: Yozi.violet, size: 22),
                const SizedBox(width: 12),
                Text('${app.t('child')} ${i + 1}',
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w800)),
                const Spacer(),
                IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => app.setChildAge(i, c.age - 1),
                    icon: const Icon(Icons.remove_circle_outline_rounded,
                        color: Yozi.violet)),
                SizedBox(
                    width: 54,
                    child: Text('${c.age} ${app.t('years')}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800))),
                IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => app.setChildAge(i, c.age + 1),
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        color: Yozi.violet)),
                IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: app.t('removeChild'),
                    onPressed: () => app.removeChild(i),
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Yozi.coral, size: 20)),
              ]),
            );
          }),
          TextButton.icon(
            onPressed: () => app.addChild(6),
            icon: const Icon(Icons.add_rounded),
            label: Text(app.t('addChild')),
            style: TextButton.styleFrom(
                foregroundColor: Yozi.violetDeep,
                backgroundColor: Yozi.violetSoft,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ]),
      ),
      const SizedBox(height: 10),
      FilledButton(
          onPressed: () => _finish(app), child: Text(app.t('startExploring'))),
      Center(
        child: TextButton(
          onPressed: () => _finish(app, clearChildren: true),
          child: Text(app.t('skip'),
              style: const TextStyle(
                  color: Yozi.muted, fontWeight: FontWeight.w700)),
        ),
      ),
    ]);
  }
}
