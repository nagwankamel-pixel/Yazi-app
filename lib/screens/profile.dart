import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/i18n.dart';
import '../core/state.dart';
import '../core/theme.dart';
import '../data/mock.dart';
import '../widgets/common.dart';
import 'home.dart';
import 'offers.dart';
import 'premium.dart';
import 'saved.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return SafeArea(
      bottom: false,
      child: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Text(app.t('profileT'),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        ),
        // user card — no personal name, the app has no accounts
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Yozi.surface,
              border: Border.all(color: Yozi.line),
              borderRadius: BorderRadius.circular(Yozi.rMd)),
          child: Row(children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      colors: [Color(0xFF7C4DE8), Color(0xFFA78BFA)])),
              child: const Center(
                  child: Text('💜', style: TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.t('hello'),
                        style: const TextStyle(
                            fontSize: 16.5, fontWeight: FontWeight.w800)),
                    Text(
                        '${kAreas[app.areaIndex].name(app.lang)}, ${app.isArabic ? 'القاهرة' : 'Cairo'}',
                        style: const TextStyle(
                            fontSize: 12.5, color: Yozi.muted)),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color:
                              app.premium ? Yozi.goldWash : Yozi.surface2,
                          borderRadius: BorderRadius.circular(999)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        if (app.premium)
                          const Icon(Icons.workspace_premium_rounded,
                              size: 11, color: Yozi.gold),
                        if (app.premium) const SizedBox(width: 3),
                        Text(
                            app.premium
                                ? app.t('premiumMember')
                                : app.t('memberSince'),
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color:
                                    app.premium ? Yozi.gold : Yozi.muted)),
                      ]),
                    ),
                  ]),
            ),
            IconButton(
              tooltip: app.t('settingsT'),
              onPressed: () => _openSettingsSheet(context),
              icon: const Icon(Icons.settings_rounded,
                  color: Yozi.muted, size: 20),
            ),
          ]),
        ),
        WalletHero(
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OffersScreen()))),
        // children — name + age, editable and removable
        SectionRow(app.t('myChildren'), action: '+ ${app.t('addChild')}',
            onAction: () => _openChildSheet(context)),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
              color: Yozi.surface,
              border: Border.all(color: Yozi.line),
              borderRadius: BorderRadius.circular(Yozi.rMd)),
          child: app.children.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(app.t('addKidsSub'),
                      style:
                          const TextStyle(color: Yozi.muted, fontSize: 13)),
                )
              : Column(
                  children: List.generate(app.children.length, (i) {
                    final c = app.children[i];
                    return InkWell(
                      onTap: () => _openChildSheet(context, index: i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(children: [
                          const Icon(Icons.child_care_rounded,
                              color: Yozi.violet, size: 19),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                                c.name.isNotEmpty
                                    ? c.name
                                    : '${app.t('child')} ${i + 1}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800)),
                          ),
                          Text('${c.age} ${app.t('years')}',
                              style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Yozi.ink2)),
                          const SizedBox(width: 2),
                          const Icon(Icons.edit_rounded,
                              color: Yozi.muted, size: 15),
                          IconButton(
                            tooltip: app.t('removeChild'),
                            onPressed: () {
                              app.removeChild(i);
                              showToast(context, app.t('childRemoved'));
                            },
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: Yozi.coral, size: 19),
                          ),
                        ]),
                      ),
                    );
                  }),
                ),
        ),
        // premium banner
        if (!app.premium)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Material(
              borderRadius: BorderRadius.circular(Yozi.rLg),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PremiumScreen())),
                child: Ink(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xFFB45309), Color(0xFFF59E0B)])),
                  child: Stack(children: [
                    PositionedDirectional(
                        end: -14,
                        bottom: -14,
                        child: Icon(Icons.workspace_premium_rounded,
                            size: 90,
                            color: Colors.white.withValues(alpha: .22))),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('YAZI Premium',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.6)),
                            const SizedBox(height: 5),
                            Text(app.t('startTrial'),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 3),
                            SizedBox(
                              width: 250,
                              child: Text(app.t('premiumSub'),
                                  style: TextStyle(
                                      color: Colors.white
                                          .withValues(alpha: .9),
                                      fontSize: 12.5)),
                            ),
                          ]),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        // menu
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          decoration: BoxDecoration(
              color: Yozi.surface,
              border: Border.all(color: Yozi.line),
              borderRadius: BorderRadius.circular(Yozi.rMd)),
          clipBehavior: Clip.antiAlias,
          child: Column(children: [
            _MenuItem(
                icon: Icons.favorite_rounded,
                label: app.t('saved'),
                iconBg: Yozi.coralWash,
                iconColor: Yozi.coral,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => Scaffold(
                        appBar: AppBar(title: Text(app.t('savedTitle'))),
                        body: const SavedScreen())))),
            _MenuItem(
                icon: Icons.local_activity_rounded,
                label: app.t('offers'),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const OffersScreen()))),
            _MenuItem(
                icon: Icons.workspace_premium_rounded,
                label: app.t('premium'),
                iconBg: Yozi.goldWash,
                iconColor: Yozi.gold,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const PremiumScreen()))),
            _MenuItem(
                icon: Icons.language_rounded,
                label: app.t('language'),
                trailing: Text(app.isArabic ? 'English' : 'العربية',
                    style: const TextStyle(
                        color: Yozi.violet,
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
                onTap: () => app.setLang(app.isArabic ? 'en' : 'ar')),
            _MenuItem(
                icon: Icons.place_rounded,
                label: app.t('changeArea'),
                onTap: () => showAreaPicker(context)),
            _MenuItem(
                icon: Icons.notifications_none_rounded,
                label: app.t('notifications'),
                onTap: () => showToast(context, app.t('notifToast'))),
            _MenuItem(
                icon: Icons.help_outline_rounded,
                label: app.t('helpSupport'),
                onTap: () => _openHelpSheet(context)),
            _MenuItem(
                icon: Icons.info_outline_rounded,
                label: app.t('aboutY'),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AboutScreen()))),
            _MenuItem(
                icon: Icons.logout_rounded,
                label: app.t('signOut'),
                iconBg: Yozi.coralWash,
                iconColor: Yozi.coral,
                labelColor: Yozi.coral,
                onTap: () => app.resetOnboarding()),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Center(
              child: Text('${app.t('protoNote')} · v$kAppVersion',
                  style: const TextStyle(fontSize: 11, color: Yozi.faint))),
        ),
      ]),
    );
  }

  /// Add (index == null) or edit a child: name + age in one small sheet.
  void _openChildSheet(BuildContext context, {int? index}) {
    final app = context.read<AppState>();
    final editing = index != null;
    final nameCtrl = TextEditingController(
        text: editing ? app.children[index].name : '');
    var age = editing ? app.children[index].age : 3;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SafeArea(
          child: StatefulBuilder(
            builder: (ctx, setSheet) => Padding(
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
                    Text(app.t(editing ? 'editChild' : 'addChild'),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: app.t('childName'),
                        hintStyle:
                            const TextStyle(color: Yozi.faint, fontSize: 13.5),
                        prefixIcon: const Icon(Icons.child_care_rounded,
                            color: Yozi.muted, size: 20),
                        filled: true,
                        fillColor: Yozi.surface,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 13),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Yozi.line)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: Yozi.violet, width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 4),
                      decoration: BoxDecoration(
                          color: Yozi.surface,
                          border: Border.all(color: Yozi.line),
                          borderRadius: BorderRadius.circular(14)),
                      child: Row(children: [
                        Text(app.t('childAge'),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        IconButton(
                            onPressed: () =>
                                setSheet(() => age = (age - 1).clamp(0, 16)),
                            icon: const Icon(
                                Icons.remove_circle_outline_rounded,
                                color: Yozi.violet)),
                        SizedBox(
                            width: 58,
                            child: Text('$age ${app.t('years')}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800))),
                        IconButton(
                            onPressed: () =>
                                setSheet(() => age = (age + 1).clamp(0, 16)),
                            icon: const Icon(Icons.add_circle_outline_rounded,
                                color: Yozi.violet)),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        if (editing) {
                          app.updateChild(index,
                              name: nameCtrl.text, age: age);
                        } else {
                          app.addChild(age, name: nameCtrl.text);
                        }
                        Navigator.pop(ctx);
                      },
                      child: Text(app.t('save')),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  /// Quick settings sheet opened from the gear icon.
  void _openSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final app = ctx.watch<AppState>();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(app.t('settingsT'),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 10),
                  _MenuItem(
                      icon: Icons.language_rounded,
                      label: app.t('language'),
                      trailing: Text(app.isArabic ? 'English' : 'العربية',
                          style: const TextStyle(
                              color: Yozi.violet,
                              fontSize: 13,
                              fontWeight: FontWeight.w800)),
                      onTap: () =>
                          app.setLang(app.isArabic ? 'en' : 'ar')),
                  _MenuItem(
                      icon: Icons.place_rounded,
                      label: app.t('changeArea'),
                      onTap: () {
                        Navigator.pop(ctx);
                        showAreaPicker(context);
                      }),
                  _MenuItem(
                      icon: Icons.notifications_none_rounded,
                      label: app.t('notifications'),
                      onTap: () {
                        Navigator.pop(ctx);
                        showToast(context, app.t('notifToast'));
                      }),
                ]),
          ),
        );
      },
    );
  }

  /// Help & Support sheet with the support email.
  void _openHelpSheet(BuildContext context) {
    final app = context.read<AppState>();
    showModalBottomSheet(
      context: context,
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
                Text(app.t('helpSupport'),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(app.t('helpSub'),
                    style:
                        const TextStyle(color: Yozi.muted, fontSize: 13.5)),
                const SizedBox(height: 16),
                Material(
                  color: Yozi.violetGhost,
                  borderRadius: BorderRadius.circular(Yozi.rSm),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Yozi.rSm),
                    onTap: () => openUrl(ctx, 'mailto:$kSupportEmail'),
                    onLongPress: () {
                      Clipboard.setData(
                          const ClipboardData(text: kSupportEmail));
                      showToast(ctx, app.t('emailCopied'));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 13),
                      child: Row(children: [
                        const Icon(Icons.mail_rounded,
                            color: Yozi.violet, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(kSupportEmail,
                              style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: Yozi.violetDeep)),
                        ),
                        Text(app.t('contactUs'),
                            style: const TextStyle(
                                fontSize: 12,
                                color: Yozi.violet,
                                fontWeight: FontWeight.w800)),
                      ]),
                    ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}

/// About YAZI page.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: Text(app.t('aboutY'))),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Center(child: Image.asset('assets/logo.png', width: 76, height: 76)),
        const SizedBox(height: 14),
        const Center(
          child: Text('YAZI',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        ),
        Center(
          child: Text('v$kAppVersion',
              style: const TextStyle(fontSize: 12, color: Yozi.muted)),
        ),
        const SizedBox(height: 20),
        Text(app.t('aboutBody'),
            style: const TextStyle(
                fontSize: 14.5, height: 1.7, color: Yozi.ink2)),
      ]),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.trailing,
      this.iconBg,
      this.iconColor,
      this.labelColor});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconBg, iconColor, labelColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Yozi.lineSoft))),
        child: Row(children: [
          Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: iconBg ?? Yozi.violetGhost,
                  borderRadius: BorderRadius.circular(12)),
              child:
                  Icon(icon, size: 19, color: iconColor ?? Yozi.violet)),
          const SizedBox(width: 13),
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: labelColor ?? Yozi.ink2))),
          trailing ??
              const Icon(Icons.chevron_right_rounded,
                  color: Yozi.faint, size: 20),
        ]),
      ),
    );
  }
}
