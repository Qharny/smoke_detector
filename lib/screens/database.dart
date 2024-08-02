import 'package:smoketector/model/reading.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gas_readings.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE gas_readings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      level REAL,
      timestamp TEXT
    )
    ''');
  }

  Future<int> insertReading(GasReading reading) async {
    final db = await database;
    return await db.insert('gas_readings', reading.toMap());
  }

  Future<List<GasReading>> getReadings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('gas_readings');
    return List.generate(maps.length, (i) {
      return GasReading.fromMap(maps[i]);
    });
  }
}