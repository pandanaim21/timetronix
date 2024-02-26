import 'package:flutter/material.dart';
import 'package:timetronix/components/custom_assign_dialog.dart';
import 'package:timetronix/components/custom_course_dialog.dart';
import 'package:timetronix/components/format_time.dart';
import 'package:timetronix/db/db_helper.dart';

class AddAssigns extends StatefulWidget {
  const AddAssigns({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddAssignsState createState() => _AddAssignsState();
}

class _AddAssignsState extends State<AddAssigns> {
  final dbHelper = DatabaseHelper();

  String? _selectedFaculty;
  String? _selectedCourse;

  //for lecture
  // String? _selectedLectureRoom;
  // final Set<String> _selectedLectureDays = {};
  // String? _selectedLectureStartTime;
  // String? _selectedLectureEndTime;
  //for laboratory
  // String? _selectedLaboratoryRoom;
  // final Set<String> _selectedLabDays = {};
  // String? _selectedLabStartTime;
  // String? _selectedLabEndTime;
  //
  String? _selectedRoom;
  final Set<String> _selectedDays = {};
  String? _selectedStartTime;
  String? _selectedEndTime;

  List<DropdownMenuItem<String>> _facultyDropdownItems = [];
  List<Map<String, dynamic>> _courseDropdownItems = [];

  List<DropdownMenuItem<String>> _lectureRoomDropdownItems = [];
  List<DropdownMenuItem<String>> _laboratoryRoomDropdownItems = [];
  //List<DropdownMenuItem<String>> _roomDropdownItems = [];

  List<Map<String, dynamic>> assigns = [];

  final List<String> _days = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<Map<String, dynamic>> assignData = await dbHelper.getAssign();
    final faculties = await dbHelper.getFaculty();
    final courses = await dbHelper.getCurriculum();
    //final classrooms = await dbHelper.getClassrooms();
    final lecRooms = await dbHelper.getLectureRooms();
    final labRooms = await dbHelper.getLaboratoryRooms();

    setState(
      () {
        _facultyDropdownItems =
            faculties.map<DropdownMenuItem<String>>((faculty) {
          return DropdownMenuItem<String>(
            value: faculty['id'].toString(),
            child: Text(faculty['firstname'] + ' ' + faculty['lastname']),
          );
        }).toList();

        _courseDropdownItems = courses.map<Map<String, dynamic>>((course) {
          return {
            'id': course['id'].toString(),
            'course': course['course'],
            'hasLab': course['hasLab'],
          };
        }).toList();

        _lectureRoomDropdownItems =
            lecRooms.map<DropdownMenuItem<String>>((lecRoom) {
          return DropdownMenuItem<String>(
            value: lecRoom['id'].toString(),
            child: Text(lecRoom['room']),
          );
        }).toList();

        // _lectureRoomDropdownItems = classrooms
        //     .where((classroom) => classroom['type'] == 'Lecture Class')
        //     .map<DropdownMenuItem<String>>((classroom) {
        //   return DropdownMenuItem<String>(
        //     value: classroom['id'].toString(),
        //     child: Text(classroom['room']),
        //   );
        // }).toList();

        _laboratoryRoomDropdownItems =
            labRooms.map<DropdownMenuItem<String>>((labRoom) {
          return DropdownMenuItem<String>(
            value: labRoom['id'].toString(),
            child: Text(labRoom['room']),
          );
        }).toList();

        // _laboratoryRoomDropdownItems = classrooms
        //     .where((classroom) => classroom['type'] == 'Laboratory Class')
        //     .map<DropdownMenuItem<String>>((classroom) {
        //   return DropdownMenuItem<String>(
        //     value: classroom['id'].toString(),
        //     child: Text(classroom['room']),
        //   );
        // }).toList();

        assigns = assignData;
      },
    );
  }

  Future<Map<String, dynamic>> getAssignmentDetails(
      Map<String, dynamic> assign) async {
    final db = await dbHelper.initializeDatabase();
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

  // Future<Map<String, dynamic>> getAssignmentDetails(
  //     Map<String, dynamic> assign) async {
  //   final db = await dbHelper.initializeDatabase();
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

  String _formatTime(int hour, int minute) {
    return formatTime(hour, minute);
  }

  _showClassDialog(
      String className, List<DropdownMenuItem<String>> roomDropdownItems) {
    showCustomClassDialog(
      context,
      className,
      roomDropdownItems,
      //_laboratoryRoomDropdownItems,
      _selectedDays,
      //_selectedLabDays,
      _selectedRoom,
      //_selectedLaboratoryRoom,
      _selectedStartTime,
      _selectedEndTime,
      // _selectedLabStartTime,
      // _selectedLabEndTime,
      _days,
      (String? value) {
        _selectedRoom = value;
      },
      (String day) {
        if (_selectedDays.contains(day)) {
          _selectedDays.remove(day);
        } else {
          _selectedDays.add(day);
        }
      },
      (int hour, int minute) {
        _selectedStartTime = _formatTime(hour, minute);
      },
      (int hour, int minute) {
        _selectedEndTime = _formatTime(hour, minute);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Faculty'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < assigns.length; index++)
                FutureBuilder(
                  future: getAssignmentDetails(assigns[index]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final assignmentDetails = snapshot.data;
                      return Column(
                        children: [
                          Card(
                            color: Colors.blue[200],
                            elevation: 2,
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Faculty: ${assignmentDetails?['faculty_firstname']}, ${assignmentDetails?['faculty_lastname']}',
                                  ),
                                  Text(
                                    'Min Load: ${assignmentDetails?['min_load']}',
                                  ),
                                  Text(
                                    'Max Load: ${assignmentDetails?['max_load']}',
                                  ),
                                  Text(
                                    'Priority Number: ${assignmentDetails?['priority_number']}',
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Course: ${assignmentDetails?['course']}',
                                  ),
                                  Text(
                                    'Description: ${assignmentDetails?['description']}',
                                  ),
                                  Text(
                                    'Units: ${assignmentDetails?['units']}',
                                  ),
                                  Text(
                                    'Has Laboratory? ${assignmentDetails?['hasLab']}',
                                  ),
                                  const SizedBox(height: 10),
                                  const Text('Lecture Class:'),
                                  Text(
                                    'Lecture Days: ${assigns[index]['day']}',
                                  ),
                                  Text(
                                    'Lecture Start Time: ${assigns[index]['start_time']}',
                                  ),
                                  Text(
                                    'Lecture End Time: ${assigns[index]['end_time']}',
                                  ),
                                  Text(
                                    'Lecture Room: ${assignmentDetails?['room']}',
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  removeAssign(assigns[index]['id']);
                                },
                              ),
                            ),
                          ),
                          if (assignmentDetails?['hasLab'] == 'YES')
                            Card(
                              color: Colors.blue[200],
                              elevation: 2,
                              child: ListTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Faculty: ${assignmentDetails?['faculty_firstname']}, ${assignmentDetails?['faculty_lastname']}',
                                    ),
                                    Text(
                                      'Min Load: ${assignmentDetails?['min_load']}',
                                    ),
                                    Text(
                                      'Max Load: ${assignmentDetails?['max_load']}',
                                    ),
                                    Text(
                                      'Priority Number: ${assignmentDetails?['priority_number']}',
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Course: ${assignmentDetails?['course']}',
                                    ),
                                    Text(
                                      'Description: ${assignmentDetails?['description']}',
                                    ),
                                    Text(
                                      'Units: ${assignmentDetails?['units']}',
                                    ),
                                    Text(
                                      'Has Laboratory? ${assignmentDetails?['hasLab']}',
                                    ),
                                    const SizedBox(height: 10),
                                    const Text('Laboratory Class:'),
                                    Text(
                                      'Laboratory Days: ${assigns[index]['day']}',
                                    ),
                                    Text(
                                      'Lab Start Time: ${assigns[index]['start_time']}',
                                    ),
                                    Text(
                                      'Lab End Time: ${assigns[index]['end_time']}',
                                    ),
                                    Text(
                                      'Laboratory Room: ${assignmentDetails?['room']}',
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    removeAssign(assigns[index]['id']);
                                  },
                                ),
                              ),
                            ),
                        ],
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCustomAssignDialog(
            context,
            _facultyDropdownItems,
            _courseDropdownItems,
            (String? value) {
              _selectedFaculty = value;
            },
            (String? value) {
              _selectedCourse = value;
            },
            () {
              _showClassDialog('Lecture Class', _lectureRoomDropdownItems);
            },
            () {
              _showClassDialog(
                  'Laboratory Class', _laboratoryRoomDropdownItems);
            },
            () {
              addAssign();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void addAssign() async {
    await dbHelper.addAssign(
      int.parse(_selectedFaculty!),
      int.parse(_selectedCourse!),
      int.parse(_selectedRoom!),
      _selectedDays.join(', '),
      _selectedStartTime!,
      _selectedEndTime!,
    );
    _loadData();
  }

  // void addAssign() async {
  //   // String labStartTime = _selectedLabStartTime ?? 'N/A';
  //   // String labEndTime = _selectedLabEndTime ?? 'N/A';
  //   // String labDays =
  //   //     _selectedLabDays.isNotEmpty ? _selectedLabDays.join(', ') : 'N/A';

  //   await dbHelper.addAssign(
  //     int.parse(_selectedFaculty!),
  //     int.parse(_selectedCourse!),
  //     int.parse(_selectedRoom!),
  //     _selectedDays.join(', '),
  //     _selectedStartTime!,
  //     _selectedEndTime!,
  //   );
  //   _loadData();
  // }

  void removeAssign(int id) async {
    await dbHelper.removeAssign(id);
    _loadData();
  }
}
