import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exceptions.dart';
import '../models/prediction.dart';

/// Loads agroshield_fp16.tflite exactly once and runs on-device inference.
///
/// Verified model contract (flatbuffer inspection, 2026-08-30):
///   input  [1,224,224,3] float32, RAW RGB 0-255 (Rescaling baked in graph)
///   output [1,32]        float32 softmax probabilities
class TFLiteService {
  Interpreter? _interpreter;
  Map<int, String> _idxToClass = {};
  bool _initializing = false;

  bool get isReady => _interpreter != null;

  Future<void> initialize() async {
    if (_interpreter != null || _initializing) return;
    _initializing = true;
    try {
      final options = InterpreterOptions()..threads = 4;
      final interpreter =
          await Interpreter.fromAsset(AppConstants.modelAsset, options: options);
      final inputShape = interpreter.getInputTensor(0).shape;
      final outputShape = interpreter.getOutputTensor(0).shape;
      if (inputShape.length != 4 ||
          inputShape[1] != AppConstants.modelInputSize ||
          inputShape[2] != AppConstants.modelInputSize ||
          inputShape[3] != 3) {
        interpreter.close();
        throw ModelLoadException(
            'Unexpected input tensor shape $inputShape; expected [1,224,224,3].');
      }
      if (outputShape.length != 2 ||
          outputShape[1] != AppConstants.numClasses) {
        interpreter.close();
        throw ModelLoadException(
            'Unexpected output tensor shape $outputShape; expected [1,32].');
      }
      final raw = await rootBundle.loadString(AppConstants.classIndexAsset);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final idxMap = (json['idx_to_class'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(int.parse(k), v as String));
      _idxToClass = idxMap;
      _interpreter = interpreter;
    } finally {
      _initializing = false;
    }
  }

  /// [input] must be shaped [1][224][224][3] with raw 0-255 values.
  Prediction predict(List<Object> input) {
    final interpreter = _interpreter;
    if (interpreter == null) {
      throw const ModelLoadException('Model not initialized.');
    }
    final output = List.generate(1, (_) => List<double>.filled(
        AppConstants.numClasses, 0.0));
    try {
      interpreter.run(input, output);
    } catch (e) {
      throw InferenceException('On-device inference failed: $e');
    }
    final probs = output.first;
    var best = 0;
    for (var i = 1; i < probs.length; i++) {
      if (probs[i] > probs[best]) best = i;
    }
    final name = _idxToClass[best] ?? 'unknown_class_$best';
    return Prediction(
      classIndex: best,
      className: name,
      confidence: probs[best],
      timestamp: DateTime.now(),
      probabilities: probs,
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
