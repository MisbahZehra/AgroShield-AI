import 'package:image/image.dart' as img;

import '../models/prediction.dart';

/// Documented Phase-1 heuristic (same method as the training repo's
/// estimate_severity): HSV colour thresholds estimate the share of leaf
/// pixels that are not healthy green. Explicitly an ESTIMATE, replaceable
/// by a dedicated severity model later.
class SeverityService {
  SeverityEstimate estimate(img.Image image) {
    final sample = img.copyResize(image, width: 160, height: 160,
        interpolation: img.Interpolation.linear);
    var leaf = 0;
    var healthy = 0;
    for (final p in sample) {
      final hsv = _rgbToHsv(p.r, p.g, p.b);
      final h = hsv[0];
      final s = hsv[1];
      final v = hsv[2];
      if (h >= 20 && h <= 95 && s >= 20 && v >= 20) leaf++;
      if (h >= 35 && h <= 85 && s >= 40 && v >= 40) healthy++;
    }
    if (leaf == 0) {
      return const SeverityEstimate(
          affectedAreaPercent: 0, severityLabel: 'low');
    }
    final affected = ((leaf - healthy) / leaf) * 100;
    final clamped = affected.clamp(0, 100).toDouble();
    final label = clamped < 20 ? 'low' : (clamped < 50 ? 'moderate' : 'high');
    return SeverityEstimate(
        affectedAreaPercent: double.parse(clamped.toStringAsFixed(1)),
        severityLabel: label);
  }

  /// Returns OpenCV-style HSV: H in [0,180), S/V in [0,255].
  static List<double> _rgbToHsv(num r, num g, num b) {
    final rd = r / 255.0;
    final gd = g / 255.0;
    final bd = b / 255.0;
    final max = [rd, gd, bd].reduce((a, c) => a > c ? a : c);
    final min = [rd, gd, bd].reduce((a, c) => a < c ? a : c);
    final d = max - min;
    var h = 0.0;
    if (d != 0) {
      if (max == rd) {
        h = 60 * (((gd - bd) / d) % 6);
      } else if (max == gd) {
        h = 60 * (((bd - rd) / d) + 2);
      } else {
        h = 60 * (((rd - gd) / d) + 4);
      }
    }
    if (h < 0) h += 360;
    final s = max == 0 ? 0.0 : d / max;
    return [h / 2.0, s * 255.0, max * 255.0];
  }
}
