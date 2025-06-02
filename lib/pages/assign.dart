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
  String? _selectedRoom;

  final Set<String> _selectedDays = {};
  String? _selectedStartTime;
  String? _selectedEndTime;

  //List<DropdownMenuItem<String>> _facultyDropdownItems = [];
  List<Map<String, dynamic>> _facultyDropdownItems = [];
  List<Map<String, dynamic>> _courseDropdownItems = [];
  // List<DropdownMenuItem<String>> _lectureRoomDropdownItems = [];
  // List<DropdownMenuItem<String>> _laboratoryRoomDropdownItems = [];
  List<Map<String, dynamic>> _lectureRoomDropdownItems = [];
  List<Map<String, dynamic>> _laboratoryRoomDropdownItems = [];
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
    final lecRooms = await dbHelper.getLectureRooms();
    final labRooms = await dbHelper.getLaboratoryRooms();

    setState(
      () {
        // _facultyDropdownItems =
        //     faculties.map<DropdownMenuItem<String>>((faculty) {
        //   return DropdownMenuItem<String>(
        //     value: faculty['id'].toString(),
        //     child: Text(faculty['firstname'] + ' ' + faculty['lastname']),
        //   );
        // }).toList();

        _facultyDropdownItems = faculties.map<Map<String, dynamic>>((faculty) {
          return {
            'faculty_id': faculty['id'].toString(),
            'firstname': faculty['firstname'],
            'lastname': faculty['lastname'],
          };
        }).toList();

        _courseDropdownItems = courses.map<Map<String, dynamic>>((course) {
          return {
            'course_id': course['course_id'].toString(),
            'course': course['course'],
            'hasLab': course['hasLab'],
          };
        }).toList();

        // _lectureRoomDropdownItems =
        //     lecRooms.map<DropdownMenuItem<String>>((lecRoom) {
        //   return DropdownMenuItem<String>(
        //     value: lecRoom['id'].toString(),
        //     child: Text(lecRoom['room']),
        //   );
        // }).toList();

        // _laboratoryRoomDropdownItems =
        //     labRooms.map<DropdownMenuItem<String>>((labRoom) {
        //   return DropdownMenuItem<String>(
        //     value: labRoom['id'].toString(),
        //     child: Text(labRoom['room']),
        //   );
        // }).toList();

        _lectureRoomDropdownItems =
            lecRooms.map<Map<String, dynamic>>((lecRoom) {
          return {
            'room_id': lecRoom['id'].toString(),
            'room': lecRoom['room'],
            'type': lecRoom['type'],
          };
        }).toList();

        _laboratoryRoomDropdownItems =
            labRooms.map<Map<String, dynamic>>((labRoom) {
          return {
            'room_id': labRoom['id'].toString(),
            'room': labRoom['room'],
            'type': labRoom['type'],
          };
        }).toList();

        assigns = assignData;
      },
    );
  }

  String _formatTime(int hour, int minute) {
    return formatTime(hour, minute);
  }

  _showClassDialog(
      String className, List<Map<String, dynamic>> roomDropdownItems) {
    showCustomClassDialog(
      context,
      className,
      roomDropdownItems,
      _selectedDays,
      _selectedRoom,
      _selectedStartTime,
      _selectedEndTime,
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
      _resetVariables,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Faculty'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
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
                          _showClassDialog(
                            'Lecture Class',
                            _lectureRoomDropdownItems,
                          );
                        },
                        () {
                          addAssign();
                        },
                        _resetVariables,
                        'Lecture Class',
                      );
                    },
                    child: const Text('Add Lecture'),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
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
                          _showClassDialog(
                            'Laboratory Class',
                            _laboratoryRoomDropdownItems,
                          );
                        },
                        () {
                          addAssign();
                        },
                        _resetVariables,
                        'Laboratory Class',
                      );
                    },
                    child: const Text('Add Laboratory'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: dbHelper.getAssignment(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final assignments = snapshot.data!;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final totalWidth = constraints.maxWidth;
                        final columnWidth = totalWidth / 6;

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: totalWidth),
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                  Colors.deepPurple.shade100),
                              dataRowColor:
                                  WidgetStateProperty.all(Colors.white),
                              border:
                                  TableBorder.all(color: Colors.grey.shade300),
                              columnSpacing:
                                  0, // We'll use fixed widths instead
                              columns: const [
                                DataColumn(
                                    label: Text('Faculty',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Course',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Day',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Room',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Start Time',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('End Time',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                              ],

                              rows: assignments.map((assignment) {
                                final facultyName =
                                    '${assignment['firstname']} ${assignment['lastname']}';
                                final courseID = assignment['course_id'];
                                final day = assignment['day'];
                                final room = assignment['room'];
                                final startTime = assignment['start_time'];
                                final endTime = assignment['end_time'];

                                return DataRow(
                                  cells: [
                                    DataCell(SizedBox(
                                        width: columnWidth,
                                        child: Text(facultyName))),
                                    DataCell(SizedBox(
                                        width: columnWidth,
                                        child: Text(courseID))),
                                    DataCell(SizedBox(
                                        width: columnWidth, child: Text(day))),
                                    DataCell(SizedBox(
                                        width: columnWidth,
                                        child: Text(room.toString()))),
                                    DataCell(SizedBox(
                                        width: columnWidth,
                                        child: Text(startTime))),
                                    DataCell(SizedBox(
                                        width: columnWidth,
                                        child: Text(endTime))),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            )
            // Expanded(
            //   child: FutureBuilder<List<Map<String, dynamic>>>(
            //     future: dbHelper.getAssignment(),
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return const Center(child: CircularProgressIndicator());
            //       } else if (snapshot.hasError) {
            //         return Center(child: Text('Error: ${snapshot.error}'));
            //       } else {
            //         final assignments = snapshot.data!;
            //         return ListView.builder(
            //           itemCount: assignments.length,
            //           itemBuilder: (context, index) {
            //             final assignment = assignments[index];
            //             final facultyName =
            //                 '${assignment['firstname']} ${assignment['lastname']}';
            //             final courseID = assignment['course_id'];
            //             final room = assignment['room'];
            //             final startTime = assignment['start_time'];
            //             final endTime = assignment['end_time'];
            //             return Padding(
            //               padding: const EdgeInsets.symmetric(vertical: 8.0),
            //               child: Row(
            //                 children: [
            //                   Expanded(
            //                     child: Card(
            //                       child: Padding(
            //                         padding: const EdgeInsets.all(8.0),
            //                         child: Text(
            //                           'Faculty: $facultyName',
            //                           style: const TextStyle(fontSize: 16.0),
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                   Expanded(
            //                     child: Card(
            //                       child: Padding(
            //                         padding: const EdgeInsets.all(8.0),
            //                         child: Text(
            //                           'Course: $courseID',
            //                           style: const TextStyle(fontSize: 16.0),
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                   Expanded(
            //                     child: Card(
            //                       child: Padding(
            //                         padding: const EdgeInsets.all(8.0),
            //                         child: Text(
            //                           'Room: $room',
            //                           style: const TextStyle(fontSize: 16.0),
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                   Expanded(
            //                     child: Card(
            //                       child: Padding(
            //                         padding: const EdgeInsets.all(8.0),
            //                         child: Text(
            //                           'Start Time: $startTime',
            //                           style: const TextStyle(fontSize: 16.0),
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                   Expanded(
            //                     child: Card(
            //                       child: Padding(
            //                         padding: const EdgeInsets.all(8.0),
            //                         child: Text(
            //                           'End Time: $endTime',
            //                           style: const TextStyle(fontSize: 16.0),
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             );
            //           },
            //         );
            //       }
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _resetVariables() {
    setState(() {
      _selectedRoom = null;
      _selectedDays.clear();
      _selectedStartTime = null;
      _selectedEndTime = null;
    });
  }

  void addAssign() async {
    await dbHelper.addAssign(
      int.parse(_selectedFaculty!),
      _selectedCourse!,
      int.parse(_selectedRoom!),
      _selectedDays.join(', '),
      _selectedStartTime!,
      _selectedEndTime!,
    );
    _loadData();
  }

  //assigment.dart
  // void removeAssign(int id) async {
  //   await dbHelper.removeAssign(id);
  //   _loadData();
  // }
}
