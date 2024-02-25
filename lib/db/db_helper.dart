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
        // Create Curriculum table
        await database.execute(
          "CREATE TABLE Curriculum(id INTEGER PRIMARY KEY AUTOINCREMENT, course TEXT, description TEXT, year INTEGER, semester TEXT, units INTEGER, meeting TEXT, hasLab TEXT)",
        );
        // Create Faculty table
        await database.execute(
          "CREATE TABLE Faculty(id INTEGER PRIMARY KEY AUTOINCREMENT, firstname TEXT, lastname TEXT, position TEXT, min_load INTEGER, max_load INTEGER, priority_number INTEGER)",
        );
        // Create Assign table with foreign key constraints
        await database.execute(
          "CREATE TABLE Assign(id INTEGER PRIMARY KEY AUTOINCREMENT, faculty_id INTEGER, course_id INTEGER, classroom_id INTEGER, lecture_day TEXT, lecture_start_time TEXT, lecture_end_time TEXT, laboratory_day TEXT, laboratory_start_time TEXT, laboratory_end_time TEXT, FOREIGN KEY (faculty_id) REFERENCES Faculty(id), FOREIGN KEY (course_id) REFERENCES Curriculum(id), FOREIGN KEY (classroom_id) REFERENCES Classroom(id))",
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

  Future<List<Map<String, dynamic>>> getFaculty() async {
    final db = await database;
    return await db.query('Faculty');
  }

  // Assign
  Future<int> addAssign(
      int facultyId,
      int courseId,
      int lecRoomId,
      String lectureDay,
      String lectureStartTime,
      String lectureEndTime,
      String laboratoryDay,
      String laboratoryStartTime,
      String laboratoryEndTime) async {
    final db = await database;
    return await db.insert(
      'Assign',
      {
        'faculty_id': facultyId,
        'course_id': courseId,
        'classroom_id': lecRoomId,
        'lecture_day': lectureDay,
        'lecture_start_time': lectureStartTime,
        'lecture_end_time': lectureEndTime,
        'laboratory_day': laboratoryDay,
        'laboratory_start_time': laboratoryStartTime,
        'laboratory_end_time': laboratoryEndTime,
      },
    );
  }

  Future<int> editAssign(
      int id,
      int newFacultyId,
      int newCourseId,
      int newClassroomId,
      String newLectureDay,
      String newLectureStartTime,
      String newLectureEndTime,
      String newLaboratoryDay,
      String newLaboratoryStartTime,
      String newLaboratoryEndTime) async {
    final db = await database;
    return await db.update(
      'Assign',
      {
        'faculty_id': newFacultyId,
        'course_id': newCourseId,
        'classroom_id': newClassroomId,
        'lecture_day': newLectureDay,
        'lecture_start_time': newLectureStartTime,
        'lecture_end_time': newLectureEndTime,
        'laboratory_day': newLaboratoryDay,
        'laboratory_start_time': newLaboratoryStartTime,
        'laboratory_end_time': newLaboratoryEndTime,
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

  // //Getters
  // // Get room details by ID
  // Future<Map<String, dynamic>> getRoomDetails(String? roomId) async {
  //   final db = await database;
  //   List<Map<String, dynamic>> result = await db.query(
  //     'Classroom',
  //     where: 'id = ?',
  //     whereArgs: [roomId],
  //   );
  //   return result.isNotEmpty ? result.first : {};
  // }

  // // Get course details by ID
  // Future<Map<String, dynamic>> getCourseDetails(String? courseId) async {
  //   final db = await database;
  //   List<Map<String, dynamic>> result = await db.query(
  //     'Curriculum',
  //     where: 'id = ?',
  //     whereArgs: [courseId],
  //   );
  //   return result.isNotEmpty ? result.first : {};
  // }

  // // Get faculty details by ID
  // Future<Map<String, dynamic>> getFacultyDetails(String? facultyId) async {
  //   final db = await database;
  //   List<Map<String, dynamic>> result = await db.query(
  //     'Faculty',
  //     where: 'id = ?',
  //     whereArgs: [facultyId],
  //   );
  //   return result.isNotEmpty ? result.first : {};
  // }

  // // Get assignment details by ID
  // Future<Map<String, dynamic>> getAssignmentDetails(
  //     Map<String, dynamic> assign) async {
  //   final db = await initializeDatabase();
  //   final result = await db.rawQuery('''
  //   SELECT Faculty.firstname AS faculty_firstname, Curriculum.course, Classroom.room
  //   FROM Assign
  //   INNER JOIN Faculty ON Assign.faculty_id = Faculty.id
  //   INNER JOIN Curriculum ON Assign.course_id = Curriculum.id
  //   INNER JOIN Classroom ON Assign.classroom_id = Classroom.id
  //   WHERE Assign.id = ?
  // ''', [assign['id']]);
  //   return result.first;
  // }

  Future<Map<String, dynamic>> getAssignment(
      Map<String, dynamic> assign) async {
    final db = await initializeDatabase();
    final result = await db.rawQuery('''
    SELECT 
      Faculty.firstname AS faculty_firstname, 
      Faculty.lastname AS faculty_lastname,
      Faculty.min_load,
      Faculty.max_load,
      Faculty.priority_number,
      Curriculum.course, 
      Curriculum.description, 
      Curriculum.year, 
      Curriculum.semester, 
      Curriculum.units, 
      Curriculum.meeting, 
      Curriculum.hasLab, 
      Classroom.room, 
      Classroom.type
    FROM Assign
    INNER JOIN Faculty ON Assign.faculty_id = Faculty.id
    INNER JOIN Curriculum ON Assign.course_id = Curriculum.id
    INNER JOIN Classroom ON Assign.classroom_id = Classroom.id
    WHERE Assign.id = ?
  ''', [assign['id']]);
    return result.first;
  }
}
