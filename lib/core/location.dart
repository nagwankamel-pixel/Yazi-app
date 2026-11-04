import 'package:geolocator/geolocator.dart';

import '../data/mock.dart';

/// Result of a real GPS lookup mapped to the nearest supported area.
class AreaDetection {
  const AreaDetection({this.areaIndex, this.denied = false, this.off = false});
  final int? areaIndex;
  final bool denied; // permission refused
  final bool off; // location services disabled
}

/// Gets the device position and returns the nearest area in [kAreas].
Future<AreaDetection> detectNearestArea() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    return const AreaDetection(off: true);
  }
  var perm = await Geolocator.checkPermission();
  if (perm == LocationPermission.denied) {
    perm = await Geolocator.requestPermission();
  }
  if (perm == LocationPermission.denied ||
      perm == LocationPermission.deniedForever) {
    return const AreaDetection(denied: true);
  }
  final pos = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.medium,
      timeLimit: Duration(seconds: 12),
    ),
  );
  var best = double.infinity;
  var bestI = 0;
  for (var i = 0; i < kAreaCoords.length; i++) {
    final d = Geolocator.distanceBetween(
        pos.latitude, pos.longitude, kAreaCoords[i][0], kAreaCoords[i][1]);
    if (d < best) {
      best = d;
      bestI = i;
    }
  }
  return AreaDetection(areaIndex: bestI);
}


/// Result of a plain GPS lookup (no area snapping).
class UserPosition {
  const UserPosition({this.lat, this.lng, this.denied = false, this.off = false});
  final double? lat, lng;
  final bool denied;
  final bool off;
  bool get ok => lat != null && lng != null;
}

/// Gets the device position only. [ask] = false never shows a permission prompt.
Future<UserPosition> getUserPosition({bool ask = true}) async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    return const UserPosition(off: true);
  }
  var perm = await Geolocator.checkPermission();
  if (perm == LocationPermission.denied && ask) {
    perm = await Geolocator.requestPermission();
  }
  if (perm == LocationPermission.denied ||
      perm == LocationPermission.deniedForever) {
    return const UserPosition(denied: true);
  }
  final pos = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.medium,
      timeLimit: Duration(seconds: 12),
    ),
  );
  return UserPosition(lat: pos.latitude, lng: pos.longitude);
}
