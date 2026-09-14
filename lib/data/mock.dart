import 'dart:convert';

import 'package:flutter/material.dart';

/// Production API — override at build time with --dart-define=YAZI_API=...
const kApiBase = String.fromEnvironment('YAZI_API',
    defaultValue: 'https://yazi.hossamhamouda.com/api/v1');

/// Origin of the API (no /api/v1) — uploaded media lives under /uploads.
final String kApiOrigin = kApiBase.replaceFirst(RegExp(r'/api/v1/?$'), '');

/// Turns a server path ("/uploads/x.png") into an absolute URL. Absolute
/// URLs and empty values pass through untouched.
String? absUrl(String? p) {
  if (p == null || p.isEmpty) return null;
  if (p.startsWith('http://') || p.startsWith('https://')) return p;
  return '$kApiOrigin$p';
}

/// ---------- models ----------
class Area {
  const Area(this.en, this.ar, [this.lat = 30.03, this.lng = 31.46]);
  final String en, ar;
  final double lat, lng;
  String name(String lang) => lang == 'ar' ? ar : en;

  factory Area.fromJson(Map<String, dynamic> j) => Area(
      j['name_en'] ?? '', j['name_ar'] ?? j['name_en'] ?? '',
      (j['lat'] as num?)?.toDouble() ?? 30.03,
      (j['lng'] as num?)?.toDouble() ?? 31.46);
}

Color _hex(String? s, int fallback) {
  if (s == null || !s.startsWith('#') || s.length != 7) return Color(fallback);
  return Color(0xFF000000 | int.parse(s.substring(1), radix: 16));
}

bool _b(dynamic v) => v == true || v == 1;
List<dynamic> _jsonList(dynamic v) {
  if (v is List) return v;
  if (v is String && v.isNotEmpty) {
    try { return (jsonDecode(v) as List); } catch (_) {}
  }
  return const [];
}

class Category {
  const Category(
      this.id, this.icon, this.emoji, this.en, this.ar, this.color, this.wash,
      {this.iconUrl});
  final String id;
  final IconData icon;
  final String emoji;
  final String en, ar;
  final Color color, wash;

  /// Icon uploaded from the admin panel — wins over the bundled artwork.
  final String? iconUrl;
  String name(String lang) => lang == 'ar' ? ar : en;

  factory Category.fromJson(Map<String, dynamic> j) => Category(
      j['id'], kCatIcons[j['id']] ?? Icons.auto_awesome_rounded,
      j['emoji'] ?? '✨', j['name_en'] ?? j['id'], j['name_ar'] ?? j['name_en'] ?? j['id'],
      _hex(j['color'], 0xFF6C3FD6), _hex(j['wash'], 0xFFEFE8FD),
      iconUrl: absUrl(j['icon']));
}

/// Subcategory icons uploaded from the admin panel, keyed "cat/sub".
final Map<String, String> kSubcatIconUrls = {};
String? subcatIconUrl(String cat, String sub) => kSubcatIconUrls['$cat/$sub'];

/// Icons per category id (server data has no icon fonts).
const kCatIcons = <String, IconData>{
  'nurseries': Icons.child_care_rounded,
  'schools': Icons.school_rounded,
  'play': Icons.toys_rounded,
  'sports': Icons.sports_soccer_rounded,
  'birthdays': Icons.cake_rounded,
  'toys': Icons.card_giftcard_rounded,
  'clothes': Icons.checkroom_rounded,
  'activities': Icons.palette_rounded,
  'firstdays': Icons.baby_changing_station_rounded,
  'healthcare': Icons.medical_services_rounded,
  'inclusive': Icons.favorite_rounded,
  'glow': Icons.auto_awesome_rounded,
};

/// Categories kept out of the Home grid — reachable through "See All".
const kHiddenFromHome = {'firstdays', 'healthcare', 'inclusive', 'glow'};

/// Categories kept out of every browse grid — Glow has its own tab.
const kHiddenFromBrowse = {'glow'};

/// Categories shown in a grid, honouring the two rules above.
List<Category> browseCats({required bool home}) => kCats
    .where((c) => !kHiddenFromBrowse.contains(c.id))
    .where((c) => !home || !kHiddenFromHome.contains(c.id))
    .toList();

/// ---------- subcategories (mirrored in backend/public/app.js) ----------
class Subcat {
  const Subcat(this.id, this.en, this.ar, {this.asset, this.icon});
  final String id, en, ar;

  /// 3D artwork under assets/icons3d/ — shown instead of [icon] when present.
  final String? asset;
  final IconData? icon;
  String name(String lang) => lang == 'ar' ? ar : en;
}

const _langSubcats = [
  Subcat('german', 'Deutsch', 'ألماني', asset: 'sub_german'),
  Subcat('english', 'English', 'إنجليزي', asset: 'sub_english'),
  Subcat('french', 'Français', 'فرنساوي', asset: 'sub_french'),
  // Present in the data ("English+Arabic") but was missing from the picker.
  Subcat('arabic', 'Arabic', 'عربي', asset: 'sub_arabic'),
];

const kSubcats = <String, List<Subcat>>{
  'nurseries': _langSubcats,
  'schools': _langSubcats,
  'play': [
    Subcat('indoor', 'Indoor', 'داخلي', asset: 'sub_indoor'),
    Subcat('outdoor', 'Outdoor', 'خارجي', asset: 'sub_outdoor'),
    Subcat('pool', 'Pool', 'حمام سباحة', asset: 'sub_pool'),
  ],
  'birthdays': [
    // One Play Area tile that covers indoor, outdoor and pool venues.
    Subcat('playarea', 'Play Area', 'منطقة لعب', asset: 'sub_indoor',
        icon: Icons.celebration_rounded),
    Subcat('giveaways', 'Giveaways', 'توزيعات', icon: Icons.card_giftcard_rounded),
    Subcat('cakes', 'Cakes', 'تورتات', icon: Icons.cake_rounded),
    Subcat('decoration', 'Decoration', 'ديكور', icon: Icons.auto_awesome_rounded),
    Subcat('programs', 'Programs', 'برامج وفقرات', icon: Icons.theater_comedy_rounded),
  ],
  'sports': [
    Subcat('robotics', 'Robotics', 'روبوتيكس', icon: Icons.smart_toy_rounded),
    Subcat('art', 'Art', 'فنون', icon: Icons.palette_rounded),
    Subcat('quran', 'Quran', 'قرآن', icon: Icons.menu_book_rounded),
    Subcat('music', 'Music', 'موسيقى', icon: Icons.music_note_rounded),
    Subcat('home_activities', 'Home Activities', 'أنشطة منزلية',
        icon: Icons.home_rounded),
  ],
  'activities': [
    Subcat('home_activities', 'Home Activities', 'أنشطة منزلية',
        icon: Icons.home_rounded),
  ],
  'firstdays': [
    Subcat('newborn', 'New Born', 'مولود جديد'),
    Subcat('newmom', 'New Mom', 'ماما جديدة'),
  ],
  'healthcare': [
    Subcat('pediatrician', 'Pediatrician', 'طبيب أطفال'),
    Subcat('dentist', 'Dentist', 'طبيب أسنان'),
    Subcat('therapy', 'Therapy', 'علاج طبيعي وتخاطب'),
    Subcat('pharmacy', 'Pharmacy', 'صيدلية'),
    Subcat('vaccination', 'Vaccination', 'تطعيمات'),
  ],
  'inclusive': [
    Subcat('therapy_center', 'Therapy Center', 'مركز تأهيل'),
    Subcat('special_school', 'Inclusive School', 'مدرسة دمج'),
    Subcat('support_group', 'Support Group', 'مجموعة دعم'),
    Subcat('sensory_play', 'Sensory Play', 'لعب حسي'),
  ],
  // Glow — the mama tab. Each entry is a tile inside it.
  'glow': [
    Subcat('beauty', 'Beauty & Wellness', 'الجمال والعناية',
        asset: 'glow_beauty', icon: Icons.spa_rounded),
    Subcat('sipsave', 'Sip & Save', 'كافيهات وعروض',
        asset: 'glow_sipsave', icon: Icons.local_cafe_rounded),
    Subcat('career', 'Career & Remote Jobs', 'شغل وفرص عن بُعد',
        asset: 'glow_career', icon: Icons.laptop_mac_rounded),
    Subcat('fitness', 'Mom Fitness', 'لياقة الأمهات',
        asset: 'glow_fitness', icon: Icons.fitness_center_rounded),
    Subcat('workshops', 'Workshops', 'ورش عمل',
        asset: 'glow_workshops', icon: Icons.handyman_rounded),
    Subcat('learning', 'Learning & Sessions', 'تعلّم وجلسات',
        asset: 'glow_learning', icon: Icons.menu_book_rounded),
    Subcat('shopping', 'Shopping Events', 'فعاليات تسوق',
        asset: 'glow_shopping', icon: Icons.shopping_bag_rounded),
    Subcat('pregnancy', 'Pregnancy Activities', 'أنشطة الحمل',
        asset: 'glow_pregnancy', icon: Icons.pregnant_woman_rounded),
  ],
};

Subcat? subcatById(String catId, String subId) {
  for (final s in kSubcats[catId] ?? const <Subcat>[]) {
    if (s.id == subId) return s;
  }
  return null;
}

class PriceRow {
  const PriceRow(this.labelEn, this.labelAr, this.valueEn, this.valueAr);

  factory PriceRow.fromJson(Map<String, dynamic> j) => PriceRow(
      j['label_en'] ?? '', j['label_ar'] ?? j['label_en'] ?? '',
      j['value_en'] ?? '', j['value_ar'] ?? j['value_en'] ?? '');
  final String labelEn, labelAr, valueEn, valueAr;
  String label(String lang) => lang == 'ar' ? labelAr : labelEn;
  String value(String lang) => lang == 'ar' ? valueAr : valueEn;
}

class Business {
  const Business({
    required this.id,
    required this.cat,
    required this.grad,
    required this.nameEn,
    required this.nameAr,
    required this.area,
    required this.drive,
    required this.rating,
    required this.reviews,
    required this.ages,
    this.minAgeMonths,
    this.maxAgeMonths,
    required this.verified,
    this.sponsored = false,
    this.offer = false,
    required this.priceEn,
    required this.priceAr,
    required this.open,
    required this.keywords,
    required this.aboutEn,
    required this.aboutAr,
    required this.prices,
    required this.amenEn,
    required this.amenAr,
    this.lat,
    this.lng,
    this.subcat = '',
    this.phone,
    this.website,
    this.facebook,
    this.instagram,
    this.hasPhoto = false,
    this.hours = const [],
    this.photos = const [],
    this.logo,
    this.admissionsOpen = false,
    this.admissionsIntake,
    this.applicationUrl,
  });

  final String id, cat, grad, nameEn, nameAr, priceEn, priceAr;
  final String aboutEn, aboutAr, keywords, ages, subcat;

  /// Age range in months. Set from the admin panel; preferred over the old
  /// free-text [ages] field, which mixed months and years.
  final int? minAgeMonths, maxAgeMonths;
  final int area, drive, reviews;
  final double rating;
  final bool verified, sponsored, offer, open;
  final List<PriceRow> prices;
  final List<String> amenEn, amenAr;
  final double? lat, lng;
  final String? phone, website, facebook, instagram;
  final bool hasPhoto;

  /// Weekly hours as stored by the admin: "Monday: 9:00 AM – 5:00 PM".
  final List<String> hours;

  /// Photos uploaded from the admin panel (absolute URLs, first = cover).
  final List<String> photos;
  final String? logo;

  /// School / nursery admissions (Phase 1).
  final bool admissionsOpen;
  final String? admissionsIntake, applicationUrl;
  bool get isSchool => cat == 'schools' || cat == 'nurseries';

  /// Cover image: uploaded photo first, then the Google place photo.
  /// Null when there is nothing, so callers show the gradient instead.
  String? photoUrl({int width = 400}) => photos.isNotEmpty
      ? photos.first
      : hasPhoto
          ? '$kApiBase/photo/$id?w=$width'
          : null;

  /// Every image for the detail gallery.
  List<String> galleryUrls({int width = 800}) => [
        ...photos,
        if (hasPhoto) '$kApiBase/photo/$id?w=$width',
      ];

  /// True when the listing has usable opening hours.
  bool get hasHours => hours.any((h) => h.contains(':'));

  /// Open right now according to the opening hours (device local time —
  /// Cairo for our users). Listings without hours never count as open, so
  /// the "Open now" filter only shows places we can actually verify.
  bool get isOpenNow => hasHours && isOpenAt(hours, DateTime.now());

  /// Today's hours line, e.g. "9:00 AM – 5:00 PM" / "Closed", or null.
  String? get todayHours {
    if (!hasHours) return null;
    final name = _dayNames[DateTime.now().weekday - 1];
    for (final h in hours) {
      if (h.toLowerCase().startsWith(name)) return h.substring(h.indexOf(':') + 1).trim();
    }
    return null;
  }

  factory Business.fromJson(Map<String, dynamic> j) => Business(
      id: j['id'], cat: j['cat'] ?? 'activities', grad: j['grad'] ?? 'violet',
      nameEn: j['name_en'] ?? '', nameAr: (j['name_ar'] ?? '') == '' ? (j['name_en'] ?? '') : j['name_ar'],
      area: (j['area'] as num?)?.toInt() ?? 0,
      drive: (j['drive'] as num?)?.toInt() ?? 0,
      rating: (j['rating'] as num?)?.toDouble() ?? 0,
      reviews: (j['reviews'] as num?)?.toInt() ?? 0,
      ages: j['ages'] ?? '',
      minAgeMonths: (j['min_age_months'] as num?)?.toInt(),
      maxAgeMonths: (j['max_age_months'] as num?)?.toInt(),
      verified: _b(j['verified']),
      sponsored: _b(j['sponsored']), offer: _b(j['offer']),
      priceEn: j['price_en'] ?? '', priceAr: j['price_ar'] ?? j['price_en'] ?? '',
      open: _b(j['open']), keywords: j['keywords'] ?? '',
      aboutEn: j['about_en'] ?? '', aboutAr: j['about_ar'] ?? j['about_en'] ?? '',
      prices: _jsonList(j['prices_json']).map((x) => PriceRow.fromJson(x)).toList(),
      amenEn: _jsonList(j['amen_en_json']).map((x) => x.toString()).toList(),
      amenAr: _jsonList(j['amen_ar_json']).map((x) => x.toString()).toList(),
      lat: (j['lat'] as num?)?.toDouble(), lng: (j['lng'] as num?)?.toDouble(),
      subcat: j['subcat'] ?? '',
      phone: j['phone'], website: j['website'],
      facebook: j['facebook'], instagram: j['instagram'],
      hasPhoto: (j['photo_ref'] ?? '').toString().isNotEmpty,
      hours: _jsonList(j['hours_json']).map((x) => x.toString()).toList(),
      photos: _jsonList(j['photos_json'])
          .map((x) => absUrl(x.toString()))
          .whereType<String>()
          .toList(),
      logo: absUrl(j['logo']),
      admissionsOpen: _b(j['admissions_open']),
      admissionsIntake: (j['admissions_intake'] ?? '').toString().isEmpty
          ? null
          : j['admissions_intake'].toString(),
      applicationUrl: (j['application_url'] ?? '').toString().isEmpty
          ? null
          : j['application_url'].toString());

  /// Parsed age range from the free-text `ages` field ("3 – 12"). Null when
  /// the field has no digits, so unknown ages never get filtered out.
  /// Subcategories a listing belongs to. The database stores these as a single
  /// free-text field that may hold several values ("English+French",
  /// "English, Arabic") and inconsistent casing ("english"). Splitting and
  /// lower-casing here lets a nursery that teaches two or three languages
  /// match the filter for each one.
  Set<String> get subcatIds => subcat
      .split(RegExp(r'[+,/&]'))
      .map((s) => s.trim().toLowerCase())
      .where((s) => s.isNotEmpty)
      .toSet();

  bool hasSubcat(String id) => subcatIds.contains(id.trim().toLowerCase());

  (int, int)? get ageRange {
    // Prefer the numeric months columns — the old free-text field read
    // "3 months – 4 years" as 3 to 4 YEARS, which is wrong by a factor of 12.
    if (minAgeMonths != null || maxAgeMonths != null) {
      final lo = (minAgeMonths ?? 0) ~/ 12;
      final hi = maxAgeMonths == null ? 99 : (maxAgeMonths! / 12).ceil();
      return (lo, hi);
    }
    final nums = RegExp(r'\d+')
        .allMatches(ages)
        .map((m) => int.parse(m.group(0)!))
        .toList();
    if (nums.isEmpty) return null;
    if (nums.length == 1) return (nums[0], nums[0]);
    return (nums[0], nums[1]);
  }

  String name(String lang) => lang == 'ar' ? nameAr : nameEn;
  String price(String lang) => lang == 'ar' ? priceAr : priceEn;
  String about(String lang) => lang == 'ar' ? aboutAr : aboutEn;
  List<String> amenities(String lang) => lang == 'ar' ? amenAr : amenEn;
}

const _dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

/// Parses "9:00 AM – 5:00 PM", "12:00 – 10:00 PM", "Open 24 hours",
/// "Closed" (Google-style, with any dash/space variant) and tells whether
/// [now] falls inside. Overnight ranges (6 PM – 2 AM) are handled.
bool isOpenAt(List<String> hours, DateTime now) {
  final name = _dayNames[now.weekday - 1];
  String? line;
  for (final h in hours) {
    if (h.toLowerCase().startsWith(name)) { line = h; break; }
  }
  if (line == null) return false;
  var spec = line.substring(line.indexOf(':') + 1).trim().toLowerCase();
  if (spec.contains('closed')) return false;
  if (spec.contains('24 hours') || spec.contains('24h')) return true;
  // normalise unicode spaces and dashes
  spec = spec
      .replaceAll(RegExp(r'[\u2009\u202f\u00a0]'), ' ')
      .replaceAll(RegExp(r'[–—]'), '-');
  final nowMin = now.hour * 60 + now.minute;
  // several ranges may be joined with ","
  for (final part in spec.split(',')) {
    final m = RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)?\s*-\s*(\d{1,2})(?::(\d{2}))?\s*(am|pm)?')
        .firstMatch(part);
    if (m == null) continue;
    final endAp = m.group(6);
    final startAp = m.group(3) ?? endAp; // "12:00 – 10:00 PM" → start shares PM
    final start = _toMinutes(int.parse(m.group(1)!), int.parse(m.group(2) ?? '0'), startAp);
    final end = _toMinutes(int.parse(m.group(4)!), int.parse(m.group(5) ?? '0'), endAp);
    if (end > start) {
      if (nowMin >= start && nowMin < end) return true;
    } else {
      // overnight, e.g. 6:00 PM – 2:00 AM
      if (nowMin >= start || nowMin < end) return true;
    }
  }
  return false;
}

int _toMinutes(int h, int m, String? ap) {
  var hh = h % 24;
  if (ap == 'pm' && hh < 12) hh += 12;
  if (ap == 'am' && hh == 12) hh = 0;
  return hh * 60 + m;
}

/// Home "Sponsored & New" strip entry managed from the admin panel.
class Featured {
  const Featured({
    required this.id,
    required this.kind,
    required this.titleEn,
    required this.titleAr,
    required this.subEn,
    required this.subAr,
    this.bizId,
    this.image,
    this.link,
  });
  final String id, kind, titleEn, titleAr, subEn, subAr;
  final String? bizId, image, link;
  bool get isNew => kind == 'new';

  factory Featured.fromJson(Map<String, dynamic> j) => Featured(
      id: j['id'], kind: j['kind'] ?? 'sponsor',
      titleEn: j['title_en'] ?? '', titleAr: j['title_ar'] ?? j['title_en'] ?? '',
      subEn: j['sub_en'] ?? '', subAr: j['sub_ar'] ?? j['sub_en'] ?? '',
      bizId: (j['biz_id'] ?? '').toString().isEmpty ? null : j['biz_id'].toString(),
      image: absUrl(j['image']),
      link: (j['link'] ?? '').toString().isEmpty ? null : j['link'].toString());

  String title(String lang) => lang == 'ar' ? titleAr : titleEn;
  String sub(String lang) => lang == 'ar' ? subAr : subEn;
}

/// One "admissions are open" alert for a school the user subscribed to.
class AdmissionAlert {
  const AdmissionAlert({required this.id, required this.bizId, required this.nameEn,
      required this.nameAr, this.intake, this.applicationUrl, required this.ts});
  final int id;
  final String bizId, nameEn, nameAr, ts;
  final String? intake, applicationUrl;
  factory AdmissionAlert.fromJson(Map<String, dynamic> j) => AdmissionAlert(
      id: (j['id'] as num).toInt(), bizId: j['biz_id'], nameEn: j['name_en'] ?? '',
      nameAr: j['name_ar'] ?? j['name_en'] ?? '', intake: j['intake'],
      applicationUrl: j['application_url'], ts: j['ts'] ?? '');
  String name(String lang) => lang == 'ar' ? nameAr : nameEn;
}

class KidsEvent {
  const KidsEvent({
    required this.id,
    required this.grad,
    required this.nameEn,
    required this.nameAr,
    required this.dateEn,
    required this.dateAr,
    required this.timeEn,
    required this.timeAr,
    required this.area,
    required this.ages,
    required this.price,
    required this.thisWeek,
    required this.orgId,
    required this.descEn,
    required this.descAr,
  });

  final String id, grad, nameEn, nameAr, dateEn, dateAr, timeEn, timeAr;
  final String ages, orgId, descEn, descAr;
  final int area, price;
  final bool thisWeek;

  factory KidsEvent.fromJson(Map<String, dynamic> j) => KidsEvent(
      id: j['id'], grad: j['grad'] ?? 'violet',
      nameEn: j['name_en'] ?? '', nameAr: j['name_ar'] ?? j['name_en'] ?? '',
      dateEn: j['date_en'] ?? '', dateAr: j['date_ar'] ?? j['date_en'] ?? '',
      timeEn: j['time_en'] ?? '', timeAr: j['time_ar'] ?? j['time_en'] ?? '',
      area: (j['area'] as num?)?.toInt() ?? 0, ages: j['ages'] ?? 'All',
      price: (j['price'] as num?)?.toInt() ?? 0, thisWeek: _b(j['this_week']),
      orgId: j['org_id'] ?? '', descEn: j['desc_en'] ?? '',
      descAr: j['desc_ar'] ?? j['desc_en'] ?? '');

  String name(String lang) => lang == 'ar' ? nameAr : nameEn;
  String date(String lang) => lang == 'ar' ? dateAr : dateEn;
  String time(String lang) => lang == 'ar' ? timeAr : timeEn;
  String desc(String lang) => lang == 'ar' ? descAr : descEn;
}

class Offer {
  const Offer({
    required this.id,
    required this.bizId,
    required this.grad,
    required this.premium,
    required this.saveEgp,
    required this.titleEn,
    required this.titleAr,
    required this.subEn,
    required this.subAr,
    required this.expEn,
    required this.expAr,
  });

  final String id, bizId, grad, titleEn, titleAr, subEn, subAr, expEn, expAr;
  final bool premium;
  final int saveEgp;

  factory Offer.fromJson(Map<String, dynamic> j) => Offer(
      id: j['id'], bizId: j['biz_id'] ?? '', grad: j['grad'] ?? 'violet',
      premium: _b(j['premium']), saveEgp: (j['save_egp'] as num?)?.toInt() ?? 0,
      titleEn: j['title_en'] ?? '', titleAr: j['title_ar'] ?? j['title_en'] ?? '',
      subEn: j['sub_en'] ?? '', subAr: j['sub_ar'] ?? j['sub_en'] ?? '',
      expEn: j['exp_en'] ?? '', expAr: j['exp_ar'] ?? j['exp_en'] ?? '');

  String title(String lang) => lang == 'ar' ? titleAr : titleEn;
  String sub(String lang) => lang == 'ar' ? subAr : subEn;
  String exp(String lang) => lang == 'ar' ? expAr : expEn;
}

/// Tutorial / tips video (YouTube etc.) managed from the admin panel.
class TipVideo {
  const TipVideo({
    required this.id,
    required this.kind,
    required this.titleEn,
    required this.titleAr,
    required this.url,
    this.thumb,
  });

  final String id, kind, titleEn, titleAr, url;
  final String? thumb;

  /// Uploaded file (served by our backend) wins over an external URL.
  factory TipVideo.fromJson(Map<String, dynamic> j) => TipVideo(
      id: j['id'], kind: j['kind'] ?? 'home_activities',
      titleEn: j['title_en'] ?? '', titleAr: j['title_ar'] ?? j['title_en'] ?? '',
      url: absUrl(j['file']) ?? (j['url'] ?? ''), thumb: absUrl(j['thumb']));

  String title(String lang) => lang == 'ar' ? titleAr : titleEn;
}

class Review {
  const Review(this.nameEn, this.nameAr, this.metaEn, this.metaAr, this.rating,
      this.color, this.textEn, this.textAr);
  final String nameEn, nameAr, metaEn, metaAr, textEn, textAr;
  final int rating;
  final Color color;
  String name(String lang) => lang == 'ar' ? nameAr : nameEn;
  String meta(String lang) => lang == 'ar' ? metaAr : metaEn;
  String text(String lang) => lang == 'ar' ? textAr : textEn;
}

/// App version shown in footers — keep in sync with pubspec.yaml.
const kAppVersion = '1.6.0';

/// ---------- live data (hydrated from the API by DataRepo) ----------
final List<Area> kAreas = [];
final List<Category> kCats = [];

Category catById(String id) => kCats.firstWhere((c) => c.id == id,
    orElse: () => Category(id, Icons.auto_awesome_rounded, '✨', id, id,
        const Color(0xFF6C3FD6), const Color(0xFFEFE8FD)));

final List<Business> kBusinesses = [];

Business? bizByIdOrNull(String id) {
  for (final b in kBusinesses) {
    if (b.id == id) return b;
  }
  return null;
}

final List<KidsEvent> kEvents = [];

KidsEvent eventById(String id) => kEvents.firstWhere((e) => e.id == id);

final List<Offer> kOffers = [];

final List<TipVideo> kVideos = [];

final List<Featured> kFeatured = [];

const kReviews = <String, List<Review>>{
  'swim1': [
    Review('Mona A.', 'منى أ.', 'Mom of a 5-year-old · Tagamoa 5',
        'أم لطفل ٥ سنوات · التجمع الخامس', 5, Color(0xFF7C4DE8),
        'Adam learned to float in 3 weeks! Coaches are patient and the mom waiting area has good coffee.',
        'آدم تعلم العوم في ٣ أسابيع! المدربون صبورون ومنطقة انتظار الأمهات فيها قهوة ممتازة.'),
    Review('Heba S.', 'هبة س.', 'Mom of a 7-year-old · Rehab',
        'أم لطفلة ٧ سنوات · الرحاب', 5, Color(0xFF0E9F6E),
        'Worth the drive from Rehab. Small groups, real progress every week.',
        'تستحق المشوار من الرحاب. مجموعات صغيرة وتقدم حقيقي كل أسبوع.'),
    Review('Sara M.', 'سارة م.', 'Mom of a 4-year-old', 'أم لطفل ٤ سنوات', 4,
        Color(0xFFE11D48),
        'Great coaching. Parking gets crowded on Fridays.',
        'تدريب ممتاز. الموقف يزدحم أيام الجمعة.'),
  ],
  'nur1': [
    Review('Nour K.', 'نور ك.', 'Mom of a 2-year-old · Tagamoa 1',
        'أم لطفلة سنتين · التجمع الأول', 5, Color(0xFF0E7DC2),
        'The live camera gives me so much peace of mind at work. Laila loves her teachers.',
        'الكاميرا المباشرة تطمئنني وأنا في الشغل. ليلى تحب مشرفاتها جدًا.'),
    Review('Aya T.', 'آية ت.', 'Mom of a 3-year-old', 'أم لطفل ٣ سنوات', 5,
        Color(0xFFD97706),
        'Clean, organised, and they actually follow the Montessori method.',
        'نظيفة ومنظمة ويطبقون منهج مونتيسوري فعلًا.'),
  ],
  'play1': [
    Review('Dina R.', 'دينا ر.', 'Mom of two (3 & 8)', 'أم لطفلين (٣ و٨)', 5,
        Color(0xFFDB2777),
        "The toddler zone is separated and safe. We did Omar's birthday here — the party room was perfect.",
        'منطقة الصغار منفصلة وآمنة. عملنا عيد ميلاد عمر هنا وقاعة الحفلات كانت ممتازة.'),
  ],
  'sch1': [
    Review('Rania H.', 'رانيا هـ.', 'Mom of a 6-year-old', 'أم لطفل ٦ سنوات', 5,
        Color(0xFF5227B0),
        'Transparent about fees from the first visit. Bus is always on time.',
        'واضحون في المصاريف من أول زيارة، والباص ملتزم دائمًا.'),
  ],
};

/// Area centers for the map — derived from live areas.
List<List<double>> get kAreaCoords =>
    [for (final a in kAreas) [a.lat, a.lng]];
