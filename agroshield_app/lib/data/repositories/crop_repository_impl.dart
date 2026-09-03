import '../../domain/repositories/crop_repository.dart';
import '../datasources/local_database.dart';
import '../models/crop.dart';

class CropRepositoryImpl implements CropRepository {
  bool _seeded = false;

  @override
  Future<List<Crop>> all() async {
    final db = await LocalDatabase.instance();
    if (!_seeded) {
      final rows = await db.rawQuery('SELECT COUNT(*) AS c FROM crops');
      final count = (rows.first['c'] as int?) ?? 0;
      if (count == 0) {
        await _seed(db);
      }
      _seeded = true;
    }
    final rows = await db.query('crops', orderBy: 'id ASC');
    return rows.map((r) => Crop.fromMap(Map<String, Object?>.from(r))).toList();
  }

  Future<void> _seed(dynamic db) async {
    const samples = [
      Crop(name: 'Wheat', type: 'wheat', growthStage: 'Tillering', healthPercent: 85, status: 'good'),
      Crop(name: 'Cotton', type: 'cotton', growthStage: 'Flowering', healthPercent: 65, status: 'moderate'),
      Crop(name: 'Rice', type: 'rice', growthStage: 'Panicle', healthPercent: 80, status: 'good'),
      Crop(name: 'Maize', type: 'corn', growthStage: 'Vegetative', healthPercent: 40, status: 'at_risk'),
    ];
    for (final c in samples) {
      await db.insert('crops', c.toMap()..remove('id'));
    }
  }

  @override
  Future<void> add(Crop crop) async {
    final db = await LocalDatabase.instance();
    await db.insert('crops', crop.toMap()..remove('id'));
  }

  @override
  Future<void> remove(int id) async {
    final db = await LocalDatabase.instance();
    await db.delete('crops', where: 'id = ?', whereArgs: [id]);
  }
}
