import 'dart:convert';

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'mock.dart';

enum RepoStatus { loading, ready, error }

/// Loads all app data from the live backend, with a disk cache so the app
/// opens instantly (and works offline) after the first successful fetch.
class DataRepo extends ChangeNotifier {
  DataRepo(this._prefs);
  final SharedPreferences _prefs;

  RepoStatus status = RepoStatus.loading;
  String? errorMessage;
  Map<String, dynamic> settings = {};
  DateTime? lastSync;

  static const _cacheKey = 'api_cache_v1';

  Future<void> load() async {
    status = RepoStatus.loading;
    notifyListeners();

    // 1) hydrate from disk cache immediately (offline-first)
    final cached = _prefs.getString(_cacheKey);
    var hasCache = false;
    if (cached != null) {
      try {
        _hydrate(jsonDecode(cached) as Map<String, dynamic>);
        hasCache = true;
        status = RepoStatus.ready;
        notifyListeners();
      } catch (_) {/* corrupt cache — ignore */}
    }

    // 2) refresh from network
    final ok = await refresh(silent: hasCache);
    if (!ok && !hasCache) {
      status = RepoStatus.error;
      notifyListeners();
    }
  }

  Future<bool> refresh({bool silent = false}) async {
    try {
      final results = await Future.wait([
        _get('/categories'),
        _get('/areas'),
        _get('/businesses'),
        _get('/events'),
        _get('/offers'),
        _get('/settings'),
        // tolerate an older server that has no /videos yet
        _get('/videos').catchError((_) => <dynamic>[]),
        _get('/featured').catchError((_) => <dynamic>[]),
        _get('/subcat-icons').catchError((_) => <dynamic>[]),
      ]).timeout(const Duration(seconds: 20));
      final payload = {
        'categories': results[0],
        'areas': results[1],
        'businesses': results[2],
        'events': results[3],
        'offers': results[4],
        'settings': results[5],
        'videos': results[6],
        'featured': results[7],
        'subcat_icons': results[8],
      };
      _hydrate(payload);
      await _prefs.setString(_cacheKey, jsonEncode(payload));
      lastSync = DateTime.now();
      status = RepoStatus.ready;
      errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      if (!silent) notifyListeners();
      return false;
    }
  }

  Future<dynamic> _get(String path) async {
    final r = await http
        .get(Uri.parse('$kApiBase$path'), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));
    if (r.statusCode != 200) throw Exception('GET $path → ${r.statusCode}');
    return jsonDecode(utf8.decode(r.bodyBytes));
  }

  void _hydrate(Map<String, dynamic> p) {
    kCats
      ..clear()
      ..addAll((p['categories'] as List).map((j) => Category.fromJson(j)));
    kAreas
      ..clear()
      ..addAll((p['areas'] as List).map((j) => Area.fromJson(j)));
    kBusinesses
      ..clear()
      ..addAll((p['businesses'] as List).map((j) => Business.fromJson(j)));
    kEvents
      ..clear()
      ..addAll((p['events'] as List).map((j) => KidsEvent.fromJson(j)));
    kOffers
      ..clear()
      ..addAll((p['offers'] as List).map((j) => Offer.fromJson(j)));
    kVideos
      ..clear()
      ..addAll(((p['videos'] as List?) ?? const [])
          .map((j) => TipVideo.fromJson(j)));
    kFeatured
      ..clear()
      ..addAll(((p['featured'] as List?) ?? const [])
          .map((j) => Featured.fromJson(j)));
    kSubcatIconUrls.clear();
    for (final j in (p['subcat_icons'] as List?) ?? const []) {
      final u = absUrl(j['icon']);
      if (u != null) kSubcatIconUrls['${j['cat']}/${j['sub']}'] = u;
    }
    settings = (p['settings'] as Map?)?.cast<String, dynamic>() ?? {};
  }

  /* ---------- school admissions: notify-me ---------- */

  /// Subscribe / unsubscribe this device to a school's admissions alerts.
  Future<bool> setAdmissionAlert(String device, String bizId, bool on,
      {String lang = 'en'}) async {
    try {
      final r = await http
          .post(Uri.parse('$kApiBase/admissions/subscribe'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'device': device, 'biz_id': bizId, 'on': on, 'lang': lang}))
          .timeout(const Duration(seconds: 10));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Schools this device is subscribed to (server is the source of truth).
  Future<List<String>> mySubscriptions(String device) async {
    try {
      final r = await _get('/admissions/mine?device=$device');
      return (r as List).map((x) => x.toString()).toList();
    } catch (_) {
      return const [];
    }
  }

  /// "Admissions open" alerts waiting for this device.
  Future<List<AdmissionAlert>> admissionAlerts(String device) async {
    try {
      final r = await _get('/admissions/alerts?device=$device');
      return (r as List).map((j) => AdmissionAlert.fromJson(j)).toList();
    } catch (_) {
      return const [];
    }
  }

  /// Remote-configured bilingual text with i18n fallback.
  String remoteText(String key, String lang, String fallback) {
    final v = settings[key];
    if (v is Map && v[lang] is String && (v[lang] as String).isNotEmpty) {
      return v[lang] as String;
    }
    return fallback;
  }

  num remoteNum(String key, num fallback) =>
      settings[key] is num ? settings[key] as num : fallback;

  Map<String, dynamic> remoteMap(String key) =>
      settings[key] is Map ? (settings[key] as Map).cast<String, dynamic>() : {};
}
