import 'dart:typed_data';

import '../../ai/models/prediction.dart';

abstract class AIRepository {
  Future<void> initialize();
  bool get isReady;
  Future<Prediction> predictFromBytes(Uint8List imageBytes);
  void dispose();
}
