import 'package:flutter/material.dart';
import 'package:timetronix/db/db_helper.dart';

class EditSchedule extends StatefulWidget {
  const EditSchedule({super.key});

  @override
  _EditScheduleState createState() => _EditScheduleState();
}

class _EditScheduleState extends State<EditSchedule> {
  final dbHelper = DatabaseHelper();

  String? selectedFacultyId;
  String? selectedCourseId;
  String? selectedRoomId;

  int units = 0;
  String? position;
  int priorityNumber = 0;
  String? roomType;

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
        child: Text('Edit Schedule Page'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddItemDialog(context);
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue[800],
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
    TextEditingController roomTypeController =
        TextEditingController(text: roomType);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Assign Faculty"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Faculty:'),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: dbHelper.getFaculty(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else {
                      List<DropdownMenuItem<String>> facultyItems = [];
                      for (var faculty in snapshot.data!) {
                        facultyItems.add(
                          DropdownMenuItem(
                            child: Text(faculty['firstname'] +
                                ' ' +
                                faculty['lastname']),
                            value: faculty['id'].toString(),
                          ),
                        );
                      }
                      return DropdownButton<String>(
                        value: selectedFacultyId,
                        items: facultyItems,
                        onChanged: (value) async {
                          setState(() {
                            selectedFacultyId = value;
                          });
                          // Fetch faculty details based on selectedFacultyId
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
                const SizedBox(height: 10),
                TextField(
                  controller: positionController,
                  decoration: const InputDecoration(labelText: 'Position'),
                ),
                TextField(
                  controller: priorityController,
                  decoration:
                      const InputDecoration(labelText: 'Priority Number'),
                ),
                const SizedBox(height: 10),
                const Text('Select Course:'),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: dbHelper.getCurriculum(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else {
                      List<DropdownMenuItem<String>> courseItems = [];
                      for (var course in snapshot.data!) {
                        courseItems.add(
                          DropdownMenuItem(
                            child: Text(course['course']),
                            value: course['id'].toString(),
                          ),
                        );
                      }
                      return DropdownButton<String>(
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
                            // Populate other fields for course if needed
                            descriptionController.text =
                                courseDetails['description'] ?? '';
                            yearController.text = courseDetails['year'] ?? '';
                            semesterController.text =
                                courseDetails['semester'] ?? '';
                            unitsController.text =
                                courseDetails['units']?.toString() ?? '';
                            meetingsController.text =
                                courseDetails['meeting'] ?? '';
                          });
                        },
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: yearController,
                  decoration: const InputDecoration(labelText: 'Year'),
                ),
                TextField(
                  controller: semesterController,
                  decoration: const InputDecoration(labelText: 'Semester'),
                ),
                TextField(
                  controller: unitsController,
                  decoration: const InputDecoration(labelText: 'Units'),
                ),
                TextField(
                  controller: meetingsController,
                  decoration: const InputDecoration(labelText: 'Meetings'),
                ),
                const SizedBox(height: 10),
                const Text('Select Room:'),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: dbHelper.getClassrooms(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else {
                      List<DropdownMenuItem<String>> roomItems = [];
                      for (var room in snapshot.data!) {
                        roomItems.add(
                          DropdownMenuItem(
                            child: Text(room['room']),
                            value: room['id'].toString(),
                          ),
                        );
                      }
                      return DropdownButton<String>(
                        value: selectedRoomId,
                        items: roomItems,
                        onChanged: (value) async {
                          setState(() {
                            selectedRoomId = value;
                          });
                          // Fetch room details based on selectedRoomId
                          Map<String, dynamic> roomDetails =
                              await dbHelper.getRoomDetails(selectedRoomId);
                          setState(() {
                            roomTypeController.text = roomDetails['type'] ?? '';
                          });
                        },
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: roomTypeController,
                  decoration: const InputDecoration(labelText: 'Room Type'),
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
                // Add item to database
                await dbHelper.addFaculty(
                  "Firstname",
                  "Lastname",
                  positionController.text,
                  int.parse(priorityController.text),
                );
                await dbHelper.addCurriculum(
                  "Course",
                  descriptionController.text,
                  yearController.text,
                  semesterController.text,
                  int.parse(unitsController.text),
                  meetingsController.text,
                );
                await dbHelper.addClassroom(
                  "Room",
                  roomTypeController.text,
                );

                // Dismiss dialog
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
