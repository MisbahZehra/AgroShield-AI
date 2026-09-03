import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/errors/app_exceptions.dart';
import '../models/weather_day.dart';

/// OpenWeather 5-day/3-hour forecast client, aggregated to daily summaries.
class OpenWeatherApi {
  final String apiKey;
  final http.Client _client;

  OpenWeatherApi({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  Future<List<WeatherDay>> fetchDailyForecast(
      double lat, double lon) async {
    final uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey');
    final res = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) {
      throw NetworkException('Weather service returned ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['list'] as List).cast<Map<String, dynamic>>();
    final byDay = <String, List<Map<String, dynamic>>>{};
    for (final entry in list) {
      final day = (entry['dt_txt'] as String).split(' ').first;
      byDay.putIfAbsent(day, () => []).add(entry);
    }
    return byDay.entries.take(7).map((e) {
      final temps = e.value
          .map((x) => (x['main']['temp'] as num).toDouble())
          .toList();
      final hum = e.value
          .map((x) => (x['main']['humidity'] as num).toInt())
          .toList();
      final rain = e.value
          .map((x) => ((x['pop'] as num?) ?? 0).toDouble())
          .toList();
      final mid = e.value[e.value.length ~/ 2];
      final condition =
          ((mid['weather'] as List).first as Map)['main'] as String;
      return WeatherDay(
        date: DateTime.parse(e.key),
        tempC: temps.reduce((a, b) => a + b) / temps.length,
        humidity: (hum.reduce((a, b) => a + b) / hum.length).round(),
        rainChance:
            (rain.reduce((a, b) => a > b ? a : b) * 100).round(),
        condition: condition,
      );
    }).toList();
  }
}
