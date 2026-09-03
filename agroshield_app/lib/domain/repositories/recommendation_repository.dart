import '../../data/models/treatment_info.dart';

abstract class RecommendationRepository {
  TreatmentInfo treatmentFor(String className);
  DiseaseInfo diseaseInfoFor(String className);
}
