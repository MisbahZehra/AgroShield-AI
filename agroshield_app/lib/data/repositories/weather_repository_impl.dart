import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/location_service.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/openweather_api.dart';
import '../models/weather_day.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final OpenWeatherApi? _api;
  final LocationService _locationService;

  WeatherRepositoryImpl({LocationService? locationService})
      : _locationService = locationService ?? LocationService(),
        _api = AppConstants.openWeatherApiKey.isEmpty
            ? null
            : OpenWeatherApi(apiKey: AppConstants.openWeatherApiKey);

  @override
  Future<WeatherResult> sevenDayForecast(
      {double? lat, double? lon}) async {
    // If explicit coordinates are passed, use them directly
    double latitude;
    double longitude;
    String locationName;
    bool isGps = false;

    if (lat != null && lon != null) {
      latitude = lat;
      longitude = lon;
      locationName = AppConstants.defaultLocationName;
    } else {
      // Use LocationService to get real GPS or fall back to default
      final loc = await _locationService.getCurrentLocation();
      latitude = loc.latitude;
      longitude = loc.longitude;
      locationName = loc.name;
      isGps = loc.isGps;
    }

    if (_api != null) {
      try {
        final connectivity = await Connectivity()
            .checkConnectivity()
            .timeout(const Duration(seconds: 3));
        if (!connectivity.contains(ConnectivityResult.none)) {
          final days = await _api.fetchDailyForecast(latitude, longitude);
          if (days.isNotEmpty) {
            return WeatherResult(
              days: _padToSeven(days),
              isSample: false,
              locationName: locationName,
            );
          }
        }
      } catch (_) {
        // fall through to clearly labelled sample data
      }
    }
    return WeatherResult(
      days: _padToSeven(MockWeatherRepository.sampleDays()),
      isSample: true,
      locationName: isGps ? locationName : AppConstants.defaultLocationName,
    );
  }

  List<WeatherDay> _padToSeven(List<WeatherDay> days) {
    if (days.length >= 7) return days.sublist(0, 7);
    final padded = List<WeatherDay>.from(days);
    var extra = 1;
    while (padded.length < 7) {
      final last = padded.last;
      padded.add(WeatherDay(
        date: last.date.add(Duration(days: extra)),
        tempC: last.tempC,
        humidity: last.humidity,
        rainChance: last.rainChance,
        condition: last.condition,
      ));
      extra++;
    }
    return padded;
  }
}

/// Clearly labelled offline sample source, used only when the real
/// OpenWeather API is unavailable or unconfigured.
class MockWeatherRepository {
  static List<WeatherDay> sampleDays() {
    final now = DateTime.now();
    const pattern = [
      [31.0, 62, 10, 'Clouds'],
      [33.0, 78, 55, 'Rain'],
      [29.0, 84, 70, 'Rain'],
      [28.0, 80, 45, 'Clouds'],
      [30.0, 70, 20, 'Clear'],
      [32.0, 58, 5, 'Clear'],
      [33.0, 55, 5, 'Clear'],
    ];
    return [
      for (var i = 0; i < 7; i++)
        WeatherDay(
          date: now.add(Duration(days: i)),
          tempC: pattern[i][0] as double,
          humidity: pattern[i][1] as int,
          rainChance: pattern[i][2] as int,
          condition: pattern[i][3] as String,
        ),
    ];
  }
}
