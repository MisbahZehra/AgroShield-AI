import 'dart:io';

import 'package:agroshield_app/ai/preprocessing/image_preprocessor.dart';
import 'package:agroshield_app/ai/severity/severity_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sample = File('assets/images/sample_wheat_rust.png');

  test('real sample leaf decodes, passes quality and builds valid tensor',
      () {
    expect(sample.existsSync(), isTrue);
    final image = ImagePreprocessor.decode(sample.readAsBytesSync());
    expect(image.width, greaterThanOrEqualTo(100));

    final quality = ImagePreprocessor.checkQuality(image);
    expect(quality.passed, isTrue,
        reason: 'sample leaf must not be rejected (reason: ${quality.reason})');

    final tensor = ImagePreprocessor.toInputTensor(image);
    expect(tensor.length, 1);
    final rows = tensor[0] as List;
    expect(rows.length, 224);
    final first = (rows[0] as List)[0] as List;
    expect(first.length, 3);
    var min = double.infinity;
    var max = double.negativeInfinity;
    for (final row in rows.cast<List>()) {
      for (final px in row.cast<List>()) {
        for (final c in px.cast<double>()) {
          if (c < min) min = c;
          if (c > max) max = c;
        }
      }
    }
    expect(min, greaterThanOrEqualTo(0));
    expect(max, lessThanOrEqualTo(255));
  });

  test('severity estimate is bounded and labelled', () {
    final image = ImagePreprocessor.decode(sample.readAsBytesSync());
    final severity = SeverityService().estimate(image);
    expect(severity.affectedAreaPercent, inInclusiveRange(0, 100));
    expect(['low', 'moderate', 'high'], contains(severity.severityLabel));
  });
}
