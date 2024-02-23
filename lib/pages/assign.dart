import 'package:flutter/material.dart';
import 'package:timetronix/components/custom_assign_dialog.dart';
import 'package:timetronix/components/custom_showClass_dialog.dart';
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
  String? _selectedLectureRoom;
  String? _selectedLaboratoryRoom;

  String? _selectedLectureStartTime;
  String? _selectedLectureEndTime;
  final Set<String> _selectedLectureDays = {};

  String? _selectedLabStartTime;
  String? _selectedLabEndTime;
  final Set<String> _selectedLabDays = {};

  List<DropdownMenuItem<String>> _facultyDropdownItems = [];
  List<DropdownMenuItem<String>> _courseDropdownItems = [];
  List<DropdownMenuItem<String>> _lectureRoomDropdownItems = [];
  List<DropdownMenuItem<String>> _laboratoryRoomDropdownItems = [];
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
    final classrooms = await dbHelper.getClassrooms();

    setState(
      () {
        _facultyDropdownItems =
            faculties.map<DropdownMenuItem<String>>((faculty) {
          return DropdownMenuItem<String>(
            value: faculty['id'].toString(),
            child: Text(faculty['firstname'] + ' ' + faculty['lastname']),
          );
        }).toList();

        _courseDropdownItems = courses.map<DropdownMenuItem<String>>((course) {
          return DropdownMenuItem<String>(
            value: course['id'].toString(),
            child: Text(course['course']),
          );
        }).toList();

        _lectureRoomDropdownItems = classrooms
            .where((classroom) => classroom['type'] == 'Lecture Class')
            .map<DropdownMenuItem<String>>((classroom) {
          return DropdownMenuItem<String>(
            value: classroom['id'].toString(),
            child: Text(classroom['room']),
          );
        }).toList();

        _laboratoryRoomDropdownItems = classrooms
            .where((classroom) => classroom['type'] == 'Laboratory Class')
            .map<DropdownMenuItem<String>>((classroom) {
          return DropdownMenuItem<String>(
            value: classroom['id'].toString(),
            child: Text(classroom['room']),
          );
        }).toList();

        assigns = assignData;
      },
    );
  }

  Future<Map<String, dynamic>> getAssignmentDetails(
      Map<String, dynamic> assign) async {
    final db = await dbHelper.initializeDatabase();
    final result = await db.rawQuery('''
    SELECT Faculty.firstname AS faculty_firstname, Curriculum.course, Classroom.room
    FROM Assign
    INNER JOIN Faculty ON Assign.faculty_id = Faculty.id
    INNER JOIN Curriculum ON Assign.course_id = Curriculum.id
    INNER JOIN Classroom ON Assign.classroom_id = Classroom.id
    WHERE Assign.id = ?
  ''', [assign['id']]);
    //await db.close();
    return result.first;
  }

  _showClassDialog(String className) {
    showCustomClassDialog(
      context,
      className,
      _lectureRoomDropdownItems,
      _laboratoryRoomDropdownItems,
      _selectedLectureDays,
      _selectedLabDays,
      _selectedLectureRoom,
      _selectedLaboratoryRoom,
      _selectedLectureStartTime,
      _selectedLectureEndTime,
      _selectedLabStartTime,
      _selectedLabEndTime,
      _days,
      (String? value) {
        setState(() {
          _selectedLectureRoom = value;
        });
      },
      (String? value) {
        setState(() {
          _selectedLaboratoryRoom = value;
        });
      },
      (String day) {
        setState(() {
          if (className == 'Lecture Class') {
            if (_selectedLectureDays.contains(day)) {
              _selectedLectureDays.remove(day);
            } else {
              _selectedLectureDays.add(day);
            }
          } else {
            if (_selectedLabDays.contains(day)) {
              _selectedLabDays.remove(day);
            } else {
              _selectedLabDays.add(day);
            }
          }
        });
      },
      (int hour, int minute) {
        setState(() {
          if (className == 'Lecture Class') {
            _selectedLectureStartTime = _formatTime(hour, minute);
          } else {
            _selectedLabStartTime = _formatTime(hour, minute);
          }
        });
      },
      (int hour, int minute) {
        setState(() {
          if (className == 'Lecture Class') {
            _selectedLectureEndTime = _formatTime(hour, minute);
          } else {
            _selectedLabEndTime = _formatTime(hour, minute);
          }
        });
      },
      (int hour, int minute) {
        setState(() {
          if (className == 'Lecture Class') {
            _selectedLectureStartTime = _formatTime(hour, minute);
          } else {
            _selectedLabStartTime = _formatTime(hour, minute);
          }
        });
      },
      (int hour, int minute) {
        setState(() {
          if (className == 'Lecture Class') {
            _selectedLectureEndTime = _formatTime(hour, minute);
          } else {
            _selectedLabEndTime = _formatTime(hour, minute);
          }
        });
      },
    );
  }

  String _formatTime(int hour, int minute) {
    final String period = hour < 12 ? 'AM' : 'PM';
    final int hourOfDay = hour % 12 == 0 ? 12 : hour % 12;
    return '$hourOfDay:${minute.toString().padLeft(2, '0')} $period';
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
                            elevation: 2,
                            child: ListTile(
                              title: Text('Assignment ${index + 1}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Priority Number: ${assigns[index]['priority_number']}',
                                  ),
                                  Text(
                                    'Faculty: ${assignmentDetails?['faculty_firstname']}',
                                  ),
                                  Text(
                                    'Course: ${assignmentDetails?['course']}',
                                  ),
                                  const SizedBox(height: 10),
                                  const Text('Lecture Class:'),
                                  Text(
                                    'Lecture Days: ${assigns[index]['lecture_day']}',
                                  ),
                                  Text(
                                    'Lecture Start Time: ${assigns[index]['lecture_start_time']}',
                                  ),
                                  Text(
                                    'Lecture End Time: ${assigns[index]['lecture_end_time']}',
                                  ),
                                  Text(
                                    'Lecture Room: ${assignmentDetails?['room']}',
                                  ),
                                  const SizedBox(height: 10),
                                  const Text('Laboratory Class:'),
                                  Text(
                                    'Laboratory Days: ${assigns[index]['laboratory_day']}',
                                  ),
                                  Text(
                                    'Lab Start Time: ${assigns[index]['laboratory_start_time']}',
                                  ),
                                  Text(
                                    'Lab End Time: ${assigns[index]['laboratory_end_time']}',
                                  ),
                                  Text(
                                    'Laboratory Room: ${assignmentDetails?['room']}',
                                  ),
                                ],
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
              setState(() {
                _selectedFaculty = value;
              });
            },
            (String? value) {
              setState(() {
                _selectedCourse = value;
              });
            },
            () {
              _showClassDialog('Lecture Class');
            },
            () {
              _showClassDialog('Laboratory Class');
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
    if (_selectedFaculty != null &&
        _selectedCourse != null &&
        _selectedLectureRoom != null &&
        _selectedLaboratoryRoom != null &&
        _selectedLectureDays.isNotEmpty &&
        _selectedLabDays.isNotEmpty &&
        _selectedLectureStartTime != null &&
        _selectedLectureEndTime != null &&
        _selectedLabStartTime != null &&
        _selectedLabEndTime != null) {
      await dbHelper.addAssign(
        int.parse(_selectedFaculty!),
        int.parse(_selectedCourse!),
        int.parse(_selectedLectureRoom!),
        _selectedLectureDays.join(', '),
        _selectedLectureStartTime!,
        _selectedLectureEndTime!,
        _selectedLabDays.join(', '),
        _selectedLabStartTime!,
        _selectedLabEndTime!,
        1,
      );
    }
    _loadData();
  }
}
