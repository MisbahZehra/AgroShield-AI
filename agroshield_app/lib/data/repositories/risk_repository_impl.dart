import '../../domain/repositories/risk_repository.dart';
import '../../domain/repositories/weather_repository.dart';
import '../models/risk_day.dart';

/// Phase-1 documented rule engine.
///
/// Score per day (0-5):
///   humidity >= 75%            +2   (60-74% +1)
///   rain chance >= 60%         +2   (30-59% +1)
///   temperature in 15-32C      +1   (favourable for most fungal pathogens)
/// Risk: 0-1 LOW, 2-3 MEDIUM, >=4 HIGH.
class RuleBasedRiskRepository implements RiskRepository {
  @override
  String get engineName => 'Rule-based estimate (Phase 1)';

  @override
  Future<List<RiskDay>> sevenDayRisk({WeatherResult? weather}) async {
    if (weather == null || weather.days.isEmpty) return [];
    return weather.days.map((d) {
      var score = 0;
      if (d.humidity >= 75) {
        score += 2;
      } else if (d.humidity >= 60) {
        score += 1;
      }
      if (d.rainChance >= 60) {
        score += 2;
      } else if (d.rainChance >= 30) {
        score += 1;
      }
      if (d.tempC >= 15 && d.tempC <= 32) score += 1;
      final level = score <= 1
          ? RiskLevel.low
          : score <= 3
              ? RiskLevel.medium
              : RiskLevel.high;
      return RiskDay(
        date: d.date,
        humidity: d.humidity,
        rainChance: d.rainChance,
        tempC: d.tempC,
        level: level,
      );
    }).toList();
  }

  static int scoreFor(int humidity, int rainChance, double tempC) {
    var score = 0;
    if (humidity >= 75) {
      score += 2;
    } else if (humidity >= 60) {
      score += 1;
    }
    if (rainChance >= 60) {
      score += 2;
    } else if (rainChance >= 30) {
      score += 1;
    }
    if (tempC >= 15 && tempC <= 32) score += 1;
    return score;
  }
}

/// Phase-2 placeholder for a trained XGBoost risk model. Not trained yet;
/// swapping it in later requires no UI changes.
class XGBoostRiskRepository implements RiskRepository {
  @override
  String get engineName => 'XGBoost (Phase 2 - not trained yet)';

  @override
  Future<List<RiskDay>> sevenDayRisk({WeatherResult? weather}) {
    throw UnimplementedError(
        'XGBoost risk model is not trained yet. Use RuleBasedRiskRepository.');
  }
}
