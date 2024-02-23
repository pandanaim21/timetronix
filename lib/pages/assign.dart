import 'package:flutter/material.dart';
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

  void _showClassDialog(String className) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(className),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (className == 'Lecture Class')
                DropdownButton<String>(
                  items: _lectureRoomDropdownItems,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedLectureRoom = value;
                    });
                  },
                  value: _selectedLectureRoom,
                  hint: const Text('Select Lecture Room'),
                ),
              if (className == 'Laboratory Class')
                DropdownButton<String>(
                  items: _laboratoryRoomDropdownItems,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedLaboratoryRoom = value;
                    });
                  },
                  value: _selectedLaboratoryRoom,
                  hint: const Text('Select Laboratory Room'),
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _days
                    .map(
                      (day) => IconButton(
                        onPressed: () {
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
                        icon: Text(
                          day,
                          style: TextStyle(
                            color: (className == 'Lecture Class'
                                        ? _selectedLectureDays
                                        : _selectedLabDays)
                                    .contains(day)
                                ? Colors.red[900]
                                : Colors.black,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          if (className == 'Lecture Class') {
                            _selectedLectureStartTime =
                                _formatTime(picked.hour, picked.minute);
                          } else {
                            _selectedLabStartTime =
                                _formatTime(picked.hour, picked.minute);
                          }
                        });
                      }
                    },
                    child: SizedBox(
                      width: 150, // Set a fixed width
                      child: Text(
                        (className == 'Lecture Class'
                                ? _selectedLectureStartTime
                                : _selectedLabStartTime) ??
                            'Select Start Time',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(' - '),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          if (className == 'Lecture Class') {
                            _selectedLectureEndTime =
                                _formatTime(picked.hour, picked.minute);
                          } else {
                            _selectedLabEndTime =
                                _formatTime(picked.hour, picked.minute);
                          }
                        });
                      }
                    },
                    child: SizedBox(
                      width: 150, // Set a fixed width
                      child: Text(
                        (className == 'Lecture Class'
                                ? _selectedLectureEndTime
                                : _selectedLabEndTime) ??
                            'Select End Time',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Implement save functionality
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Implement save functionality
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        );
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Assign'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      isExpanded: true,
                      items: _facultyDropdownItems,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedFaculty = value;
                        });
                      },
                      value: _selectedFaculty,
                      hint: const Text('Select Faculty'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      isExpanded: true,
                      items: _courseDropdownItems,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedCourse = value;
                        });
                      },
                      value: _selectedCourse,
                      hint: const Text('Select Course'),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _showClassDialog('Lecture Class');
                          },
                          child: const Text('Lecture Class'),
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton(
                          onPressed: () {
                            _showClassDialog('Laboratory Class');
                          },
                          child: const Text('Laboratory Class'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        addAssign();
                        // Call the addAssign function here
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Assignments',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
                      return Card(
                        elevation: 2,
                        child: ListTile(
                          title: Text('Assignment ${index + 1}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Priority Number: ${assigns[index]['priority_number']}'),
                              Text(
                                  'Faculty: ${assignmentDetails?['faculty_firstname']}'),
                              Text('Course: ${assignmentDetails?['course']}'),
                              const SizedBox(height: 20),
                              const Text('Lecture Class:'),
                              Text(
                                  'Lecture Days: ${assigns[index]['lecture_day']}'),
                              Text(
                                  'Lecture Start Time: ${assigns[index]['lecture_start_time']}'),
                              Text(
                                  'Lecture End Time: ${assigns[index]['lecture_end_time']}'),
                              const SizedBox(height: 20),
                              const Text('Laboratory Class:'),
                              Text(
                                  'Lecture Room: ${assignmentDetails?['room']}'),
                              Text(
                                  'Lab Start Time: ${assigns[index]['laboratory_start_time']}'),
                              Text(
                                  'Lab End Time: ${assigns[index]['laboratory_end_time']}'),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
            ],
          ),
        ),
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
      print('Assign added successfully!');
    } else {
      print('Please select all required fields.');
    }
    _loadData();
  }
}
