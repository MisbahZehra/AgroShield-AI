import '../data/models/treatment_info.dart';

/// Bundled verified knowledge base: general agronomic guidance per class,
/// plus REAL verified product-level data for wheat rust, rice blast, and
/// cotton pests (sourced from Pakistani agricultural research).
///
/// For classes NOT covered by verified product data, the app shows
/// "Verified treatment information is currently unavailable" rather
/// than guessing.
class DiseaseKnowledgeBase {
  static String displayName(String className) =>
      _info(className).displayName;

  static String cropOf(String className) => _info(className).crop;

  static DiseaseInfo info(String className) => _info(className);

  /// All class names present in the bundled knowledge table.
  static Iterable<String> get allClassNames => _table.keys;

  /// Returns treatment info for [className]. If verified product data
  /// exists (wheat rust, rice blast, cotton pests), it is included.
  /// Otherwise only general guidance is returned with hasVerifiedInfo=false
  /// so the UI shows the "unavailable" fallback.
  static TreatmentInfo treatment(String className) {
    final i = _info(className);
    if (i.category == 'healthy') {
      return TreatmentInfo(
        className: className,
        actions: [
          'No disease detected. Continue regular field monitoring.',
          'Keep balanced irrigation and fertilisation practices.',
        ],
        preventive: [
          'Scout the field weekly for early symptoms.',
          'Use certified seed and resistant varieties.',
        ],
        organic: [
          'Maintain crop rotation and field sanitation.',
        ],
        hasVerifiedInfo: true,
      );
    }
    // Check for verified product-level data
    final verified = _verifiedTreatments[className];
    if (verified != null) return verified;
    // No verified product data — general guidance only
    return TreatmentInfo(
      className: className,
      actions: _actions(i),
      preventive: _preventive(i),
      organic: _organic(i),
      hasVerifiedInfo: false,
    );
  }

  /// Look up verified treatment by class name (for assistant / RAG).
  static TreatmentInfo? verifiedTreatment(String className) =>
      _verifiedTreatments[className];

  static List<String> _actions(DiseaseInfo i) {
    switch (i.category) {
      case 'fungal':
        return [
          'Remove and destroy heavily infected leaves and plant debris.',
          'Avoid overhead irrigation; water at the base in the morning.',
          'Ask your extension office about a registered fungicide suitable for ${i.displayName} and apply strictly per label.',
        ];
      case 'bacterial':
        return [
          'Remove severely infected plants to reduce spread.',
          'Avoid working in the field while foliage is wet.',
          'Ask your extension office about approved copper-based options for bacterial diseases.',
        ];
      case 'viral':
        return [
          'Uproot and destroy infected plants; there is no cure for viral diseases.',
          'Control the insect vectors (whitefly/aphids) that spread the virus.',
          'Plant resistant or tolerant varieties next season.',
        ];
      case 'pest':
        return [
          'Inspect the undersides of leaves and remove heavy infestations.',
          'Use a strong water spray to dislodge pests where practical.',
          'Ask your extension office about a registered miticide/insecticide if damage spreads.',
        ];
      default:
        return [];
    }
  }

  static List<String> _preventive(DiseaseInfo i) => [
        'Use certified disease-free seed and resistant varieties.',
        'Rotate crops and keep the field free of volunteer plants and debris.',
        'Maintain proper plant spacing for airflow.',
        'Apply balanced fertilisation; excess nitrogen increases ${i.category == 'fungal' ? 'fungal' : 'disease'} pressure.',
      ];

  static List<String> _organic(DiseaseInfo i) {
    switch (i.category) {
      case 'fungal':
        return [
          'Neem oil extracts can suppress early fungal pressure (follow label).',
          'Sulphur-based organic fungicides are commonly used for rusts and mildews.',
        ];
      case 'bacterial':
        return [
          'Copper-based organic bactericides may reduce spread when used early (follow label).',
        ];
      case 'viral':
        return [
          'Reflective mulches and yellow sticky traps reduce whitefly/aphid vectors.',
        ];
      case 'pest':
        return [
          'Neem oil and insecticidal soaps are effective organic options for mites and small insects.',
          'Encourage natural predators such as ladybirds.',
        ];
      default:
        return [];
    }
  }

  static DiseaseInfo _info(String className) =>
      _table[className] ??
      DiseaseInfo(
        className: className,
        displayName: className.replaceAll('_', ' '),
        crop: className.split('_').first,
        category: 'fungal',
        about: 'No detailed description bundled for this class.',
        symptoms: const [],
      );

  static const Map<String, DiseaseInfo> _table = {
    'corn_blight': DiseaseInfo(
      className: 'corn_blight',
      displayName: 'Corn Blight',
      crop: 'corn',
      category: 'fungal',
      about:
          'A fungal leaf blight of maize producing large grey-green lesions that dry out and reduce yield.',
      symptoms: [
        'Long grey-green lesions on leaves',
        'Lesions turn tan with dark borders',
        'Leaves dry from the tip downwards',
      ],
    ),
    'corn_common_rust': DiseaseInfo(
      className: 'corn_common_rust',
      displayName: 'Corn Common Rust',
      crop: 'corn',
      category: 'fungal',
      about:
          'A widespread fungal disease producing cinnamon-brown powdery pustules on both leaf surfaces.',
      symptoms: [
        'Small reddish-brown pustules on both leaf sides',
        'Pustules turn brown-black late in season',
        'Yellowing around heavy infections',
      ],
    ),
    'corn_gray_leaf_spot': DiseaseInfo(
      className: 'corn_gray_leaf_spot',
      displayName: 'Corn Gray Leaf Spot',
      crop: 'corn',
      category: 'fungal',
      about:
          'Fungal disease with rectangular grey-tan lesions confined between leaf veins; favoured by humid weather.',
      symptoms: [
        'Narrow rectangular grey lesions between veins',
        'Lesions merge and kill whole leaves',
        'Starts on lower leaves and moves up',
      ],
    ),
    'corn_healthy': DiseaseInfo(
      className: 'corn_healthy',
      displayName: 'Healthy Corn',
      crop: 'corn',
      category: 'healthy',
      about: 'No disease signs detected on this maize leaf.',
      symptoms: [],
    ),
    'rice_bacterial_leaf_blight': DiseaseInfo(
      className: 'rice_bacterial_leaf_blight',
      displayName: 'Rice Bacterial Leaf Blight',
      crop: 'rice',
      category: 'bacterial',
      about:
          'A serious bacterial disease; water-soaked stripes start at the leaf tip and turn yellow-white.',
      symptoms: [
        'Water-soaked streaks from the leaf tip',
        'Yellow to white drying of the leaf blade',
        'Milky dew-like drops on young lesions',
      ],
    ),
    'rice_brown_spot': DiseaseInfo(
      className: 'rice_brown_spot',
      displayName: 'Rice Brown Spot',
      crop: 'rice',
      category: 'fungal',
      about:
          'Fungal disease causing oval brown spots with grey centres; often worse in nutrient-poor fields.',
      symptoms: [
        'Oval brown spots with grey centres',
        'Dark border around each spot',
        'Grains may show dark discolouration',
      ],
    ),
    'rice_healthy_rice_leaf': DiseaseInfo(
      className: 'rice_healthy_rice_leaf',
      displayName: 'Healthy Rice',
      crop: 'rice',
      category: 'healthy',
      about: 'No disease signs detected on this rice leaf.',
      symptoms: [],
    ),
    'rice_hispa': DiseaseInfo(
      className: 'rice_hispa',
      displayName: 'Rice Hispa (Pest)',
      crop: 'rice',
      category: 'pest',
      about:
          'A beetle pest; adults scrape the leaf surface leaving white streaks, larvae mine inside the leaf.',
      symptoms: [
        'White translucent feeding streaks',
        'Shortened leaves with scraped surface',
        'Small dark beetles on young leaves',
      ],
    ),
    'rice_leaf_blast': DiseaseInfo(
      className: 'rice_leaf_blast',
      displayName: 'Rice Leaf Blast',
      crop: 'rice',
      category: 'fungal',
      about:
          'The most damaging rice fungal disease; spindle-shaped lesions with grey centres '
          'and brown borders. At panicle stage, neck rot can break the panicle.',
      symptoms: [
        'Diamond/spindle shaped lesions with grey centres',
        'Brown margin around each lesion',
        'Neck rot at panicle stage',
        'Neck infection can break the panicle',
      ],
    ),
    'rice_leaf_scald': DiseaseInfo(
      className: 'rice_leaf_scald',
      displayName: 'Rice Leaf Scald',
      crop: 'rice',
      category: 'fungal',
      about:
          'Fungal disease producing tan scalded zones with dark brown margins from the leaf tip or edge.',
      symptoms: [
        'Tan lesions starting at leaf tip/margin',
        'Concentric zones with dark brown border',
        'Leaf tip dries and turns straw coloured',
      ],
    ),
    'rice_narrow_brown_leaf_spot': DiseaseInfo(
      className: 'rice_narrow_brown_leaf_spot',
      displayName: 'Rice Narrow Brown Leaf Spot',
      crop: 'rice',
      category: 'fungal',
      about:
          'Fungal disease causing narrow brown spots aligned with the veins, common in low-potassium soils.',
      symptoms: [
        'Narrow brown spots along veins',
        'Spots may join into long stripes',
        'Leaf sheath shows brown net pattern',
      ],
    ),
    'rice_sheath_blight': DiseaseInfo(
      className: 'rice_sheath_blight',
      displayName: 'Rice Sheath Blight',
      crop: 'rice',
      category: 'fungal',
      about:
          'Fungal disease of the sheath and leaf blade with oval greenish-grey lesions; favoured by dense planting.',
      symptoms: [
        'Oval grey-green lesions on the sheath',
        'White mycelium visible in humid weather',
        'Lesions climb from sheath to blade',
      ],
    ),
    'sugarcane_healthy': DiseaseInfo(
      className: 'sugarcane_healthy',
      displayName: 'Healthy Sugarcane',
      crop: 'sugarcane',
      category: 'healthy',
      about: 'No disease signs detected on this sugarcane leaf.',
      symptoms: [],
    ),
    'sugarcane_mosaic': DiseaseInfo(
      className: 'sugarcane_mosaic',
      displayName: 'Sugarcane Mosaic (Virus)',
      crop: 'sugarcane',
      category: 'viral',
      about:
          'A viral disease producing light and dark green mosaic patterns; spread by aphids.',
      symptoms: [
        'Mosaic of light and dark green on young leaves',
        'Chlorotic streaks along the veins',
        'Stunted, weak cane growth',
      ],
    ),
    'sugarcane_redrot': DiseaseInfo(
      className: 'sugarcane_redrot',
      displayName: 'Sugarcane Red Rot',
      crop: 'sugarcane',
      category: 'fungal',
      about:
          'A serious stalk disease; internal tissue turns red with white patches while leaves yellow and dry.',
      symptoms: [
        'Yellowing and drying of older leaves',
        'Red internal cane tissue with white patches',
        'Cane may smell alcoholic when split',
      ],
    ),
    'sugarcane_rust': DiseaseInfo(
      className: 'sugarcane_rust',
      displayName: 'Sugarcane Rust',
      crop: 'sugarcane',
      category: 'fungal',
      about:
          'Fungal disease producing orange-brown pustules on the underside of leaves in warm humid weather.',
      symptoms: [
        'Yellow spots turning orange-brown',
        'Dusty rust pustules on leaf underside',
        'Severe cases dry the whole leaf',
      ],
    ),
    'sugarcane_yellow': DiseaseInfo(
      className: 'sugarcane_yellow',
      displayName: 'Sugarcane Yellow Leaf',
      crop: 'sugarcane',
      category: 'viral',
      about:
          'A viral disease first showing intense yellowing of the leaf midrib, then of the whole leaf.',
      symptoms: [
        'Bright yellow midrib on mature leaves',
        'Yellowing spreads from midrib outward',
        'Reduced cane vigour and yield',
      ],
    ),
    'tomato_bacterial_spot': DiseaseInfo(
      className: 'tomato_bacterial_spot',
      displayName: 'Tomato Bacterial Spot',
      crop: 'tomato',
      category: 'bacterial',
      about:
          'Bacterial disease causing small dark water-soaked spots on leaves and rough spots on fruit.',
      symptoms: [
        'Small water-soaked dark spots',
        'Spots turn brown with yellow halo',
        'Rough scabby spots on fruit',
      ],
    ),
    'tomato_early_blight': DiseaseInfo(
      className: 'tomato_early_blight',
      displayName: 'Tomato Early Blight',
      crop: 'tomato',
      category: 'fungal',
      about:
          'Fungal disease of older leaves producing brown target-like rings with concentric circles.',
      symptoms: [
        'Brown spots with concentric rings (target board)',
        'Yellowing around the spots',
        'Starts on lower, older leaves',
      ],
    ),
    'tomato_healthy': DiseaseInfo(
      className: 'tomato_healthy',
      displayName: 'Healthy Tomato',
      crop: 'tomato',
      category: 'healthy',
      about: 'No disease signs detected on this tomato leaf.',
      symptoms: [],
    ),
    'tomato_late_blight': DiseaseInfo(
      className: 'tomato_late_blight',
      displayName: 'Tomato Late Blight',
      crop: 'tomato',
      category: 'fungal',
      about:
          'A fast, destructive disease causing large pale water-soaked patches that turn brown in cool wet weather.',
      symptoms: [
        'Large pale green water-soaked patches',
        'Patches turn brown and brittle',
        'White fuzzy growth under leaves in humidity',
      ],
    ),
    'tomato_leaf_mold': DiseaseInfo(
      className: 'tomato_leaf_mold',
      displayName: 'Tomato Leaf Mold',
      crop: 'tomato',
      category: 'fungal',
      about:
          'Fungal disease of protected tomato; pale yellow spots above with olive-grey mould beneath.',
      symptoms: [
        'Pale yellow spots on upper leaf surface',
        'Olive-grey mould on the underside',
        'Leaves curl and dry in heavy infection',
      ],
    ),
    'tomato_mosaic_virus': DiseaseInfo(
      className: 'tomato_mosaic_virus',
      displayName: 'Tomato Mosaic Virus',
      crop: 'tomato',
      category: 'viral',
      about:
          'A highly contagious virus causing mosaic mottling, distorted leaves and reduced fruit.',
      symptoms: [
        'Light/dark green mosaic mottling',
        'Distorted, fern-like young leaves',
        'Stunted plant with reduced fruit',
      ],
    ),
    'tomato_septoria_leaf_spot': DiseaseInfo(
      className: 'tomato_septoria_leaf_spot',
      displayName: 'Tomato Septoria Leaf Spot',
      crop: 'tomato',
      category: 'fungal',
      about:
          'Fungal disease producing many small circular spots with dark edges and tan centres on lower leaves.',
      symptoms: [
        'Many small round spots with dark border',
        'Tan-grey centre with tiny black dots',
        'Lower leaves yellow and drop early',
      ],
    ),
    'tomato_target_spot': DiseaseInfo(
      className: 'tomato_target_spot',
      displayName: 'Tomato Target Spot',
      crop: 'tomato',
      category: 'fungal',
      about:
          'Fungal disease with target-like brown lesions surrounded by a yellow halo.',
      symptoms: [
        'Brown lesions with concentric rings',
        'Pronounced yellow halo around spots',
        'Fruit may show sunken dark lesions',
      ],
    ),
    'tomato_twospotted_spider_mite': DiseaseInfo(
      className: 'tomato_twospotted_spider_mite',
      displayName: 'Tomato Spider Mite (Pest)',
      crop: 'tomato',
      category: 'pest',
      about:
          'Tiny sap-sucking mites causing fine yellow stippling, bronzing and webbing on the underside.',
      symptoms: [
        'Fine yellow specks (stippling) on leaves',
        'Silky webbing on the underside',
        'Leaves bronze and dry in heavy attack',
      ],
    ),
    'tomato_yellow_leaf_curl_virus': DiseaseInfo(
      className: 'tomato_yellow_leaf_curl_virus',
      displayName: 'Tomato Yellow Leaf Curl Virus',
      crop: 'tomato',
      category: 'viral',
      about:
          'Whitefly-transmitted virus causing upward leaf curling, yellowing and severe stunting.',
      symptoms: [
        'Upward cupping and curling of leaves',
        'Yellow margins on young leaves',
        'Stunted plant with few fruits',
      ],
    ),
    'wheat_brownrust': DiseaseInfo(
      className: 'wheat_brownrust',
      displayName: 'Wheat Brown Rust',
      crop: 'wheat',
      category: 'fungal',
      about:
          'Fungal disease with scattered orange-brown pustules on the upper leaf surface. '
          'Spreads rapidly in humid weather; can cause significant yield loss if untreated.',
      symptoms: [
        'Orange-brown pustules on upper surface',
        'Pustules scattered randomly',
        'Spreading in humid weather',
        'Leaves yellow and dry early',
      ],
    ),
    'wheat_healthy': DiseaseInfo(
      className: 'wheat_healthy',
      displayName: 'Healthy Wheat',
      crop: 'wheat',
      category: 'healthy',
      about: 'No disease signs detected on this wheat leaf.',
      symptoms: [],
    ),
    'wheat_mildew': DiseaseInfo(
      className: 'wheat_mildew',
      displayName: 'Wheat Powdery Mildew',
      crop: 'wheat',
      category: 'fungal',
      about:
          'Fungal disease producing white powdery growth on leaves and stems in dense, humid crops.',
      symptoms: [
        'White powdery patches on leaves',
        'Patches turn grey with black dots later',
        'Yellowing of infected leaves',
      ],
    ),
    'wheat_septoria': DiseaseInfo(
      className: 'wheat_septoria',
      displayName: 'Wheat Septoria',
      crop: 'wheat',
      category: 'fungal',
      about:
          'Fungal leaf blotch with oval tan lesions containing rows of tiny black fruiting bodies.',
      symptoms: [
        'Oval tan lesions on leaves',
        'Tiny black dots inside lesions',
        'Lower leaves affected first',
      ],
    ),
    'wheat_yellowrust': DiseaseInfo(
      className: 'wheat_yellowrust',
      displayName: 'Wheat Yellow Rust',
      crop: 'wheat',
      category: 'fungal',
      about:
          'Fungal disease forming yellow pustules in distinct stripes along the leaf veins. '
          'Also called stripe rust; favoured by cool temperatures and high humidity.',
      symptoms: [
        'Yellow pustules in stripes along veins',
        'Stripes run parallel to the leaf edge',
        'Appears in humid weather',
        'Severe cases dry the whole leaf',
      ],
    ),
  };

  // ──────────────────────────────────────────────────────────────────────
  // VERIFIED PRODUCT-LEVEL TREATMENT DATA
  // Sourced from Pakistani agricultural research and field trials.
  // Only these classes have verified product recommendations.
  // All other classes show "Verified treatment information is currently
  // unavailable" — the app never extrapolates beyond this data.
  // ──────────────────────────────────────────────────────────────────────

  static const Map<String, TreatmentInfo> _verifiedTreatments = {
    // ── ENTRY 1: Wheat Rust (leaf/stripe/stem rust) ──
    'wheat_brownrust': TreatmentInfo(
      className: 'wheat_brownrust',
      actions: [
        'Apply Propiconazole (commercial name: Tilt) at first sign of infection.',
        'Dose: 3 mL per 1500 mL water.',
        'Repeat application per product label interval.',
        'Remove and destroy heavily infected leaves and plant debris.',
      ],
      preventive: [
        'Use rust-resistant wheat varieties.',
        'Avoid excessive nitrogen fertilizer.',
        'Field scouting during humid weeks for early detection.',
      ],
      organic: [
        'Sulphur-based organic fungicides are commonly used for rusts (follow label).',
      ],
      hasVerifiedInfo: true,
      products: [
        ProductRecommendation(
          name: 'Tilt',
          activeIngredient: 'Propiconazole',
          dose: '3 mL per 1500 mL water',
          timing: 'Apply at first sign of infection; repeat per product label interval',
        ),
      ],
      source:
          'Peer-reviewed study, Muhammad Nawaz Shareef University of Agriculture, Multan, Pakistan',
    ),
    'wheat_yellowrust': TreatmentInfo(
      className: 'wheat_yellowrust',
      actions: [
        'Apply Propiconazole (commercial name: Tilt) at first sign of infection.',
        'Dose: 3 mL per 1500 mL water.',
        'Repeat application per product label interval.',
        'Remove and destroy heavily infected leaves and plant debris.',
      ],
      preventive: [
        'Use rust-resistant wheat varieties.',
        'Avoid excessive nitrogen fertilizer.',
        'Field scouting during humid weeks for early detection.',
      ],
      organic: [
        'Sulphur-based organic fungicides are commonly used for rusts (follow label).',
      ],
      hasVerifiedInfo: true,
      products: [
        ProductRecommendation(
          name: 'Tilt',
          activeIngredient: 'Propiconazole',
          dose: '3 mL per 1500 mL water',
          timing: 'Apply at first sign of infection; repeat per product label interval',
        ),
      ],
      source:
          'Peer-reviewed study, Muhammad Nawaz Shareef University of Agriculture, Multan, Pakistan',
    ),

    // ── ENTRY 2: Rice Blast ──
    'rice_leaf_blast': TreatmentInfo(
      className: 'rice_leaf_blast',
      actions: [
        'Apply one of the following verified fungicides:',
        'Nativo 75% WP \u2014 65 grams per acre.',
        'Recado Ultra 40% SC \u2014 200 mL per acre.',
        'Amistar Top 325 SC \u2014 200 mL per acre.',
        'Apply at first sign of diamond-shaped lesions.',
      ],
      preventive: [
        'Avoid excess nitrogen fertilisation.',
        'Ensure good field drainage.',
        'Use resistant varieties where available.',
      ],
      organic: [
        'Neem oil extracts can suppress early fungal pressure (follow label).',
      ],
      hasVerifiedInfo: true,
      products: [
        ProductRecommendation(
          name: 'Nativo 75% WP',
          activeIngredient: 'Tebuconazole + Trifloxystrobin',
          dose: '65 grams per acre',
          timing: 'Apply at first sign of infection',
        ),
        ProductRecommendation(
          name: 'Recado Ultra 40% SC',
          activeIngredient: 'Dimoxystrobin + Epoxiconazole',
          dose: '200 mL per acre',
          timing: 'Apply at first sign of infection',
        ),
        ProductRecommendation(
          name: 'Amistar Top 325 SC',
          activeIngredient: 'Azoxystrobin + Difenoconazole',
          dose: '200 mL per acre',
          timing: 'Apply at first sign of infection',
        ),
      ],
      source:
          'Pakistani agricultural field trial (rice blast fungicide efficacy study)',
    ),

    // ── ENTRY 3: Cotton Bollworm / Whitefly / Thrips ──
    // Note: cotton classes are not in the current TFLite model, but this
    // data is available for the assistant when users ask about cotton pests.
    'cotton_bollworm': TreatmentInfo(
      className: 'cotton_bollworm',
      actions: [
        'Apply Lufenuron 5% EC.',
        'Dose: 40\u2013330 mL per acre (use lower end for early/light infestation, '
            'higher end for severe infestation, per product label).',
        'Inspect bolls for boring damage; treat at threshold.',
      ],
      preventive: [
        'Use pheromone traps for early detection.',
        'Regular field scouting.',
        'Avoid overuse of broad-spectrum insecticides (resistance risk).',
      ],
      organic: [
        'Encourage natural predators (parasitoid wasps, ladybirds).',
        'Neem-based botanical insecticides for light infestations.',
      ],
      hasVerifiedInfo: true,
      products: [
        ProductRecommendation(
          name: 'Lufenuron 5% EC',
          activeIngredient: 'Lufenuron',
          dose: '40\u2013330 mL per acre',
          timing: 'Use lower end for early infestation; higher end for severe; per product label',
        ),
      ],
      source:
          'Pakistan-based agrochemical supplier product data sheet',
    ),
    'cotton_whitefly': TreatmentInfo(
      className: 'cotton_whitefly',
      actions: [
        'Apply Lufenuron 5% EC.',
        'Dose: 40\u2013330 mL per acre (per product label).',
        'Check leaf undersides for tiny white insects.',
      ],
      preventive: [
        'Use yellow sticky traps for monitoring.',
        'Avoid overuse of broad-spectrum insecticides (resistance risk).',
        'Field scouting for early detection.',
      ],
      organic: [
        'Neem oil and insecticidal soaps for light infestations.',
        'Encourage natural predators such as ladybirds and lacewings.',
      ],
      hasVerifiedInfo: true,
      products: [
        ProductRecommendation(
          name: 'Lufenuron 5% EC',
          activeIngredient: 'Lufenuron',
          dose: '40\u2013330 mL per acre',
          timing: 'Per product label; lower end for light, higher for severe',
        ),
      ],
      source:
          'Pakistan-based agrochemical supplier product data sheet',
    ),
    'cotton_thrips': TreatmentInfo(
      className: 'cotton_thrips',
      actions: [
        'Apply Lufenuron 5% EC.',
        'Dose: 40\u2013330 mL per acre (per product label).',
        'Look for silvery streaks on leaves as diagnostic sign.',
      ],
      preventive: [
        'Use blue sticky traps for monitoring.',
        'Avoid overuse of broad-spectrum insecticides (resistance risk).',
        'Field scouting for early detection.',
      ],
      organic: [
        'Neem oil and insecticidal soaps for light infestations.',
        'Encourage natural predators (predatory mites, lacewings).',
      ],
      hasVerifiedInfo: true,
      products: [
        ProductRecommendation(
          name: 'Lufenuron 5% EC',
          activeIngredient: 'Lufenuron',
          dose: '40\u2013330 mL per acre',
          timing: 'Per product label; lower end for light, higher for severe',
        ),
      ],
      source:
          'Pakistan-based agrochemical supplier product data sheet',
    ),
  };
}
