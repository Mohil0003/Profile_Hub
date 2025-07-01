import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user.dart';
import 'package:sqflite_common/sqlite_api.dart';


class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    late Database db;
    
    if (kIsWeb) {
      // Web-specific initialization
      var factory = createDatabaseFactoryFfiWeb();
      db = await factory.openDatabase(
        'matrimony.db',
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _createDb,
        ),
      );
    } else {
      // Mobile-specific initialization
      sqfliteFfiInit();
      String path = join(await getDatabasesPath(), 'matrimony.db');
       db = await openDatabase(path,
          onCreate: (db, version) async {
            await _createDb(db, version);
          },
         onUpgrade: (db, oldVersion, newVersion) {

         },
         version: 1
      );
    }

    return db;
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        city TEXT NOT NULL,
        password TEXT NOT NULL,
        birthdate TEXT NOT NULL,
        gender TEXT NOT NULL,
        hobbies TEXT NOT NULL,
        isFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> toggleFavorite(int id) async {
    final db = await database;
    
    // Get current favorite status
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['isFavorite'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      final currentStatus = result.first['isFavorite'] == 1;
      final newStatus = !currentStatus;
      
      await db.update(
        'users',
        {'isFavorite': newStatus ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // Helper method to delete all data (for testing)
  Future<void> deleteAllUsers() async {
    final db = await database;
    await db.delete('users');
  }

  createDatabaseFactoryFfiWeb() {}

  Future<int> insertUser(User user) async {
    final db = await database;
    
    // Check if email already exists
    final existingUser = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [user.email],
    );

    if (existingUser.isNotEmpty) {
      throw Exception('Email already registered');
    }

    // Insert the new user
    final id = await db.insert('users', user.toMap());
    
    return id;
  }
}