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
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'database.db'),
      onCreate: (database, version) async {
        // Create Classroom table
        await database.execute(
          "CREATE TABLE Classroom(id INTEGER PRIMARY KEY AUTOINCREMENT, room TEXT, type TEXT)",
        );
        await database.execute(
          "CREATE TABLE LectureRoom(id INTEGER PRIMARY KEY AUTOINCREMENT, lecture_room TEXT)",
        );
        await database.execute(
          "CREATE TABLE LaboratoryRoom(id INTEGER PRIMARY KEY AUTOINCREMENT, laboratory_room TEXT)",
        );
        await database.execute(
          "CREATE TABLE Curriculum(course_id TEXT PRIMARY KEY, description TEXT, year TEXT, semester TEXT, units INTEGER, meeting TEXT, hasLab TEXT)",
        );
        await database.execute(
          "CREATE TABLE Faculty(id INTEGER PRIMARY KEY AUTOINCREMENT, firstname TEXT, lastname TEXT, position TEXT, min_load INTEGER, max_load INTEGER, priority_number INTEGER)",
        );
        // Create Assign table with foreign key constraints
        await database.execute(
          "CREATE TABLE Assign (id INTEGER PRIMARY KEY AUTOINCREMENT,  faculty_id INTEGER, course_id TEXT, room_id INTEGER, day TEXT, start_time TEXT, end_time TEXT, FOREIGN KEY (faculty_id) REFERENCES Faculty(id), FOREIGN KEY (course_id) REFERENCES Curriculum(course_id), FOREIGN KEY (room_id) REFERENCES Room(id))",
        );
      },
      version: 1,
    );
  }

  //classroom
  Future<int> addClassroom(String room, String type) async {
    final db = await database;
    return await db.insert(
      'Classroom',
      {
        'room': room,
        'type': type,
      },
    );
  }

  Future<int> addLectureRoom(String room) async {
    final db = await database;
    return await db.insert(
      'LectureRoom',
      {
        'lecture_room': room,
      },
    );
  }

  Future<int> addLaboratoryRoom(String room) async {
    final db = await database;
    return await db.insert(
      'LaboratoryRoom',
      {
        'laboratory_room': room,
      },
    );
  }

  Future<int> editClassroom(int id, String newRoom, String newType) async {
    final db = await database;
    return await db.update(
      'Classroom',
      {
        'room': newRoom,
        'type': newType,
      },
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> removeClassroom(int roomId) async {
    final db = await database;
    return await db.delete(
      'Classroom',
      where: "id = ?",
      whereArgs: [roomId],
    );
  }

  Future<int> removeAssignByRoomID(int roomId) async {
    final db = await database;
    return await db.delete(
      'Assign',
      where: "room_id = ?",
      whereArgs: [roomId],
    );
  }

  Future<List<Map<String, dynamic>>> getClassrooms() async {
    final db = await database;
    return await db.query('Classroom');
  }

  // Function to get lecture rooms
  Future<List<Map<String, dynamic>>> getLectureRooms() async {
    final db = await database;
    return await db
        .query('Classroom', where: 'type = ?', whereArgs: ['Lecture Class']);
  }

  // Function to get laboratory rooms
  Future<List<Map<String, dynamic>>> getLaboratoryRooms() async {
    final db = await database;
    return await db
        .query('Classroom', where: 'type = ?', whereArgs: ['Laboratory Class']);
  }

  //curriculum
  Future<int> addCurriculum(
    String course,
    String description,
    String year,
    String semester,
    int units,
    String meeting,
    String hasLab,
  ) async {
    final db = await database;
    return await db.insert(
      'Curriculum',
      {
        'course_id': course,
        'description': description,
        'year': year,
        'semester': semester,
        'units': units,
        'meeting': meeting,
        'hasLab': hasLab
      },
    );
  }

  Future<int> editCurriculum(
      String course,
      String newDescription,
      String newYear,
      String newSemester,
      int newUnits,
      String newMeeting,
      String newHasLab) async {
    final db = await database;
    return await db.update(
      'Curriculum',
      {
        'description': newDescription,
        'year': newYear,
        'semester': newSemester,
        'units': newUnits,
        'meeting': newMeeting,
        'hasLab': newHasLab
      },
      where: "course_id = ?",
      whereArgs: [course],
    );
  }

  Future<int> removeCourse(String course) async {
    final db = await database;
    return await db.delete(
      'Curriculum',
      where: "course_id = ?",
      whereArgs: [course],
    );
  }

  Future<int> removeAssignByCourseID(String courseId) async {
    final db = await database;
    return await db.delete(
      'Assign',
      where: "course_id = ?",
      whereArgs: [courseId],
    );
  }

  Future<List<Map<String, dynamic>>> getCurriculum() async {
    final db = await database;
    return await db.query('Curriculum');
  }

  //faculty
  Future<int> addFaculty(
    String firstname,
    String lastname,
    String position,
    int minLoad,
    int maxLoad,
    int priorityNumber,
  ) async {
    final db = await database;
    return await db.insert(
      'Faculty',
      {
        'firstname': firstname,
        'lastname': lastname,
        'position': position,
        'min_load': minLoad,
        'max_load': maxLoad,
        'priority_number': priorityNumber,
      },
    );
  }

  Future<int> editFaculty(
    int id,
    String newFirstname,
    String newLastname,
    String newPosition,
    int newMinLoad,
    int newMaxLoad,
    int newPriorityNumber,
  ) async {
    final db = await database;
    return await db.update(
      'Faculty',
      {
        'firstname': newFirstname,
        'lastname': newLastname,
        'position': newPosition,
        'min_load': newMinLoad,
        'max_load': newMaxLoad,
        'priority_number': newPriorityNumber,
      },
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> removeFaculty(int id) async {
    final db = await database;
    return await db.delete(
      'Faculty',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> removeAssignByFacultyId(int facultyId) async {
    final db = await database;
    return await db.delete(
      'Assign',
      where: "faculty_id = ?",
      whereArgs: [facultyId],
    );
  }

  Future<List<Map<String, dynamic>>> getFaculty() async {
    final db = await database;
    return await db.query('Faculty');
  }

  // Assign
  // Future<int> addAssign(int facultyId, String courseId, int parse, String join,
  //     String s, String t) async {
  //   final db = await database;
  //   return await db.insert(
  //     'Assign',
  //     {
  //       'faculty_id': facultyId,
  //       'course_id': courseId,
  //     },
  //   );
  // }

  Future<int> addAssign(int facultyId, String courseId, int roomId, String days,
      String startTime, String endTime) async {
    final db = await database;
    return await db.insert(
      'Assign',
      {
        'faculty_id': facultyId,
        'course_id': courseId,
        'room_id': roomId,
        'day': days,
        'start_time': startTime,
        'end_time': endTime,
      },
    );
  }

  Future<int> editAssign(int id, int newFacultyId, int newCourseId) async {
    final db = await database;
    return await db.update(
      'Assign',
      {
        'faculty_id': newFacultyId,
        'course_id': newCourseId,
      },
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> removeAssign(int id) async {
    final db = await database;
    return await db.delete(
      'Assign',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAssign() async {
    final db = await database;
    return await db.query('Assign');
  }

  Future<List<Map<String, dynamic>>> getAssignment() async {
    final db = await database;
    return await db.rawQuery('''
    SELECT 
      Faculty.firstname,
      Faculty.lastname,
      Curriculum.course_id,
      Classroom.room,
      day,
      start_time,
      end_time
    FROM Assign
    INNER JOIN Faculty ON Assign.faculty_id = Faculty.id
    INNER JOIN Curriculum ON Assign.course_id = Curriculum.course_id
    INNER JOIN Classroom ON Assign.room_id = Classroom.id
  ''');
  }

  // For assignment.dart
  // Future<List<Map<String, dynamic>>> getAssignment() async {
  //   final db = await database;
  //   return await db.rawQuery('''
  //   SELECT Faculty.firstname, Faculty.lastname, Curriculum.course
  //   FROM Assign
  //   INNER JOIN Faculty ON Assign.faculty_id = Faculty.id
  //   INNER JOIN Curriculum ON Assign.course_id = Curriculum.id
  // ''');
  // }
}
