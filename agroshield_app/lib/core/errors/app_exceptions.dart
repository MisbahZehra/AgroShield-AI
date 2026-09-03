class AppException implements Exception {
  final String message;
  const AppException(this.message);
  @override
  String toString() => message;
}

class ModelLoadException extends AppException {
  const ModelLoadException(super.message);
}

class InferenceException extends AppException {
  const InferenceException(super.message);
}

class ImageQualityException extends AppException {
  const ImageQualityException(super.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}
