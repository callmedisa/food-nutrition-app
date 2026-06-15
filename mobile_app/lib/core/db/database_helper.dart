import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'nutriscan.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Таблица дневника питания
    await db.execute('''
      CREATE TABLE meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        food_id TEXT,
        food_name TEXT,
        food_name_ru TEXT,
        food_name_kz TEXT,
        food_calories REAL,
        food_protein REAL,
        food_fat REAL,
        food_carbs REAL,
        food_category TEXT,
        food_emoji TEXT,
        grams REAL NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');

    // Таблица профиля пользователя (единственная строка, id=1)
    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY,
        name TEXT,
        age INTEGER,
        weight REAL,
        height REAL,
        gender TEXT,
        activity TEXT
      )
    ''');

    // Таблица настроек (locale, themeMode и т.д.)
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  // Convenience: get/set a setting string
  static Future<String?> getSetting(String key) async {
    final db = await database;
    final rows = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  static Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}