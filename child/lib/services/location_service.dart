/// Deteksi lokasi GPS + reverse geocode ke nama kota (Fase 2).
///
/// Lokasi otomatis via `geolocator`; nama kota dari `geocoding`
/// (geocoder Android). Gagal aman: kembali ke `null` agar pemanggil
/// memakai fallback.
library;

import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double lat;
  final double lon;
  final String cityName;

  const LocationResult({
    required this.lat,
    required this.lon,
    required this.cityName,
  });
}

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// Minta izin lokasi. Mengembalikan `true` bila diizinkan (while-in-use).
  Future<bool> requestPermission() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      return perm == LocationPermission.whileInUse ||
          perm == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  /// Ambil posisi saat ini, dengan timeout [timeout]. Gagal -> null.
  Future<Position?> currentPosition({Duration timeout = const Duration(seconds: 20)}) async {
    if (!await requestPermission()) return null;
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 20),
        ),
      ).timeout(timeout);
    } catch (_) {
      return null;
    }
  }

  /// Deteksi lokasi + nama kota. Gagal -> null.
  Future<LocationResult?> detect() async {
    final pos = await currentPosition();
    if (pos == null) return null;

    var city = '';
    try {
      final marks = await geo.placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (marks.isNotEmpty) {
        final m = marks.first;
        city = m.locality ??
            m.subAdministrativeArea ??
            m.administrativeArea ??
            m.subLocality ??
            '';
      }
    } catch (_) {}

    return LocationResult(
      lat: pos.latitude,
      lon: pos.longitude,
      cityName: city,
    );
  }
}
