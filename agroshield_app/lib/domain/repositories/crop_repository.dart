import '../../data/models/crop.dart';

abstract class CropRepository {
  Future<List<Crop>> all();
  Future<void> add(Crop crop);
  Future<void> remove(int id);
}
