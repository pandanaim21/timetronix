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
      join(path, 'classroom.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE Classroom(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<int> addClassroom(String name) async {
    final db = await database;
    return await db.insert('Classroom', {'name': name});
  }

  Future<int> editClassroom(int id, String newName) async {
    final db = await database;
    return await db.update(
      'Classroom',
      {'name': newName},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> removeClassroom(String name) async {
    final db = await database;
    return await db.delete(
      'Classroom',
      where: "name = ?",
      whereArgs: [name],
    );
  }

  Future<List<String>> getClassrooms() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('Classroom');
    return List.generate(maps.length, (i) {
      return maps[i]['name'];
    });
  }
}
