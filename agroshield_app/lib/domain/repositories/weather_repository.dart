import '../../data/models/weather_day.dart';

abstract class WeatherRepository {
  /// Returns 7 daily weather summaries. [isSample] is true when the data
  /// comes from the clearly labelled offline sample source.
  Future<WeatherResult> sevenDayForecast({double? lat, double? lon});
}

class WeatherResult {
  final List<WeatherDay> days;
  final bool isSample;
  final String locationName;

  const WeatherResult({
    required this.days,
    required this.isSample,
    required this.locationName,
  });
}
