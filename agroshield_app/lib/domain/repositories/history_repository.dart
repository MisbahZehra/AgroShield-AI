import '../../data/models/scan_record.dart';

abstract class HistoryRepository {
  Future<int> save(ScanRecord record);
  Future<List<ScanRecord>> all();
  Future<ScanRecord?> byId(int id);
  Future<void> delete(int id);
  Future<void> clear();
}
