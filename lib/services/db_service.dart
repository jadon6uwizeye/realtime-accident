import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/accident.dart';

// Updated DatabaseService class

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app3.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        plate_number TEXT NOT NULL,
        car_model TEXT NOT NULL,
        phone_number INTEGER NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE accidents (
        id INTEGER PRIMARY KEY,
        userId INTEGER,
        latitude TEXT,
        longitude TEXT,
        timestamp TEXT
      )
    ''');
  }

  // User Functions
  Future<int> createUser(User user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Accident Functions
  Future<int> initiateAccident(int userId) async {
    final db = await instance.database;
    final accident = Accident(
      userId: userId,
      latitude: -2.2406396093827334,
      longitude: 30.5255126953125,
      timestamp: DateTime.now().toIso8601String(),
    );
    return await db.insert('accidents', accident.toMap());
  }

  Future<int> logAccident(Accident accident) async {
    final db = await instance.database;
    return await db.insert('accidents', accident.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Accident>> getAccidents(int userId) async {
    final db = await instance.database;
    final maps = await db.query('accidents', where: 'userId = ?', whereArgs: [userId]);
    return maps.map((map) => Accident.fromMap(map)).toList();
  }
}
