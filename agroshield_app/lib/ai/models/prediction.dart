class Prediction {
  final int classIndex;
  final String className;
  final double confidence;
  final DateTime timestamp;
  final List<double> probabilities;

  const Prediction({
    required this.classIndex,
    required this.className,
    required this.confidence,
    required this.timestamp,
    required this.probabilities,
  });

  String get crop => className.split('_').first;

  bool get isHealthy => className.endsWith('healthy');
}

enum ScanStage { decode, quality, preprocess, inference, mapping, done }

class QualityReport {
  final bool passed;
  final String? reason;
  final double brightness;
  final double blurScore;
  final int width;
  final int height;

  const QualityReport({
    required this.passed,
    this.reason,
    required this.brightness,
    required this.blurScore,
    required this.width,
    required this.height,
  });
}

class SeverityEstimate {
  final double affectedAreaPercent;
  final String severityLabel;

  const SeverityEstimate({
    required this.affectedAreaPercent,
    required this.severityLabel,
  });
}

class ScanOutcome {
  final String imagePath;
  final Prediction prediction;
  final SeverityEstimate severity;
  final bool lowConfidence;
  final int? historyId;

  const ScanOutcome({
    required this.imagePath,
    required this.prediction,
    required this.severity,
    required this.lowConfidence,
    this.historyId,
  });
}
