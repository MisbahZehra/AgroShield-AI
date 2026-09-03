import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exceptions.dart';
import '../models/prediction.dart';

/// Prepares camera/gallery images for the agroshield_fp16.tflite model.
///
/// Verified pipeline (flatbuffer inspection of the exported model):
/// the MobileNetV3Large graph contains a baked-in Rescaling layer
/// (x * 1/127.5 - 1), therefore the client must feed RAW [0,255] float32
/// RGB pixels, resized to 224x224 with bilinear interpolation.
class ImagePreprocessor {
  /// Decodes, validates and resizes [bytes] into the model input tensor
  /// shaped [1][224][224][3] of raw 0-255 doubles.
  static List<Object> toInputTensor(img.Image image) {
    final resized = img.copyResize(
      image,
      width: AppConstants.modelInputSize,
      height: AppConstants.modelInputSize,
      interpolation: img.Interpolation.linear,
    );
    final size = AppConstants.modelInputSize;
    final rows = List<Object>.generate(size, (y) {
      final cols = List<Object>.generate(size, (x) {
        final p = resized.getPixel(x, y);
        return <double>[
          p.r.clamp(0, 255).toDouble(),
          p.g.clamp(0, 255).toDouble(),
          p.b.clamp(0, 255).toDouble(),
        ];
      });
      return cols;
    });
    return [rows];
  }

  static img.Image decode(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw const ImageQualityException('The selected file is not a valid image.');
    }
    return image;
  }

  /// Documented rule-based quality validation: decodability, minimum
  /// resolution, brightness window and a lenient laplacian blur score.
  static QualityReport checkQuality(img.Image image) {
    final width = image.width;
    final height = image.height;
    if (width < 100 || height < 100) {
      return QualityReport(
        passed: false,
        reason: 'resolution',
        brightness: 0,
        blurScore: 0,
        width: width,
        height: height,
      );
    }
    final gray = img.copyResize(
      img.grayscale(image),
      width: 128,
      height: 128,
      interpolation: img.Interpolation.linear,
    );
    double sum = 0;
    for (final p in gray) {
      sum += p.r;
    }
    final brightness = sum / (gray.width * gray.height);
    if (brightness < 18 || brightness > 242) {
      return QualityReport(
        passed: false,
        reason: 'brightness',
        brightness: brightness,
        blurScore: -1,
        width: width,
        height: height,
      );
    }
    final blur = _laplacianVariance(gray);
    return QualityReport(
      passed: blur >= 2.0,
      reason: blur >= 2.0 ? null : 'blur',
      brightness: brightness,
      blurScore: blur,
      width: width,
      height: height,
    );
  }

  static double _laplacianVariance(img.Image gray) {
    final w = gray.width;
    final h = gray.height;
    final values = <double>[];
    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        final v = 4 * gray.getPixel(x, y).r.toDouble() -
            gray.getPixel(x - 1, y).r.toDouble() -
            gray.getPixel(x + 1, y).r.toDouble() -
            gray.getPixel(x, y - 1).r.toDouble() -
            gray.getPixel(x, y + 1).r.toDouble();
        values.add(v);
      }
    }
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.fold<double>(
            0, (acc, v) => acc + (v - mean) * (v - mean)) /
        values.length;
    return variance;
  }
}
