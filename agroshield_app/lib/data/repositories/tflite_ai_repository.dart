import 'dart:typed_data';

import '../../ai/models/prediction.dart';
import '../../ai/preprocessing/image_preprocessor.dart';
import '../../ai/tflite/tflite_service.dart';
import '../../domain/repositories/ai_repository.dart';

class TFLiteAIRepository implements AIRepository {
  final TFLiteService _service;

  TFLiteAIRepository(this._service);

  @override
  Future<void> initialize() => _service.initialize();

  @override
  bool get isReady => _service.isReady;

  @override
  Future<Prediction> predictFromBytes(Uint8List imageBytes) async {
    final image = ImagePreprocessor.decode(imageBytes);
    final tensor = ImagePreprocessor.toInputTensor(image);
    return _service.predict(tensor);
  }

  Prediction predictTensor(List<Object> tensor) => _service.predict(tensor);

  @override
  void dispose() => _service.dispose();
}
