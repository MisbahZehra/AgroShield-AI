import '../../domain/repositories/recommendation_repository.dart';
import '../../knowledge/disease_knowledge_base.dart';
import '../models/treatment_info.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  @override
  TreatmentInfo treatmentFor(String className) =>
      DiseaseKnowledgeBase.treatment(className);

  @override
  DiseaseInfo diseaseInfoFor(String className) =>
      DiseaseKnowledgeBase.info(className);
}
