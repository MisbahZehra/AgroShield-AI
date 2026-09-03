import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_sd.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pa'),
    Locale('sd'),
    Locale('ur'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AgroShield AI'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Smart Protection for Healthy Crops'**
  String get tagline;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcomeTo;

  /// No description provided for @onboardingCompanion.
  ///
  /// In en, this message translates to:
  /// **'Your AI Companion for Stronger, Healthier Crops'**
  String get onboardingCompanion;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @onboard1Title.
  ///
  /// In en, this message translates to:
  /// **'AI Disease Detection'**
  String get onboard1Title;

  /// No description provided for @onboard1Body.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of a leaf. AgroShield AI identifies the disease directly on your phone.'**
  String get onboard1Body;

  /// No description provided for @onboard2Title.
  ///
  /// In en, this message translates to:
  /// **'Offline Protection'**
  String get onboard2Title;

  /// No description provided for @onboard2Body.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis runs on your device. No internet needed in the field.'**
  String get onboard2Body;

  /// No description provided for @onboard3Title.
  ///
  /// In en, this message translates to:
  /// **'Weather-Based Risk Alerts'**
  String get onboard3Title;

  /// No description provided for @onboard3Body.
  ///
  /// In en, this message translates to:
  /// **'A 7-day disease risk estimate helps you act before damage spreads.'**
  String get onboard3Body;

  /// No description provided for @onboard4Title.
  ///
  /// In en, this message translates to:
  /// **'Simple Voice Guidance'**
  String get onboard4Title;

  /// No description provided for @onboard4Body.
  ///
  /// In en, this message translates to:
  /// **'Listen to results and guidance in your own language.'**
  String get onboard4Body;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageNote.
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime in Settings.'**
  String get languageNote;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// No description provided for @farmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what\'s happening in your farm'**
  String get farmSubtitle;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @scanDisease.
  ///
  /// In en, this message translates to:
  /// **'Scan Disease'**
  String get scanDisease;

  /// No description provided for @scanDiseaseDesc.
  ///
  /// In en, this message translates to:
  /// **'Detect plant diseases'**
  String get scanDiseaseDesc;

  /// No description provided for @sevenDayForecast.
  ///
  /// In en, this message translates to:
  /// **'7-Day Forecast'**
  String get sevenDayForecast;

  /// No description provided for @sevenDayForecastDesc.
  ///
  /// In en, this message translates to:
  /// **'Check disease risk'**
  String get sevenDayForecastDesc;

  /// No description provided for @myCrops.
  ///
  /// In en, this message translates to:
  /// **'My Crops'**
  String get myCrops;

  /// No description provided for @myCropsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage your fields'**
  String get myCropsDesc;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @historyDesc.
  ///
  /// In en, this message translates to:
  /// **'View past scans'**
  String get historyDesc;

  /// No description provided for @fieldAlerts.
  ///
  /// In en, this message translates to:
  /// **'Field Alerts'**
  String get fieldAlerts;

  /// No description provided for @noAlerts.
  ///
  /// In en, this message translates to:
  /// **'No active alerts. Your fields look fine.'**
  String get noAlerts;

  /// No description provided for @highRiskAlert.
  ///
  /// In en, this message translates to:
  /// **'High disease risk detected for your {crop} field.'**
  String highRiskAlert(String crop);

  /// No description provided for @offlineAi.
  ///
  /// In en, this message translates to:
  /// **'Offline AI'**
  String get offlineAi;

  /// No description provided for @offlineAiDesc.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis runs on your device'**
  String get offlineAiDesc;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @cropsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Crops'**
  String get cropsTitle;

  /// No description provided for @addCrop.
  ///
  /// In en, this message translates to:
  /// **'Add Crop'**
  String get addCrop;

  /// No description provided for @cropName.
  ///
  /// In en, this message translates to:
  /// **'Crop name'**
  String get cropName;

  /// No description provided for @growthStage.
  ///
  /// In en, this message translates to:
  /// **'Growth Stage'**
  String get growthStage;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @statusGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get statusGood;

  /// No description provided for @statusModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get statusModerate;

  /// No description provided for @statusAtRisk.
  ///
  /// In en, this message translates to:
  /// **'At Risk'**
  String get statusAtRisk;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @deleteCrop.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get deleteCrop;

  /// No description provided for @noCrops.
  ///
  /// In en, this message translates to:
  /// **'No crops yet'**
  String get noCrops;

  /// No description provided for @noCropsDesc.
  ///
  /// In en, this message translates to:
  /// **'Add your first field to start monitoring.'**
  String get noCropsDesc;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Disease'**
  String get scanTitle;

  /// No description provided for @placeLeaf.
  ///
  /// In en, this message translates to:
  /// **'Place the affected leaf in the frame'**
  String get placeLeaf;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @capture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get capture;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// No description provided for @tipsBody.
  ///
  /// In en, this message translates to:
  /// **'Use daylight, fill the frame with one leaf, keep the camera steady and avoid shadows.'**
  String get tipsBody;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @qualityFail.
  ///
  /// In en, this message translates to:
  /// **'Please capture a clearer image of the leaf.'**
  String get qualityFail;

  /// No description provided for @analyzingTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Image'**
  String get analyzingTitle;

  /// No description provided for @analyzingBody.
  ///
  /// In en, this message translates to:
  /// **'AgroShield AI is analyzing your crop...'**
  String get analyzingBody;

  /// No description provided for @stageDecode.
  ///
  /// In en, this message translates to:
  /// **'Reading image'**
  String get stageDecode;

  /// No description provided for @stageQuality.
  ///
  /// In en, this message translates to:
  /// **'Checking image quality'**
  String get stageQuality;

  /// No description provided for @stagePreprocess.
  ///
  /// In en, this message translates to:
  /// **'Preparing model input'**
  String get stagePreprocess;

  /// No description provided for @stageInference.
  ///
  /// In en, this message translates to:
  /// **'Running on-device AI'**
  String get stageInference;

  /// No description provided for @stageMapping.
  ///
  /// In en, this message translates to:
  /// **'Mapping result'**
  String get stageMapping;

  /// No description provided for @resultTitle.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get resultTitle;

  /// No description provided for @diseaseDetected.
  ///
  /// In en, this message translates to:
  /// **'Disease Detected'**
  String get diseaseDetected;

  /// No description provided for @healthyLeaf.
  ///
  /// In en, this message translates to:
  /// **'Healthy Leaf'**
  String get healthyLeaf;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @affectedCrop.
  ///
  /// In en, this message translates to:
  /// **'Affected Crop'**
  String get affectedCrop;

  /// No description provided for @estimatedAffectedArea.
  ///
  /// In en, this message translates to:
  /// **'Estimated Affected Area'**
  String get estimatedAffectedArea;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @severityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get severityLow;

  /// No description provided for @severityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get severityModerate;

  /// No description provided for @severityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get severityHigh;

  /// No description provided for @detectedOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Detected on your device - works offline'**
  String get detectedOnDevice;

  /// No description provided for @lowConfidence.
  ///
  /// In en, this message translates to:
  /// **'Low confidence'**
  String get lowConfidence;

  /// No description provided for @lowConfidenceBody.
  ///
  /// In en, this message translates to:
  /// **'Please capture another clear image of the leaf.'**
  String get lowConfidenceBody;

  /// No description provided for @retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake Photo'**
  String get retakePhoto;

  /// No description provided for @aboutDisease.
  ///
  /// In en, this message translates to:
  /// **'About This Disease'**
  String get aboutDisease;

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// No description provided for @viewTreatment.
  ///
  /// In en, this message translates to:
  /// **'View Treatment'**
  String get viewTreatment;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @treatmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Treatment'**
  String get treatmentTitle;

  /// No description provided for @recommendedTreatment.
  ///
  /// In en, this message translates to:
  /// **'Recommended Actions'**
  String get recommendedTreatment;

  /// No description provided for @treatmentIntro.
  ///
  /// In en, this message translates to:
  /// **'Follow these steps to protect your crop.'**
  String get treatmentIntro;

  /// No description provided for @preventiveSteps.
  ///
  /// In en, this message translates to:
  /// **'Preventive Steps'**
  String get preventiveSteps;

  /// No description provided for @organicAlternatives.
  ///
  /// In en, this message translates to:
  /// **'Organic & Cultural Options'**
  String get organicAlternatives;

  /// No description provided for @noTreatmentInfo.
  ///
  /// In en, this message translates to:
  /// **'Verified treatment information is currently unavailable.'**
  String get noTreatmentInfo;

  /// No description provided for @generalGuidance.
  ///
  /// In en, this message translates to:
  /// **'General guidance only. Confirm chemical options with your local agricultural extension office.'**
  String get generalGuidance;

  /// No description provided for @saveToPlan.
  ///
  /// In en, this message translates to:
  /// **'Save to My Plan'**
  String get saveToPlan;

  /// No description provided for @savedToPlan.
  ///
  /// In en, this message translates to:
  /// **'Saved to history'**
  String get savedToPlan;

  /// No description provided for @riskTitle.
  ///
  /// In en, this message translates to:
  /// **'7-Day Risk Forecast'**
  String get riskTitle;

  /// No description provided for @riskSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Disease Risk Forecast'**
  String get riskSubtitle;

  /// No description provided for @ruleBasedNote.
  ///
  /// In en, this message translates to:
  /// **'Rule-based disease risk estimate from weather data. Not a trained AI prediction.'**
  String get ruleBasedNote;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @riskLow.
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get riskLow;

  /// No description provided for @riskMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium Risk'**
  String get riskMedium;

  /// No description provided for @riskHigh.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get riskHigh;

  /// No description provided for @rainChance.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get rainChance;

  /// No description provided for @noWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather unavailable. Showing clearly labelled sample data.'**
  String get noWeather;

  /// No description provided for @weatherSample.
  ///
  /// In en, this message translates to:
  /// **'Sample data'**
  String get weatherSample;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @searchHistory.
  ///
  /// In en, this message translates to:
  /// **'Search scans'**
  String get searchHistory;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No scans yet'**
  String get noHistory;

  /// No description provided for @noHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Your scan results will appear here, even offline.'**
  String get noHistoryDesc;

  /// No description provided for @assistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get assistantTitle;

  /// No description provided for @askAgroShield.
  ///
  /// In en, this message translates to:
  /// **'Ask AgroShield'**
  String get askAgroShield;

  /// No description provided for @assistantHint.
  ///
  /// In en, this message translates to:
  /// **'Answers come from the bundled verified knowledge base only.'**
  String get assistantHint;

  /// No description provided for @q1.
  ///
  /// In en, this message translates to:
  /// **'What disease is this?'**
  String get q1;

  /// No description provided for @q2.
  ///
  /// In en, this message translates to:
  /// **'How can I protect my crop?'**
  String get q2;

  /// No description provided for @q3.
  ///
  /// In en, this message translates to:
  /// **'What should I monitor this week?'**
  String get q3;

  /// No description provided for @assistantDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'The assistant only uses bundled verified guidance and never invents chemical doses.'**
  String get assistantDisclaimer;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @farmInformation.
  ///
  /// In en, this message translates to:
  /// **'Farm Information'**
  String get farmInformation;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About AgroShield AI'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get appVersion;

  /// No description provided for @assistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get assistant;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @ttsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Voice guidance'**
  String get ttsEnabled;

  /// No description provided for @defaultLocation.
  ///
  /// In en, this message translates to:
  /// **'Default location'**
  String get defaultLocation;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear scan history'**
  String get clearHistory;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all saved scans from this device?'**
  String get clearHistoryConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cameraDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is needed to scan leaves. Enable it in system settings.'**
  String get cameraDenied;

  /// No description provided for @modelLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'The on-device AI model could not be started.'**
  String get modelLoadFailed;

  /// No description provided for @percent.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String percent(String value);

  /// No description provided for @confidenceValue.
  ///
  /// In en, this message translates to:
  /// **'Confidence: {value}%'**
  String confidenceValue(String value);

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'AgroShield AI detects crop diseases from a leaf photo directly on your phone, estimates severity, and warns you about weather-driven disease risk - even without internet.'**
  String get aboutBody;

  /// No description provided for @helpBody.
  ///
  /// In en, this message translates to:
  /// **'Scan a single leaf in good daylight. Results above the confidence threshold are reliable; low-confidence results ask for a retake. For chemical treatment, always confirm with your local extension office.'**
  String get helpBody;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @crops.
  ///
  /// In en, this message translates to:
  /// **'Crops'**
  String get crops;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @weatherUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Weather unavailable'**
  String get weatherUnavailable;

  /// No description provided for @feelsLikeEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get feelsLikeEstimate;

  /// No description provided for @sevenDay.
  ///
  /// In en, this message translates to:
  /// **'7-Day'**
  String get sevenDay;

  /// No description provided for @cropAdded.
  ///
  /// In en, this message translates to:
  /// **'Crop added'**
  String get cropAdded;

  /// No description provided for @selectCropType.
  ///
  /// In en, this message translates to:
  /// **'Crop type'**
  String get selectCropType;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @voiceNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Voice is not available on this device'**
  String get voiceNotAvailable;

  /// No description provided for @diseaseRiskFor.
  ///
  /// In en, this message translates to:
  /// **'Disease risk for {crop}'**
  String diseaseRiskFor(String crop);

  /// No description provided for @rainAlert.
  ///
  /// In en, this message translates to:
  /// **'Rain Alert'**
  String get rainAlert;

  /// No description provided for @diseaseRiskAlerts.
  ///
  /// In en, this message translates to:
  /// **'Disease Risk Alerts'**
  String get diseaseRiskAlerts;

  /// No description provided for @weatherAlerts.
  ///
  /// In en, this message translates to:
  /// **'Weather Alerts'**
  String get weatherAlerts;

  /// No description provided for @highRiskAlerts.
  ///
  /// In en, this message translates to:
  /// **'High Risk Alerts'**
  String get highRiskAlerts;

  /// No description provided for @sevenDayRiskAlerts.
  ///
  /// In en, this message translates to:
  /// **'7-Day Risk Alerts'**
  String get sevenDayRiskAlerts;

  /// No description provided for @dailyFarmSummary.
  ///
  /// In en, this message translates to:
  /// **'Daily Farm Summary'**
  String get dailyFarmSummary;

  /// No description provided for @notifSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Toggle notifications on or off. Changes are saved locally.'**
  String get notifSettingsHint;

  /// No description provided for @farmDetails.
  ///
  /// In en, this message translates to:
  /// **'Farm Details'**
  String get farmDetails;

  /// No description provided for @province.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get province;

  /// No description provided for @farmSize.
  ///
  /// In en, this message translates to:
  /// **'Farm Size'**
  String get farmSize;

  /// No description provided for @soilType.
  ///
  /// In en, this message translates to:
  /// **'Soil Type'**
  String get soilType;

  /// No description provided for @irrigationType.
  ///
  /// In en, this message translates to:
  /// **'Irrigation Type'**
  String get irrigationType;

  /// No description provided for @farmingType.
  ///
  /// In en, this message translates to:
  /// **'Farming Type'**
  String get farmingType;

  /// No description provided for @primaryCrops.
  ///
  /// In en, this message translates to:
  /// **'Primary Crops'**
  String get primaryCrops;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @farmNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Additional notes about your farm...'**
  String get farmNotesHint;

  /// No description provided for @farmLocation.
  ///
  /// In en, this message translates to:
  /// **'Farm Location'**
  String get farmLocation;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkMode;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pa', 'sd', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pa':
      return AppLocalizationsPa();
    case 'sd':
      return AppLocalizationsSd();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
