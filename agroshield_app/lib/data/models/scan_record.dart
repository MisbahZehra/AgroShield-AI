class ScanRecord {
  final int? id;
  final String imagePath;
  final String crop;
  final String disease;
  final double confidence;
  final double affectedArea;
  final String severity;
  final String risk;
  final int timestamp;

  const ScanRecord({
    this.id,
    required this.imagePath,
    required this.crop,
    required this.disease,
    required this.confidence,
    required this.affectedArea,
    required this.severity,
    required this.risk,
    required this.timestamp,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'imagePath': imagePath,
        'crop': crop,
        'disease': disease,
        'confidence': confidence,
        'affectedArea': affectedArea,
        'severity': severity,
        'risk': risk,
        'timestamp': timestamp,
      };

  static ScanRecord fromMap(Map<String, Object?> map) => ScanRecord(
        id: map['id'] as int?,
        imagePath: map['imagePath'] as String,
        crop: map['crop'] as String,
        disease: map['disease'] as String,
        confidence: (map['confidence'] as num).toDouble(),
        affectedArea: (map['affectedArea'] as num).toDouble(),
        severity: map['severity'] as String,
        risk: map['risk'] as String,
        timestamp: map['timestamp'] as int,
      );
}
