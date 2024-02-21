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
      join(path, 'db.db'),
      onCreate: (database, version) async {
        // Create Classroom table
        await database.execute(
          "CREATE TABLE Classroom(id INTEGER PRIMARY KEY AUTOINCREMENT, room TEXT, type TEXT)",
        );
        // Create Curriculum table
        await database.execute(
          "CREATE TABLE Curriculum(id INTEGER PRIMARY KEY AUTOINCREMENT, course TEXT, description TEXT, year INTEGER, semester TEXT, units INTEGER, meeting TEXT, hasLab TEXT)",
        );
        // Create Faculty table
        await database.execute(
          "CREATE TABLE Faculty(id INTEGER PRIMARY KEY AUTOINCREMENT, firstname TEXT, lastname TEXT, position TEXT, priority_number INTEGER)",
        );
        // Create Assign table
        await database.execute(
          "CREATE TABLE Assign(id INTEGER PRIMARY KEY AUTOINCREMENT, faculty_name TEXT, course TEXT, lecture_day TEXT, lecture_time TEXT, lecture_room TEXT, laboratory_day TEXT, laboratory_time TEXT, laboratory_room TEXT, priority_number INTEGER)",
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

  //curriculum
  Future<int> addCurriculum(String course, String description, String year,
      String semester, int units, String meeting, String hasLab) async {
    final db = await database;
    return await db.insert(
      'Curriculum',
      {
        'course': course,
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
      int id,
      String newCourse,
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
        'course': newCourse,
        'description': newDescription,
        'year': newYear,
        'semester': newSemester,
        'units': newUnits,
        'meeting': newMeeting,
        'hasLab': newHasLab
      },
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> removeCurriculum(int id) async {
    final db = await database;
    return await db.delete(
      'Curriculum',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getCurriculum() async {
    final db = await database;
    return await db.query('Curriculum');
  }

  //faculty
  Future<int> addFaculty(String firstname, String lastname, String position,
      int priorityNumber) async {
    final db = await database;
    return await db.insert(
      'Faculty',
      {
        'firstname': firstname,
        'lastname': lastname,
        'position': position,
        'priority_number': priorityNumber,
      },
    );
  }

  Future<int> editFaculty(int id, String newFirstname, String newLastname,
      String newPosition, int newPriorityNumber) async {
    final db = await database;
    return await db.update(
      'Faculty',
      {
        'firstname': newFirstname,
        'lastname': newLastname,
        'position': newPosition,
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

  Future<List<Map<String, dynamic>>> getFaculty() async {
    final db = await database;
    return await db.query('Faculty');
  }

  // Assign
  Future<int> addAssign(
      String facultyName,
      String course,
      String lectureDay,
      String lectureTime,
      String lectureRoom,
      String laboratoryDay,
      String laboratoryTime,
      String laboratoryRoom,
      int priorityNumber) async {
    final db = await database;
    return await db.insert(
      'Assign',
      {
        'faculty_name': facultyName,
        'course': course,
        'lecture_day': lectureDay,
        'lecture_time': lectureTime,
        'lecture_room': lectureRoom,
        'laboratory_day': laboratoryDay,
        'laboratory_time': laboratoryTime,
        'laboratory_room': laboratoryRoom,
        'priority_number': priorityNumber
      },
    );
  }

  Future<int> editAssign(
      int id,
      String newFacultyName,
      String newCourse,
      String newLectureDay,
      String newLectureTime,
      String newLectureRoom,
      String newLaboratoryDay,
      String newLaboratoryTime,
      String newLaboratoryRoom,
      int newPriorityNumber) async {
    final db = await database;
    return await db.update(
      'Assign',
      {
        'faculty_name': newFacultyName,
        'course': newCourse,
        'lecture_day': newLectureDay,
        'lecture_time': newLectureTime,
        'lecture_room': newLectureRoom,
        'laboratory_day': newLaboratoryDay,
        'laboratory_time': newLaboratoryTime,
        'laboratory_room': newLaboratoryRoom,
        'priority_number': newPriorityNumber
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

  Future<List<Map<String, dynamic>>> getAssigns() async {
    final db = await database;
    return await db.query('Assign');
  }

  //Getters
  // Get room details by ID
  Future<Map<String, dynamic>> getRoomDetails(String? roomId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'Classroom',
      where: 'id = ?',
      whereArgs: [roomId],
    );
    return result.isNotEmpty ? result.first : {};
  }

  // Get course details by ID
  Future<Map<String, dynamic>> getCourseDetails(String? courseId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'Curriculum',
      where: 'id = ?',
      whereArgs: [courseId],
    );
    return result.isNotEmpty ? result.first : {};
  }

  // Get faculty details by ID
  Future<Map<String, dynamic>> getFacultyDetails(String? facultyId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'Faculty',
      where: 'id = ?',
      whereArgs: [facultyId],
    );
    return result.isNotEmpty ? result.first : {};
  }

  // Get assignment details by ID
  Future<Map<String, dynamic>> getAssignmentDetails(int? assignmentId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'Assign',
      where: 'id = ?',
      whereArgs: [assignmentId],
    );
    return result.isNotEmpty ? result.first : {};
  }
}
