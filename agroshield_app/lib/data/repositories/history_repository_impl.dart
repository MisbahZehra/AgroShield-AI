import '../../domain/repositories/history_repository.dart';
import '../datasources/local_database.dart';
import '../models/scan_record.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  @override
  Future<int> save(ScanRecord record) async {
    final db = await LocalDatabase.instance();
    return db.insert('scans', record.toMap()..remove('id'));
  }

  @override
  Future<List<ScanRecord>> all() async {
    final db = await LocalDatabase.instance();
    final rows = await db.query('scans', orderBy: 'timestamp DESC');
    return rows
        .map((r) => ScanRecord.fromMap(Map<String, Object?>.from(r)))
        .toList();
  }

  @override
  Future<ScanRecord?> byId(int id) async {
    final db = await LocalDatabase.instance();
    final rows = await db.query('scans', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return ScanRecord.fromMap(Map<String, Object?>.from(rows.first));
  }

  @override
  Future<void> delete(int id) async {
    final db = await LocalDatabase.instance();
    await db.delete('scans', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> clear() async {
    final db = await LocalDatabase.instance();
    await db.delete('scans');
  }
}
