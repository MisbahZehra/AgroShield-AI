class Crop {
  final int? id;
  final String name;
  final String type;
  final String growthStage;
  final int healthPercent;
  final String status;

  const Crop({
    this.id,
    required this.name,
    required this.type,
    required this.growthStage,
    required this.healthPercent,
    required this.status,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'growthStage': growthStage,
        'healthPercent': healthPercent,
        'status': status,
      };

  static Crop fromMap(Map<String, Object?> map) => Crop(
        id: map['id'] as int?,
        name: map['name'] as String,
        type: map['type'] as String,
        growthStage: map['growthStage'] as String,
        healthPercent: map['healthPercent'] as int,
        status: map['status'] as String,
      );
}
