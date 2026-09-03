import '../../data/models/risk_day.dart';
import 'weather_repository.dart';

abstract class RiskRepository {
  /// Phase-1 documented rule-based estimate. Phase-2 XGBoost model can be
  /// swapped in behind this interface without UI changes.
  Future<List<RiskDay>> sevenDayRisk({WeatherResult? weather});
  String get engineName;
}
