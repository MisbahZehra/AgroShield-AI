class WeatherDay {
  final DateTime date;
  final double tempC;
  final int humidity;
  final int rainChance;
  final String condition;

  const WeatherDay({
    required this.date,
    required this.tempC,
    required this.humidity,
    required this.rainChance,
    required this.condition,
  });
}
