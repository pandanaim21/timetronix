import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    // Initialize sqflite ffi
    sqfliteFfiInit();
    // Set databaseFactory to use ffi
    databaseFactory = databaseFactoryFfi;

    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'classrooms.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE Classroom(id INTEGER PRIMARY KEY AUTOINCREMENT, room TEXT, type TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<int> addClassroom(String room, String type) async {
    final db = await database;
    return await db.insert('Classroom', {'room': room, 'type': type});
  }

  Future<int> editClassroom(int id, String newRoom, String newType) async {
    final db = await database;
    return await db.update(
      'Classroom',
      {'room': newRoom, 'type': newType},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> removeClassroom(String room) async {
    final db = await database;
    return await db.delete(
      'Classroom',
      where: "room = ?",
      whereArgs: [room],
    );
  }

  Future<List<Map<String, dynamic>>> getClassrooms() async {
    final db = await database;
    return await db.query('Classroom');
  }
}
