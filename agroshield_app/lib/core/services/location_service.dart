// ignore_for_file: deprecated_member_use
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

/// Result of a location lookup.
class LocationResult {
  final double latitude;
  final double longitude;
  final String name;
  final bool isGps; // true = real GPS, false = fallback default

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.isGps,
  });
}

/// Handles runtime location permission, GPS coordinates, and reverse
/// geocoding via the OpenWeather geocoding API.
class LocationService {
  final http.Client _client;

  LocationService({http.Client? client}) : _client = client ?? http.Client();

  /// Attempts to get the device's real GPS location.
  /// Falls back to the default (Sindh, Pakistan) when:
  ///   - permission is denied
  ///   - location services are disabled
  ///   - the position cannot be determined
  Future<LocationResult> getCurrentLocation() async {
    try {
      // 1. Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return _fallback();

      // 2. Check / request permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return _fallback();
      }
      if (permission == LocationPermission.deniedForever) return _fallback();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // 3. Get current position
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        );

        // 4. Reverse geocode to get city name
        final cityName = await _reverseGeocode(
          position.latitude,
          position.longitude,
        );

        return LocationResult(
          latitude: position.latitude,
          longitude: position.longitude,
          name: cityName,
          isGps: true,
        );
      }
    } catch (_) {
      // Any failure -> graceful fallback
    }
    return _fallback();
  }

  /// Reverse geocode using OpenWeather's geocoding API.
  Future<String> _reverseGeocode(double lat, double lon) async {
    final key = AppConstants.openWeatherApiKey;
    if (key.isEmpty) return _formatCoords(lat, lon);

    try {
      final uri = Uri.parse(
        'https://api.openweathermap.org/geo/1.0/reverse'
        '?lat=$lat&lon=$lon&limit=1&appid=$key',
      );
      final res = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        if (list.isNotEmpty) {
          final data = list.first as Map<String, dynamic>;
          final city = data['name'] as String?;
          final state = data['state'] as String?;
          final country = data['country'] as String?;
          final parts = [city, state, country]
              .where((s) => s != null && s.isNotEmpty)
              .toList();
          if (parts.isNotEmpty) return parts.join(', ');
        }
      }
    } catch (_) {
      // fall through
    }
    return _formatCoords(lat, lon);
  }

  String _formatCoords(double lat, double lon) =>
      '${lat.toStringAsFixed(2)}N, ${lon.toStringAsFixed(2)}E';

  LocationResult _fallback() => LocationResult(
        latitude: AppConstants.defaultLatitude,
        longitude: AppConstants.defaultLongitude,
        name: AppConstants.defaultLocationName,
        isGps: false,
      );
}
