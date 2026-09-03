import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/repositories/assistant_repository.dart';
import '../../knowledge/disease_knowledge_base.dart';

// ---------------------------------------------------------------------------
// Mock / offline assistant — keyword-matched against the verified knowledge base
// ---------------------------------------------------------------------------

/// Offline assistant grounded ONLY in the bundled verified knowledge base.
/// Uses keyword matching to find the most relevant class for the user's
/// question, then returns verified info from the knowledge base.
/// Supports English and Roman Urdu.
class MockAssistantRepository implements AssistantRepository {
  @override
  Future<String> answer(
    String question, {
    String? lastClassName,
    List<Map<String, String>>? conversationHistory,
    String? scanContext,
  }) async {
    // Resolve pronoun references from conversation history
    final resolvedQuestion =
        _resolvePronouns(question, conversationHistory);
    final rq = resolvedQuestion.toLowerCase();

    // 1. Try to match a specific disease class from the question text
    final matchedClass = _matchClass(rq) ?? lastClassName;

    // 2. Determine the intent of the question
    final intent = _detectIntent(rq);

    // 3. Answer based on intent + matched class
    return _respond(intent, rq, matchedClass);
  }

  // ── Intent detection ──────────────────────────────────────────────────

  static const _infoKeywords = [
    'disease', 'what is', 'kya hai', 'kisam', 'pehchan',
    'symptom', 'sign', 'nishani', 'alamat', 'symptoms',
    'describe', 'batao', 'batayein', 'explain',
  ];
  static const _treatmentKeywords = [
    'protect', 'treat', 'save', 'spray', 'fungicide', 'product',
    'dose', 'medicine', 'ilaj', 'dawai', 'upay', 'upaay',
    'bachao', 'bachane', 'kaise bachaye', 'how to treat',
    'how to save', 'how to protect', 'spray kare', 'spray karna',
    'kya mare', 'konsi dawai',
  ];
  static const _organicKeywords = [
    'organic', 'natural', 'desi ilaj', 'desi', 'be chemicals',
    'without chemical', 'gharelu',
  ];
  static const _preventKeywords = [
    'prevent', 'avoid', 'pehle se', 'roktham', 'rok-tham',
    'bachaav', ' precaution',
  ];
  static const _monitorKeywords = [
    'monitor', 'week', 'risk', 'hafta', 'is hafte', 'this week',
    'mausam', 'weather', 'barish', 'rain',
  ];
  static const _greetKeywords = [
    'hello', 'hi', 'salam', 'assalam', 'aoa',
  ];

  String _detectIntent(String rq) {
    if (_greetKeywords.any((k) => rq.contains(k))) return 'greet';
    if (_treatmentKeywords.any((k) => rq.contains(k))) return 'treat';
    if (_organicKeywords.any((k) => rq.contains(k))) return 'organic';
    if (_preventKeywords.any((k) => rq.contains(k))) return 'prevent';
    if (_monitorKeywords.any((k) => rq.contains(k))) return 'monitor';
    if (_infoKeywords.any((k) => rq.contains(k))) return 'info';
    return 'general';
  }

  // ── Class matching from keywords ──────────────────────────────────────

  /// Maps crop keywords to crop prefix used in class names.
  static const _cropKeywords = <String, List<String>>{
    'wheat': ['wheat', 'gehun', 'gehu', 'kanak'],
    'rice': ['rice', 'chawal', 'dhaan', 'paddy'],
    'corn': ['corn', 'maize', 'bhutta', 'makka'],
    'tomato': ['tomato', 'tamatar', 'tamater'],
    'sugarcane': ['sugarcane', 'sugar cane', 'ganna', 'ganne'],
    'cotton': ['cotton', 'kapas'],
  };

  /// Maps disease keywords to class-name fragments.
  static const _diseaseKeywords = <String, String>{
    'brown rust': 'brownrust',
    'brownrust': 'brownrust',
    'yellow rust': 'yellowrust',
    'yellowrust': 'yellowrust',
    'stripe rust': 'yellowrust',
    'stem rust': 'brownrust',
    'leaf rust': 'brownrust',
    'rust': 'rust', // generic — resolved per crop
    'blast': 'leaf_blast',
    'leaf blast': 'leaf_blast',
    'blight': 'blight', // generic
    'early blight': 'early_blight',
    'late blight': 'late_blight',
    'bacterial leaf blight': 'bacterial_leaf_blight',
    'bacterial spot': 'bacterial_spot',
    'gray leaf spot': 'gray_leaf_spot',
    'grey leaf spot': 'gray_leaf_spot',
    'brown spot': 'brown_spot',
    'narrow brown': 'narrow_brown_leaf_spot',
    'sheath blight': 'sheath_blight',
    'leaf scald': 'leaf_scald',
    'hispa': 'hispa',
    'mildew': 'mildew',
    'powdery mildew': 'mildew',
    'septoria': 'septoria',
    'septoria leaf': 'septoria_leaf_spot',
    'mosaic': 'mosaic',
    'red rot': 'redrot',
    'redrot': 'redrot',
    'leaf mold': 'leaf_mold',
    'leaf mould': 'leaf_mold',
    'leaf curl': 'yellow_leaf_curl_virus',
    'yellow leaf curl': 'yellow_leaf_curl_virus',
    'target spot': 'target_spot',
    'mite': 'twospotted_spider_mite',
    'spider mite': 'twospotted_spider_mite',
    'bollworm': 'cotton_bollworm',
    'whitefly': 'cotton_whitefly',
    'thrips': 'cotton_thrips',
    'scald': 'leaf_scald',
  };

  /// Try to find the best matching class name from the question text.
  String? _matchClass(String rq) {
    // Detect crop from keywords
    String? detectedCrop;
    for (final entry in _cropKeywords.entries) {
      if (entry.value.any((kw) => rq.contains(kw))) {
        detectedCrop = entry.key;
        break;
      }
    }

    // Detect disease from keywords (try longer phrases first)
    String? detectedDiseaseFragment;
    final sortedKeys = _diseaseKeywords.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final kw in sortedKeys) {
      if (rq.contains(kw)) {
        detectedDiseaseFragment = _diseaseKeywords[kw];
        break;
      }
    }

    if (detectedCrop != null && detectedDiseaseFragment != null) {
      // Both crop + disease detected — find exact class
      final candidate = '${detectedCrop}_$detectedDiseaseFragment';
      if (_classExists(candidate)) return candidate;
      // Try partial match
      final all = DiseaseKnowledgeBase.allClassNames;
      final match = all.where(
          (c) => c.startsWith(detectedCrop!) && c.contains(detectedDiseaseFragment!));
      if (match.isNotEmpty) return match.first;
    }
    if (detectedDiseaseFragment != null) {
      // Disease only — try to find across all crops
      final all = DiseaseKnowledgeBase.allClassNames;
      final match = all.where((c) => c.contains(detectedDiseaseFragment!));
      if (match.isNotEmpty) return match.first;
    }
    if (detectedCrop != null) {
      // Crop only — check if asking about healthy
      if (rq.contains('healthy') || rq.contains('sehat')) {
        return '${detectedCrop}_healthy';
      }
      // Return first disease class for that crop
      final all = DiseaseKnowledgeBase.allClassNames;
      final diseases = all
          .where((c) => c.startsWith(detectedCrop!) && !c.contains('healthy'));
      if (diseases.isNotEmpty) return diseases.first;
    }
    return null;
  }

  bool _classExists(String className) =>
      DiseaseKnowledgeBase.allClassNames.contains(className);

  // ── Response builder ──────────────────────────────────────────────────

  String _respond(String intent, String rq, String? matchedClass) {
    switch (intent) {
      case 'greet':
        return 'Assalam-o-Alaikum! I am AgroShield AI. '
            'You can ask me about crop diseases, treatments, prevention, '
            'or scan a leaf for diagnosis. '
            '(e.g. "wheat rust ka ilaj" or "how to treat rice blast")';

      case 'treat':
        if (matchedClass != null) {
          final t = DiseaseKnowledgeBase.treatment(matchedClass);
          final name = DiseaseKnowledgeBase.displayName(matchedClass);
          if (t.hasVerifiedProducts) {
            final products = t.products!.map((p) =>
                '${p.name} (${p.activeIngredient}) \u2014 ${p.dose}. ${p.timing}.')
                .join('\n');
            final source = t.source != null ? '\nSource: ${t.source}' : '';
            return 'Verified recommendation for $name:\n$products\n'
                'Prevention: ${t.preventive.join('. ')}$source';
          }
          if (t.hasVerifiedInfo) {
            return 'Treatment for $name:\n${t.actions.join('\n')}\n'
                'Prevention: ${t.preventive.join('. ')}';
          }
          return 'Verified treatment information is currently unavailable '
              'for $name. Please consult your local agricultural extension '
              'office for chemical recommendations.';
        }
        return 'Please scan a leaf first so I can identify the disease, '
            'or mention a specific crop and disease (e.g. "wheat rust treatment").';

      case 'organic':
        if (matchedClass != null) {
          final t = DiseaseKnowledgeBase.treatment(matchedClass);
          final name = DiseaseKnowledgeBase.displayName(matchedClass);
          if (t.organic.isNotEmpty) {
            return 'Organic options for $name:\n${t.organic.join('\n')}';
          }
        }
        return 'General organic options:\n'
            '\u2022 Neem oil extracts for fungal diseases\n'
            '\u2022 Insecticidal soaps for pests\n'
            '\u2022 Copper-based organic bactericides\n'
            'Always follow label instructions.';

      case 'prevent':
        if (matchedClass != null) {
          final t = DiseaseKnowledgeBase.treatment(matchedClass);
          final name = DiseaseKnowledgeBase.displayName(matchedClass);
          return 'Prevention for $name:\n${t.preventive.join('\n')}';
        }
        return 'General prevention tips:\n'
            '\u2022 Use certified disease-free seed and resistant varieties\n'
            '\u2022 Rotate crops each season\n'
            '\u2022 Maintain proper plant spacing for airflow\n'
            '\u2022 Scout fields weekly for early symptoms';

      case 'monitor':
        return 'This week, monitor humidity and rain in the 7-Day Risk screen. '
            'High humidity with rain favours fungal diseases \u2014 scout leaves '
            'after wet days and scan any suspicious leaf.';

      case 'info':
        if (matchedClass != null) {
          final info = DiseaseKnowledgeBase.info(matchedClass);
          final symptoms = info.symptoms.isEmpty
              ? ''
              : '\nCommon signs:\n${info.symptoms.map((s) => '\u2022 $s').join('\n')}';
          return '${info.displayName} (${info.category})\n${info.about}$symptoms';
        }
        return 'I can identify diseases in wheat, rice, corn, tomato, and sugarcane. '
            'Scan a leaf or ask about a specific crop disease.';

      default: // 'general'
        if (matchedClass != null) {
          final info = DiseaseKnowledgeBase.info(matchedClass);
          final t = DiseaseKnowledgeBase.treatment(matchedClass);
          final parts = <String>['${info.displayName}: ${info.about}'];
          if (t.hasVerifiedProducts) {
            final p = t.products!.first;
            parts.add('Verified product: ${p.name} (${p.activeIngredient}) \u2014 ${p.dose}');
          }
          if (t.preventive.isNotEmpty) {
            parts.add('Prevention: ${t.preventive.first}');
          }
          return parts.join('\n');
        }
        return 'I can help with crop disease questions. Try:\n'
            '\u2022 "wheat rust ka ilaj" (treatment for wheat rust)\n'
            '\u2022 "rice blast symptoms"\n'
            '\u2022 "tomato late blight prevention"\n'
            '\u2022 "organic options for corn"\n'
            '\u2022 Scan a leaf for automatic diagnosis';
    }
  }

  /// Very lightweight pronoun resolution: if the current question contains
  /// "ye" / "this" / "it" and a previous question mentioned a disease or
  /// crop, prepend the class context so keyword matching works.
  String _resolvePronouns(
    String question,
    List<Map<String, String>>? history,
  ) {
    if (history == null || history.isEmpty) return question;
    final q = question.toLowerCase();
    final hasPronoun = q.contains('ye ') ||
        q.contains('this') ||
        q.contains('it ') ||
        q.contains('wo ') ||
        q.contains('iske baad') ||
        q.contains('is ke');
    if (!hasPronoun) return question;

    // Walk backwards to find the last user question with a disease/crop keyword
    for (var i = history.length - 1; i >= 0; i--) {
      if (history[i]['role'] == 'user') {
        return '${history[i]['content']} — $question';
      }
    }
    return question;
  }
}

// ---------------------------------------------------------------------------
// Remote assistant — calls the FastAPI backend → DeepSeek LLM
// ---------------------------------------------------------------------------

/// Production assistant that calls the FastAPI backend which in turn
/// calls the DeepSeek (OpenAI-compatible) Chat Completions endpoint.
/// Falls back to [MockAssistantRepository] when the backend is unreachable.
class RemoteAssistantRepository implements AssistantRepository {
  final String baseUrl;
  final http.Client _client;
  final MockAssistantRepository _fallback = MockAssistantRepository();

  RemoteAssistantRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  Future<String> answer(
    String question, {
    String? lastClassName,
    List<Map<String, String>>? conversationHistory,
    String? scanContext,
  }) async {
    // If no backend URL is configured, skip the network call entirely.
    if (baseUrl.isEmpty) {
      return _fallback.answer(
        question,
        lastClassName: lastClassName,
        conversationHistory: conversationHistory,
        scanContext: scanContext,
      );
    }
    try {
      // Build the messages payload including conversation history
      final messages = <Map<String, String>>[];

      // Add prior conversation turns
      if (conversationHistory != null) {
        messages.addAll(conversationHistory);
      }

      // Add the current question
      messages.add({'role': 'user', 'content': question});

      final body = jsonEncode({
        'messages': messages,
        if (lastClassName != null) 'lastClassName': lastClassName,
        if (scanContext != null) 'scanContext': scanContext,
      });

      final res = await _client
          .post(
            Uri.parse('$baseUrl/chat'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 25));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final reply = data['reply'] as String?;
        if (reply != null && reply.trim().isNotEmpty) {
          return reply.trim();
        }
      }

      // Non-200 or empty reply — fall through to local fallback
      return await _fallback.answer(
        question,
        lastClassName: lastClassName,
        conversationHistory: conversationHistory,
        scanContext: scanContext,
      );
    } catch (_) {
      // Backend unreachable — use local knowledge base
      return _fallback.answer(
        question,
        lastClassName: lastClassName,
        conversationHistory: conversationHistory,
        scanContext: scanContext,
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Smart assistant — tries remote first, falls back to local knowledge base
// ---------------------------------------------------------------------------

/// Wraps either the remote or mock repository. If a [backendUrl] is provided
/// and reachable, answers come from the LLM backend; otherwise the bundled
/// verified knowledge base is used.
class SmartAssistantRepository implements AssistantRepository {
  final AssistantRepository _remote;
  final AssistantRepository _local;

  SmartAssistantRepository({
    required AssistantRepository remote,
    required AssistantRepository local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<String> answer(
    String question, {
    String? lastClassName,
    List<Map<String, String>>? conversationHistory,
    String? scanContext,
  }) async {
    try {
      final reply = await _remote.answer(
        question,
        lastClassName: lastClassName,
        conversationHistory: conversationHistory,
        scanContext: scanContext,
      );
      return reply;
    } catch (_) {
      return _local.answer(
        question,
        lastClassName: lastClassName,
        conversationHistory: conversationHistory,
        scanContext: scanContext,
      );
    }
  }
}
