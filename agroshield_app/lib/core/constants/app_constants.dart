class AppConstants {
  static const String appName = 'AgroShield AI';
  static const String modelAsset = 'assets/models/agroshield_fp16.tflite';
  static const String classIndexAsset = 'assets/models/class_index.json';
  static const String metadataAsset =
      'assets/models/flutter_model_metadata.json';

  /// Verified from flutter_model_metadata.json and flatbuffer inspection.
  static const int modelInputSize = 224;
  static const int numClasses = 32;
  static const double confidenceThreshold = 0.3;

  static const String openWeatherApiKey =
      String.fromEnvironment('OPENWEATHER_API_KEY');
  static const String openWeatherForecastUrl =
      'https://api.openweathermap.org/data/2.5/forecast';

  /// FastAPI assistant backend URL, passed via --dart-define at build time.
  /// Leave empty to use only the local knowledge-base assistant.
  static const String assistantBackendUrl =
      String.fromEnvironment('ASSISTANT_BACKEND_URL');

  /// Fallback coordinates (Sindh, Pakistan) used when the device
  /// location is unavailable.
  static const double defaultLatitude = 25.3924;
  static const double defaultLongitude = 68.3578;
  static const String defaultLocationName = 'Sindh, Pakistan';
}
