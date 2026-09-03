enum RiskLevel { low, medium, high }

class RiskDay {
  final DateTime date;
  final int humidity;
  final int rainChance;
  final double tempC;
  final RiskLevel level;

  const RiskDay({
    required this.date,
    required this.humidity,
    required this.rainChance,
    required this.tempC,
    required this.level,
  });
}
