import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/mock.dart' show kApiBase;

/// Notifications for admissions alerts.
///
/// A parent only ever gets one after YOU approve an opening in the admin
/// panel — nothing here sends anything by itself.
///
/// Every step is allowed to fail quietly: a phone without Google services, a
/// parent who declines permission, or no network must never stop Yazi from
/// working. The in-app alert list still shows everything regardless.
class Push {
  Push._();

  static String? _token;
  static bool _started = false;

  /// What to run when a parent taps a notification — set by main.dart so the
  /// app can open the school it refers to.
  static void Function(String bizId)? onOpenSchool;

  static Future<void> start(String deviceId, String lang) async {
    if (_started) return;
    _started = true;
    try {
      await Firebase.initializeApp();
      final fm = FirebaseMessaging.instance;

      // Android 13+ and iOS ask the parent first. Declining is fine.
      final settings = await fm.requestPermission(alert: true, badge: true, sound: true);
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        await _register(deviceId, '', lang);   // clears any old token
        return;
      }

      _token = await fm.getToken();
      if (_token != null) await _register(deviceId, _token!, lang);

      // Tokens are replaced by the system from time to time.
      fm.onTokenRefresh.listen((t) {
        _token = t;
        _register(deviceId, t, lang);
      });

      // Tapped while the app was in the background.
      FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);
      // Tapped while the app was closed entirely.
      final initial = await fm.getInitialMessage();
      if (initial != null) _handleTap(initial);
    } catch (e) {
      debugPrint('[push] not available: $e');
    }
  }

  static void _handleTap(RemoteMessage m) {
    final id = m.data['biz_id'];
    if (id is String && id.isNotEmpty) onOpenSchool?.call(id);
  }

  /// Turn notifications off for this device without uninstalling.
  static Future<void> disable(String deviceId, String lang) async {
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) { /* nothing to delete */ }
    _token = null;
    await _register(deviceId, '', lang);
  }

  static Future<void> _register(String deviceId, String token, String lang) async {
    try {
      await http
          .post(Uri.parse('$kApiBase/push/register'),
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode({
                'device': deviceId,
                'token': token,
                'platform': defaultTargetPlatform.name,
                'lang': lang,
              }))
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('[push] could not register: $e');
    }
  }
}
