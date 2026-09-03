// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AgroShield AI';

  @override
  String get tagline => 'Smart Protection for Healthy Crops';

  @override
  String get loading => 'Loading...';

  @override
  String get welcomeTo => 'Welcome to';

  @override
  String get onboardingCompanion =>
      'Your AI Companion for Stronger, Healthier Crops';

  @override
  String get getStarted => 'Get Started';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get onboard1Title => 'AI Disease Detection';

  @override
  String get onboard1Body =>
      'Take a photo of a leaf. AgroShield AI identifies the disease directly on your phone.';

  @override
  String get onboard2Title => 'Offline Protection';

  @override
  String get onboard2Body =>
      'Diagnosis runs on your device. No internet needed in the field.';

  @override
  String get onboard3Title => 'Weather-Based Risk Alerts';

  @override
  String get onboard3Body =>
      'A 7-day disease risk estimate helps you act before damage spreads.';

  @override
  String get onboard4Title => 'Simple Voice Guidance';

  @override
  String get onboard4Body =>
      'Listen to results and guidance in your own language.';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageNote => 'You can change this anytime in Settings.';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get farmer => 'Farmer';

  @override
  String get farmSubtitle => 'Here\'s what\'s happening in your farm';

  @override
  String get humidity => 'Humidity';

  @override
  String get location => 'Location';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get scanDisease => 'Scan Disease';

  @override
  String get scanDiseaseDesc => 'Detect plant diseases';

  @override
  String get sevenDayForecast => '7-Day Forecast';

  @override
  String get sevenDayForecastDesc => 'Check disease risk';

  @override
  String get myCrops => 'My Crops';

  @override
  String get myCropsDesc => 'Manage your fields';

  @override
  String get history => 'History';

  @override
  String get historyDesc => 'View past scans';

  @override
  String get fieldAlerts => 'Field Alerts';

  @override
  String get noAlerts => 'No active alerts. Your fields look fine.';

  @override
  String highRiskAlert(String crop) {
    return 'High disease risk detected for your $crop field.';
  }

  @override
  String get offlineAi => 'Offline AI';

  @override
  String get offlineAiDesc => 'Diagnosis runs on your device';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get cropsTitle => 'My Crops';

  @override
  String get addCrop => 'Add Crop';

  @override
  String get cropName => 'Crop name';

  @override
  String get growthStage => 'Growth Stage';

  @override
  String get status => 'Status';

  @override
  String get statusGood => 'Good';

  @override
  String get statusModerate => 'Moderate';

  @override
  String get statusAtRisk => 'At Risk';

  @override
  String get health => 'Health';

  @override
  String get deleteCrop => 'Remove';

  @override
  String get noCrops => 'No crops yet';

  @override
  String get noCropsDesc => 'Add your first field to start monitoring.';

  @override
  String get scanTitle => 'Scan Disease';

  @override
  String get placeLeaf => 'Place the affected leaf in the frame';

  @override
  String get gallery => 'Gallery';

  @override
  String get capture => 'Capture';

  @override
  String get tips => 'Tips';

  @override
  String get tipsBody =>
      'Use daylight, fill the frame with one leaf, keep the camera steady and avoid shadows.';

  @override
  String get retake => 'Retake';

  @override
  String get qualityFail => 'Please capture a clearer image of the leaf.';

  @override
  String get analyzingTitle => 'Analyzing Image';

  @override
  String get analyzingBody => 'AgroShield AI is analyzing your crop...';

  @override
  String get stageDecode => 'Reading image';

  @override
  String get stageQuality => 'Checking image quality';

  @override
  String get stagePreprocess => 'Preparing model input';

  @override
  String get stageInference => 'Running on-device AI';

  @override
  String get stageMapping => 'Mapping result';

  @override
  String get resultTitle => 'Result';

  @override
  String get diseaseDetected => 'Disease Detected';

  @override
  String get healthyLeaf => 'Healthy Leaf';

  @override
  String get confidence => 'Confidence';

  @override
  String get affectedCrop => 'Affected Crop';

  @override
  String get estimatedAffectedArea => 'Estimated Affected Area';

  @override
  String get severity => 'Severity';

  @override
  String get severityLow => 'Low';

  @override
  String get severityModerate => 'Moderate';

  @override
  String get severityHigh => 'High';

  @override
  String get detectedOnDevice => 'Detected on your device - works offline';

  @override
  String get lowConfidence => 'Low confidence';

  @override
  String get lowConfidenceBody =>
      'Please capture another clear image of the leaf.';

  @override
  String get retakePhoto => 'Retake Photo';

  @override
  String get aboutDisease => 'About This Disease';

  @override
  String get symptoms => 'Symptoms';

  @override
  String get viewTreatment => 'View Treatment';

  @override
  String get listen => 'Listen';

  @override
  String get treatmentTitle => 'Treatment';

  @override
  String get recommendedTreatment => 'Recommended Actions';

  @override
  String get treatmentIntro => 'Follow these steps to protect your crop.';

  @override
  String get preventiveSteps => 'Preventive Steps';

  @override
  String get organicAlternatives => 'Organic & Cultural Options';

  @override
  String get noTreatmentInfo =>
      'Verified treatment information is currently unavailable.';

  @override
  String get generalGuidance =>
      'General guidance only. Confirm chemical options with your local agricultural extension office.';

  @override
  String get saveToPlan => 'Save to My Plan';

  @override
  String get savedToPlan => 'Saved to history';

  @override
  String get riskTitle => '7-Day Risk Forecast';

  @override
  String get riskSubtitle => 'Disease Risk Forecast';

  @override
  String get ruleBasedNote =>
      'Rule-based disease risk estimate from weather data. Not a trained AI prediction.';

  @override
  String get today => 'Today';

  @override
  String get riskLow => 'Low Risk';

  @override
  String get riskMedium => 'Medium Risk';

  @override
  String get riskHigh => 'High Risk';

  @override
  String get rainChance => 'Rain';

  @override
  String get noWeather =>
      'Weather unavailable. Showing clearly labelled sample data.';

  @override
  String get weatherSample => 'Sample data';

  @override
  String get historyTitle => 'History';

  @override
  String get all => 'All';

  @override
  String get searchHistory => 'Search scans';

  @override
  String get noHistory => 'No scans yet';

  @override
  String get noHistoryDesc =>
      'Your scan results will appear here, even offline.';

  @override
  String get assistantTitle => 'Assistant';

  @override
  String get askAgroShield => 'Ask AgroShield';

  @override
  String get assistantHint =>
      'Answers come from the bundled verified knowledge base only.';

  @override
  String get q1 => 'What disease is this?';

  @override
  String get q2 => 'How can I protect my crop?';

  @override
  String get q3 => 'What should I monitor this week?';

  @override
  String get assistantDisclaimer =>
      'The assistant only uses bundled verified guidance and never invents chemical doses.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get farmInformation => 'Farm Information';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get language => 'Language';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get about => 'About AgroShield AI';

  @override
  String get appVersion => 'Version';

  @override
  String get assistant => 'Assistant';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get ttsEnabled => 'Voice guidance';

  @override
  String get defaultLocation => 'Default location';

  @override
  String get clearHistory => 'Clear scan history';

  @override
  String get clearHistoryConfirm => 'Delete all saved scans from this device?';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get delete => 'Delete';

  @override
  String get error => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get cameraDenied =>
      'Camera permission is needed to scan leaves. Enable it in system settings.';

  @override
  String get modelLoadFailed => 'The on-device AI model could not be started.';

  @override
  String percent(String value) {
    return '$value%';
  }

  @override
  String confidenceValue(String value) {
    return 'Confidence: $value%';
  }

  @override
  String get aboutBody =>
      'AgroShield AI detects crop diseases from a leaf photo directly on your phone, estimates severity, and warns you about weather-driven disease risk - even without internet.';

  @override
  String get helpBody =>
      'Scan a single leaf in good daylight. Results above the confidence threshold are reliable; low-confidence results ask for a retake. For chemical treatment, always confirm with your local extension office.';

  @override
  String get home => 'Home';

  @override
  String get crops => 'Crops';

  @override
  String get scan => 'Scan';

  @override
  String get profile => 'Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get weatherUnavailable => 'Weather unavailable';

  @override
  String get feelsLikeEstimate => 'Estimate';

  @override
  String get sevenDay => '7-Day';

  @override
  String get cropAdded => 'Crop added';

  @override
  String get selectCropType => 'Crop type';

  @override
  String get save => 'Save';

  @override
  String get voiceNotAvailable => 'Voice is not available on this device';

  @override
  String diseaseRiskFor(String crop) {
    return 'Disease risk for $crop';
  }

  @override
  String get rainAlert => 'Rain Alert';

  @override
  String get diseaseRiskAlerts => 'Disease Risk Alerts';

  @override
  String get weatherAlerts => 'Weather Alerts';

  @override
  String get highRiskAlerts => 'High Risk Alerts';

  @override
  String get sevenDayRiskAlerts => '7-Day Risk Alerts';

  @override
  String get dailyFarmSummary => 'Daily Farm Summary';

  @override
  String get notifSettingsHint =>
      'Toggle notifications on or off. Changes are saved locally.';

  @override
  String get farmDetails => 'Farm Details';

  @override
  String get province => 'Province';

  @override
  String get farmSize => 'Farm Size';

  @override
  String get soilType => 'Soil Type';

  @override
  String get irrigationType => 'Irrigation Type';

  @override
  String get farmingType => 'Farming Type';

  @override
  String get primaryCrops => 'Primary Crops';

  @override
  String get notes => 'Notes';

  @override
  String get farmNotesHint => 'Additional notes about your farm...';

  @override
  String get farmLocation => 'Farm Location';

  @override
  String get themeMode => 'Theme';

  @override
  String get lightMode => 'Light';

  @override
  String get darkMode => 'Dark';

  @override
  String get systemDefault => 'System Default';
}
