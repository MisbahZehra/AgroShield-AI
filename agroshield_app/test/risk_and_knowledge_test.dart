import 'package:agroshield_app/data/repositories/risk_repository_impl.dart';
import 'package:agroshield_app/data/models/risk_day.dart';
import 'package:agroshield_app/data/models/weather_day.dart';
import 'package:agroshield_app/domain/repositories/weather_repository.dart';
import 'package:agroshield_app/knowledge/disease_knowledge_base.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RuleBasedRiskRepository', () {
    final repo = RuleBasedRiskRepository();

    test('humid rainy warm day is high risk', () async {
      final days = await repo.sevenDayRisk(
        weather: WeatherResult(
          days: [
            WeatherDay(
                date: DateTime(2026, 8, 30),
                tempC: 26,
                humidity: 85,
                rainChance: 80,
                condition: 'Rain'),
          ],
          isSample: false,
          locationName: 'test',
        ),
      );
      expect(days.single.level, RiskLevel.high);
    });

    test('dry cool day is low risk', () async {
      final days = await repo.sevenDayRisk(
        weather: WeatherResult(
          days: [
            WeatherDay(
                date: DateTime(2026, 8, 30),
                tempC: 10,
                humidity: 30,
                rainChance: 0,
                condition: 'Clear'),
          ],
          isSample: false,
          locationName: 'test',
        ),
      );
      expect(days.single.level, RiskLevel.low);
    });

    test('score boundaries', () {
      expect(RuleBasedRiskRepository.scoreFor(80, 70, 25), 5);
      expect(RuleBasedRiskRepository.scoreFor(65, 40, 25), 3);
      expect(RuleBasedRiskRepository.scoreFor(20, 0, 40), 0);
    });
  });

  group('Knowledge base', () {
    test('all 32 classes have entries', () {
      const classes = [
        'corn_blight','corn_common_rust','corn_gray_leaf_spot','corn_healthy',
        'rice_bacterial_leaf_blight','rice_brown_spot','rice_healthy_rice_leaf',
        'rice_hispa','rice_leaf_blast','rice_leaf_scald',
        'rice_narrow_brown_leaf_spot','rice_sheath_blight','sugarcane_healthy',
        'sugarcane_mosaic','sugarcane_redrot','sugarcane_rust','sugarcane_yellow',
        'tomato_bacterial_spot','tomato_early_blight','tomato_healthy',
        'tomato_late_blight','tomato_leaf_mold','tomato_mosaic_virus',
        'tomato_septoria_leaf_spot','tomato_target_spot',
        'tomato_twospotted_spider_mite','tomato_yellow_leaf_curl_virus',
        'wheat_brownrust','wheat_healthy','wheat_mildew','wheat_septoria',
        'wheat_yellowrust',
      ];
      for (final c in classes) {
        final info = DiseaseKnowledgeBase.info(c);
        expect(info.displayName, isNot(contains('unknown')));
        expect(info.about, isNotEmpty);
      }
      // All disease classes (non-healthy) must have verified info
      const diseaseClasses = [
        'corn_blight','corn_common_rust','corn_gray_leaf_spot',
        'rice_bacterial_leaf_blight','rice_brown_spot',
        'rice_hispa','rice_leaf_blast','rice_leaf_scald',
        'rice_narrow_brown_leaf_spot','rice_sheath_blight',
        'sugarcane_mosaic','sugarcane_redrot','sugarcane_rust','sugarcane_yellow',
        'tomato_bacterial_spot','tomato_early_blight',
        'tomato_late_blight','tomato_leaf_mold','tomato_mosaic_virus',
        'tomato_septoria_leaf_spot','tomato_target_spot',
        'tomato_twospotted_spider_mite','tomato_yellow_leaf_curl_virus',
        'wheat_brownrust','wheat_mildew','wheat_septoria','wheat_yellowrust',
      ];
      for (final c in diseaseClasses) {
        final t = DiseaseKnowledgeBase.treatment(c);
        expect(t.hasVerifiedInfo, isTrue,
            reason: '$c should have verified info');
        expect(t.source, isNotNull,
            reason: '$c should have a source citation');
      }
      // Classes with products should have hasVerifiedProducts == true
      const classesWithProducts = [
        'corn_blight','corn_common_rust','corn_gray_leaf_spot',
        'rice_bacterial_leaf_blight','rice_brown_spot','rice_hispa',
        'rice_leaf_blast','rice_leaf_scald','rice_narrow_brown_leaf_spot',
        'rice_sheath_blight','sugarcane_redrot','sugarcane_rust',
        'tomato_bacterial_spot','tomato_early_blight','tomato_late_blight',
        'tomato_leaf_mold','tomato_septoria_leaf_spot','tomato_target_spot',
        'tomato_twospotted_spider_mite',
        'wheat_brownrust','wheat_mildew','wheat_septoria','wheat_yellowrust',
      ];
      for (final c in classesWithProducts) {
        final t = DiseaseKnowledgeBase.treatment(c);
        expect(t.hasVerifiedProducts, isTrue,
            reason: '$c should have verified products');
      }
      // Viral classes have verified info but NO products
      const viralClasses = [
        'sugarcane_mosaic','sugarcane_yellow',
        'tomato_mosaic_virus','tomato_yellow_leaf_curl_virus',
      ];
      for (final c in viralClasses) {
        final t = DiseaseKnowledgeBase.treatment(c);
        expect(t.hasVerifiedInfo, isTrue,
            reason: '$c should have verified info');
        expect(t.hasVerifiedProducts, isFalse,
            reason: '$c is viral and should NOT have products');
      }
    });

    test('verified products have correct doses', () {
      // Wheat rust — Propiconazole (Tilt)
      final wheatT = DiseaseKnowledgeBase.treatment('wheat_yellowrust');
      expect(wheatT.products, isNotNull);
      expect(wheatT.products!.first.name, 'Tilt');
      expect(wheatT.products!.first.activeIngredient, 'Propiconazole');
      expect(wheatT.products!.first.dose, contains('3 mL per 1500 mL'));
      expect(wheatT.source, contains('Muhammad Nawaz Shareef'));

      // Rice blast — 3 fungicide options
      final riceT = DiseaseKnowledgeBase.treatment('rice_leaf_blast');
      expect(riceT.products, isNotNull);
      expect(riceT.products!.length, 3);
      expect(riceT.products!.map((p) => p.name),
          containsAll(['Nativo 75% WP', 'Recado Ultra 40% SC', 'Amistar Top 325 SC']));
      expect(riceT.source, contains('Pakistani agricultural field trial'));
    });

    test('healthy classes do not have product data', () {
      final t = DiseaseKnowledgeBase.treatment('corn_healthy');
      expect(t.hasVerifiedProducts, isFalse);
      expect(t.hasVerifiedInfo, isTrue);
    });
  });
}
