import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../ai/models/prediction.dart';
import '../ai/preprocessing/image_preprocessor.dart';
import '../ai/severity/severity_service.dart';
import '../ai/tflite/tflite_service.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/location_service.dart';
import '../core/services/tts_service.dart';
import '../core/services/stt_service.dart';
import '../data/models/crop.dart';
import '../data/models/risk_day.dart';
import '../data/models/scan_record.dart';
import '../data/repositories/assistant_repository_impl.dart';
import '../data/repositories/crop_repository_impl.dart';
import '../data/repositories/history_repository_impl.dart';
import '../data/repositories/recommendation_repository_impl.dart';
import '../data/repositories/risk_repository_impl.dart';
import '../data/repositories/settings_repository_impl.dart';
import '../data/repositories/tflite_ai_repository.dart';
import '../data/repositories/weather_repository_impl.dart';
import '../domain/repositories/weather_repository.dart';

final ttsServiceProvider = Provider<TtsService>((ref) => TtsService());
final sttServiceProvider = Provider<SttService>((ref) => SttService());
final connectivityServiceProvider =
    Provider<ConnectivityService>((ref) => ConnectivityService());
final locationServiceProvider =
    Provider<LocationService>((ref) => LocationService());

final aiRepositoryProvider =
    Provider<TFLiteAIRepository>((ref) => TFLiteAIRepository(TFLiteService()));
final historyRepositoryProvider =
    Provider<HistoryRepositoryImpl>((ref) => HistoryRepositoryImpl());
final cropRepositoryProvider =
    Provider<CropRepositoryImpl>((ref) => CropRepositoryImpl());
final settingsRepositoryProvider =
    Provider<SettingsRepositoryImpl>((ref) => SettingsRepositoryImpl());
final recommendationRepositoryProvider = Provider<RecommendationRepositoryImpl>(
    (ref) => RecommendationRepositoryImpl());
final weatherRepositoryProvider = Provider<WeatherRepositoryImpl>(
    (ref) => WeatherRepositoryImpl(
        locationService: ref.read(locationServiceProvider)));
final riskRepositoryProvider = Provider<RuleBasedRiskRepository>(
    (ref) => RuleBasedRiskRepository());
final assistantRepositoryProvider = Provider<SmartAssistantRepository>(
    (ref) => SmartAssistantRepository(
          remote: RemoteAssistantRepository(
            baseUrl: AppConstants.assistantBackendUrl,
          ),
          local: MockAssistantRepository(),
        ));

final modelInitProvider = FutureProvider<void>((ref) async {
  await ref.read(aiRepositoryProvider).initialize();
});

final cropsProvider = FutureProvider<List<Crop>>((ref) async {
  return ref.read(cropRepositoryProvider).all();
});

final historyProvider = FutureProvider<List<ScanRecord>>((ref) async {
  return ref.read(historyRepositoryProvider).all();
});

final weatherProvider = FutureProvider<WeatherResult>((ref) async {
  return ref.read(weatherRepositoryProvider).sevenDayForecast();
});

final riskProvider = FutureProvider<List<RiskDay>>((ref) async {
  final weather = await ref.watch(weatherProvider.future);
  return ref.read(riskRepositoryProvider).sevenDayRisk(weather: weather);
});

/// Orchestrates the real Scan -> Inference -> Result pipeline.
class ScanPipeline {
  final Ref _ref;
  ScanPipeline(this._ref);

  Future<ScanOutcome> run(
    String imagePath, {
    required void Function(ScanStage stage) onStage,
  }) async {
    onStage(ScanStage.decode);
    final bytes = await File(imagePath).readAsBytes();
    final image = ImagePreprocessor.decode(bytes);

    onStage(ScanStage.quality);
    final quality = ImagePreprocessor.checkQuality(image);
    if (!quality.passed) {
      throw ImageQualityException(quality.reason ?? 'quality');
    }

    onStage(ScanStage.preprocess);
    final tensor = ImagePreprocessor.toInputTensor(image);

    onStage(ScanStage.inference);
    final repo = _ref.read(aiRepositoryProvider);
    if (!repo.isReady) await repo.initialize();
    final prediction = repo.predictTensor(tensor);
    final severity = SeverityService().estimate(image);

    onStage(ScanStage.mapping);
    final lowConfidence =
        prediction.confidence < AppConstants.confidenceThreshold;
    String savedPath = imagePath;
    try {
      final docs = await getApplicationDocumentsDirectory();
      final scansDir = Directory(p.join(docs.path, 'scans'));
      await scansDir.create(recursive: true);
      savedPath = p.join(
          scansDir.path, 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await File(imagePath).copy(savedPath);
    } catch (_) {
      savedPath = imagePath;
    }
    String risk = 'unknown';
    try {
      final weather =
          await _ref.read(weatherRepositoryProvider).sevenDayForecast();
      final days = await _ref
          .read(riskRepositoryProvider)
          .sevenDayRisk(weather: weather);
      if (days.isNotEmpty) risk = days.first.level.name;
    } catch (_) {}

    final record = ScanRecord(
      imagePath: savedPath,
      crop: prediction.crop,
      disease: prediction.className,
      confidence: prediction.confidence,
      affectedArea: severity.affectedAreaPercent,
      severity: severity.severityLabel,
      risk: risk,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    final id = await _ref.read(historyRepositoryProvider).save(record);
    onStage(ScanStage.done);
    return ScanOutcome(
      imagePath: savedPath,
      prediction: prediction,
      severity: severity,
      lowConfidence: lowConfidence,
      historyId: id,
    );
  }
}

final scanPipelineProvider = Provider<ScanPipeline>((ref) => ScanPipeline(ref));

final lastScanProvider = StateProvider<ScanOutcome?>((ref) => null);
