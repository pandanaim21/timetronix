import 'package:flutter/material.dart';
import 'package:timetronix/components/dictionary.dart';
import 'package:timetronix/db/db_helper.dart';

class EditSchedule extends StatefulWidget {
  const EditSchedule({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EditScheduleState createState() => _EditScheduleState();
}

class _EditScheduleState extends State<EditSchedule> {
  final dbHelper = DatabaseHelper();
  // ignore: prefer_collection_literals
  Set<String> selectedDays = Set();

  String? selectedFacultyId;
  String? selectedCourseId;
  String? selectedLecRoomId;
  String? selectedLabRoomId;
  int units = 0;
  String? position;
  int priorityNumber = 0;
  String? selectedStartTime;
  String? selectedEndTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Schedule',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: const Center(
        child: Text('Schedule Page'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddItemDialog(context);
        },
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddItemDialog(BuildContext context) async {
    TextEditingController positionController =
        TextEditingController(text: position);
    TextEditingController priorityController =
        TextEditingController(text: priorityNumber.toString());
    TextEditingController descriptionController = TextEditingController();
    TextEditingController yearController = TextEditingController();
    TextEditingController semesterController = TextEditingController();
    TextEditingController unitsController =
        TextEditingController(text: units.toString());
    TextEditingController meetingsController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Assign Faculty"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: dbHelper.getFaculty(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else {
                      List<DropdownMenuItem<String>> facultyItems = [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Select Faculty'),
                        ),
                      ];
                      for (var faculty in snapshot.data!) {
                        facultyItems.add(
                          DropdownMenuItem(
                            value: faculty['id'].toString(),
                            child: Text(faculty['firstname'] +
                                ' ' +
                                faculty['lastname']),
                          ),
                        );
                      }
                      return DropdownButton<String>(
                        isExpanded: true,
                        value: selectedFacultyId,
                        items: facultyItems,
                        onChanged: (value) async {
                          setState(() {
                            selectedFacultyId = value;
                          });
                          Map<String, dynamic> facultyDetails = await dbHelper
                              .getFacultyDetails(selectedFacultyId);
                          setState(() {
                            positionController.text =
                                facultyDetails['position'] ?? '';
                            priorityController.text =
                                facultyDetails['priority_number']?.toString() ??
                                    '';
                          });
                        },
                      );
                    }
                  },
                ),
                TextField(
                  controller: positionController,
                  decoration: const InputDecoration(labelText: 'Position'),
                ),
                const SizedBox(height: 10),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: dbHelper.getCurriculum(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else {
                      List<DropdownMenuItem<String>> courseItems = [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Select Course'),
                        ),
                      ];

                      for (var course in snapshot.data!) {
                        courseItems.add(
                          DropdownMenuItem(
                            value: course['id'].toString(),
                            child: Text(course['course']),
                          ),
                        );
                      }
                      return DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCourseId,
                        items: courseItems,
                        onChanged: (value) async {
                          setState(() {
                            selectedCourseId = value;
                          });
                          // Fetch course details based on selectedCourseId
                          Map<String, dynamic> courseDetails =
                              await dbHelper.getCourseDetails(selectedCourseId);
                          setState(() {
                            descriptionController.text =
                                courseDetails['description'] ?? '';
                            yearController.text = courseDetails['year'] ?? '';
                            semesterController.text =
                                courseDetails['semester'] ?? '';
                            unitsController.text =
                                courseDetails['units']?.toString() ?? '';
                            meetingsController.text =
                                courseDetails['meeting'] ?? '';
                            // Check if the course has lab
                            String hasLab = courseDetails['hasLab'] ?? '';
                            // Disable the lab room dropdown if the course has no laboratory
                            if (hasLab == 'NO') {
                              selectedLabRoomId = null;
                            }
                          });
                        },
                      );
                    }
                  },
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: unitsController,
                  decoration: const InputDecoration(labelText: 'Units'),
                ),
                TextField(
                  controller: meetingsController,
                  decoration: const InputDecoration(labelText: 'Frequency'),
                ),
                const SizedBox(height: 10),
                // Row of buttons for days
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDayButton('M'),
                    _buildDayButton('T'),
                    _buildDayButton('W'),
                    _buildDayButton('TTH'),
                    _buildDayButton('F'),
                    _buildDayButton('S'),
                    _buildDayButton('S'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: dbHelper.getClassrooms(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else {
                          List<DropdownMenuItem<String>> roomItems = [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Lecture Room'),
                            ),
                          ];
                          for (var room in snapshot.data!) {
                            if (room['type'] == 'Lecture Class') {
                              roomItems.add(
                                DropdownMenuItem(
                                  value: room['id'].toString(),
                                  child: Text(room['room']),
                                ),
                              );
                            }
                          }
                          return DropdownButton<String>(
                            value: selectedLecRoomId,
                            items: roomItems,
                            onChanged: (value) async {
                              setState(() {
                                selectedLecRoomId = value;
                              });
                            },
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 20),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: dbHelper.getClassrooms(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else {
                          List<DropdownMenuItem<String>> roomItems = [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Laboratory Room'),
                            ),
                          ];

                          for (var room in snapshot.data!) {
                            if (room['type'] == 'Laboratory Class') {
                              roomItems.add(
                                DropdownMenuItem(
                                  value: room['id'].toString(),
                                  child: Text(room['room']),
                                ),
                              );
                            }
                          }
                          return DropdownButton<String>(
                            value: selectedLabRoomId,
                            items: roomItems,
                            onChanged: (value) async {
                              setState(() {
                                selectedLabRoomId = value;
                              });
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Start Time: '),
                    DropdownButton<String>(
                      value: selectedStartTime,
                      onChanged: (value) {
                        setState(() {
                          selectedStartTime = value;
                        });
                      },
                      items: timeSlots.map((String time) {
                        return DropdownMenuItem<String>(
                          value: time,
                          child: Text(time),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 10),
                    const Text('-'),
                    const SizedBox(width: 10),
                    const Text('End Time: '),
                    DropdownButton<String>(
                      value: selectedEndTime,
                      onChanged: (value) {
                        setState(() {
                          selectedEndTime = value;
                        });
                      },
                      items: timeSlots.map((String time) {
                        return DropdownMenuItem<String>(
                          value: time,
                          child: Text(time),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Add"),
              onPressed: () async {
                //implement adding
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDayButton(String day) {
    return SizedBox(
      width: 60,
      child: TextButton(
        onPressed: () {
          setState(() {
            if (selectedDays.contains(day)) {
              selectedDays.remove(day);
            } else {
              selectedDays.add(day);
            }
          });
        },
        style: ButtonStyle(
          backgroundColor: selectedDays.contains(day)
              ? MaterialStateProperty.all(Colors.blue)
              : null,
          foregroundColor: selectedDays.contains(day)
              ? MaterialStateProperty.all(Colors.white)
              : null,
        ),
        child: Text(day),
      ),
    );
  }
}
