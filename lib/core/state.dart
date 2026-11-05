import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock.dart';
import 'i18n.dart';
import 'location.dart';

class ChildProfile {
  ChildProfile({required this.age, this.name = ''});
  int age;
  String name;
}

/// Global app state: language, area, children, saved items, premium, wallet.
class AppState extends ChangeNotifier {
  AppState(this._prefs) {
    lang = _prefs.getString('lang') ?? 'en';
    onboarded = _prefs.getBool('onboarded') ?? false;
    areaIndex = _prefs.getInt('area') ?? 1;
    premium = _prefs.getBool('premium') ?? false;
    wallet = _prefs.getInt('wallet') ?? 0;
    deviceId = _prefs.getString('deviceId') ?? _newDeviceId();
    _prefs.setString('deviceId', deviceId);
    if (_prefs.getBool('locShared') ?? false) _silentLocate();
    admissionSubs.addAll(_prefs.getStringList('admSubs') ?? const []);
    seenAlerts.addAll(_prefs.getStringList('seenAlerts') ?? const []);
    savedBiz.addAll(_prefs.getStringList('savedBiz') ?? const []);
    savedEvents.addAll(_prefs.getStringList('savedEv') ?? const []);
    // stored as "age" (old builds) or "age|name"
    children.addAll((_prefs.getStringList('children') ?? const []).map((s) {
      final i = s.indexOf('|');
      if (i < 0) return ChildProfile(age: int.tryParse(s) ?? 4);
      return ChildProfile(
          age: int.tryParse(s.substring(0, i)) ?? 4,
          name: s.substring(i + 1));
    }));
  }

  final SharedPreferences _prefs;

  String lang = 'en';
  bool onboarded = false;
  int areaIndex = 1;

  /// User's real position. Kept on this device only, never sent anywhere.
  double? userLat, userLng;
  bool get hasLocation => userLat != null && userLng != null;

  /// Asks for permission and reads the position. Does NOT change the area.
  Future<UserPosition> shareLocation() async {
    try {
      final p = await getUserPosition();
      if (p.ok) {
        userLat = p.lat;
        userLng = p.lng;
        _prefs.setBool('locShared', true);
        notifyListeners();
      }
      return p;
    } catch (_) {
      return const UserPosition(off: true);
    }
  }

  /// On launch: refresh the position silently if the user shared before.
  Future<void> _silentLocate() async {
    try {
      final p = await getUserPosition(ask: false);
      if (p.ok) {
        userLat = p.lat;
        userLng = p.lng;
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Estimated road distance in km (straight line x 1.3).
  double? kmTo(Business b) {
    if (!hasLocation || b.lat == null || b.lng == null) return null;
    const r = 6371.0;
    double rad(double d) => d * pi / 180;
    final dLat = rad(b.lat! - userLat!);
    final dLng = rad(b.lng! - userLng!);
    final a = pow(sin(dLat / 2), 2) +
        cos(rad(userLat!)) * cos(rad(b.lat!)) * pow(sin(dLng / 2), 2);
    return 2 * r * asin(sqrt(a)) * 1.3;
  }

  /// "~4.5 km" (estimate), or null when location is not shared.
  String? travelText(Business b) {
    final km = kmTo(b);
    if (km == null) return null;
    final kmS = km < 10 ? km.toStringAsFixed(1) : km.round().toString();
    return '~$kmS ${t('km')}';
  }
  bool premium = false;
  int wallet = 0;
  final Set<String> savedBiz = {};
  final Set<String> savedEvents = {};

  /// Anonymous per-install id used for school admissions alerts.
  late final String deviceId;

  /// Schools this device asked to be notified about.
  final Set<String> admissionSubs = {};

  /// Alert ids the user already opened (so the bell dot clears).
  final Set<String> seenAlerts = {};

  static String _newDeviceId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final r = Random.secure();
    return 'dev-${List.generate(20, (_) => chars[r.nextInt(chars.length)]).join()}';
  }

  bool isSubscribed(String bizId) => admissionSubs.contains(bizId);

  void setSubscribed(String bizId, bool on) {
    on ? admissionSubs.add(bizId) : admissionSubs.remove(bizId);
    _save();
    notifyListeners();
  }

  void replaceSubscriptions(Iterable<String> ids) {
    admissionSubs
      ..clear()
      ..addAll(ids);
    _save();
    notifyListeners();
  }

  void markAlertsSeen(Iterable<String> ids) {
    seenAlerts.addAll(ids);
    _save();
    notifyListeners();
  }
  final List<ChildProfile> children = [];

  bool get isArabic => lang == 'ar';

  String t(String key) => kStrings[lang]?[key] ?? kStrings['en']![key] ?? key;

  void _save() {
    _prefs.setString('lang', lang);
    _prefs.setBool('onboarded', onboarded);
    _prefs.setInt('area', areaIndex);
    _prefs.setBool('premium', premium);
    _prefs.setInt('wallet', wallet);
    _prefs.setStringList('savedBiz', savedBiz.toList());
    _prefs.setStringList('savedEv', savedEvents.toList());
    _prefs.setStringList('admSubs', admissionSubs.toList());
    _prefs.setStringList('seenAlerts', seenAlerts.take(200).toList());
    _prefs.setStringList(
        'children', children.map((c) => '${c.age}|${c.name}').toList());
  }

  void setLang(String l) {
    lang = l;
    _save();
    notifyListeners();
  }

  void setArea(int i) {
    areaIndex = i;
    _save();
    notifyListeners();
  }

  void completeOnboarding() {
    onboarded = true;
    _save();
    notifyListeners();
  }

  void resetOnboarding() {
    onboarded = false;
    _save();
    notifyListeners();
  }

  bool isSaved(String id) => savedBiz.contains(id);
  bool isEventSaved(String id) => savedEvents.contains(id);

  /// Returns true if the item is now saved.
  bool toggleBiz(String id) {
    final added = !savedBiz.remove(id);
    if (added) savedBiz.add(id);
    _save();
    notifyListeners();
    return added;
  }

  bool toggleEvent(String id) {
    final added = !savedEvents.remove(id);
    if (added) savedEvents.add(id);
    _save();
    notifyListeners();
    return added;
  }

  void saveEvent(String id) {
    savedEvents.add(id);
    _save();
    notifyListeners();
  }

  void addChild(int age, {String name = ''}) {
    children.add(ChildProfile(age: age, name: name.trim()));
    _save();
    notifyListeners();
  }

  void updateChild(int index, {String? name, int? age}) {
    if (index < 0 || index >= children.length) return;
    if (name != null) children[index].name = name.trim();
    if (age != null) children[index].age = age.clamp(0, 16);
    _save();
    notifyListeners();
  }

  void removeChild(int index) {
    if (index < 0 || index >= children.length) return;
    children.removeAt(index);
    _save();
    notifyListeners();
  }

  void setChildAge(int index, int age) {
    children[index].age = age.clamp(0, 16);
    _save();
    notifyListeners();
  }

  void unlockPremium() {
    premium = true;
    _save();
    notifyListeners();
  }

  void addSavings(int egp) {
    wallet += egp;
    _save();
    notifyListeners();
  }
}
