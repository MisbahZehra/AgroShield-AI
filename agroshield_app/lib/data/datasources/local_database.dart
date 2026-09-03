import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static Database? _db;

  static Future<Database> instance() async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dir, 'agroshield.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE scans(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            imagePath TEXT NOT NULL,
            crop TEXT NOT NULL,
            disease TEXT NOT NULL,
            confidence REAL NOT NULL,
            affectedArea REAL NOT NULL,
            severity TEXT NOT NULL,
            risk TEXT NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE crops(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            growthStage TEXT NOT NULL,
            healthPercent INTEGER NOT NULL,
            status TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }
}
