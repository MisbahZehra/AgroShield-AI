class DiseaseInfo {
  final String className;
  final String displayName;
  final String crop;
  final String category;
  final String about;
  final List<String> symptoms;

  const DiseaseInfo({
    required this.className,
    required this.displayName,
    required this.crop,
    required this.category,
    required this.about,
    required this.symptoms,
  });
}

/// A verified pesticide / agrochemical product recommendation.
class ProductRecommendation {
  final String name;
  final String activeIngredient;
  final String dose;
  final String timing;

  const ProductRecommendation({
    required this.name,
    required this.activeIngredient,
    required this.dose,
    required this.timing,
  });
}

class TreatmentInfo {
  final String className;
  final List<String> actions;
  final List<String> preventive;
  final List<String> organic;
  final bool hasVerifiedInfo;

  /// Verified product recommendations (null when no verified data exists).
  final List<ProductRecommendation>? products;

  /// Source citation for the verified data.
  final String? source;

  const TreatmentInfo({
    required this.className,
    required this.actions,
    required this.preventive,
    required this.organic,
    required this.hasVerifiedInfo,
    this.products,
    this.source,
  });

  /// Whether this treatment has verified product-level data.
  bool get hasVerifiedProducts =>
      products != null && products!.isNotEmpty;
}
