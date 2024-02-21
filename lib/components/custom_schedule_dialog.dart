import 'package:flutter/material.dart';
import 'package:timetronix/components/dictionary.dart';
import 'package:timetronix/db/db_helper.dart';

// ignore: must_be_immutable
class CustomScheduleDialog extends StatefulWidget {
  String? selectedFacultyId;
  String? selectedCourseId;
  String? selectedRoomId;
  final TextEditingController positionController;
  final TextEditingController priorityController;
  final TextEditingController descriptionController;
  final TextEditingController yearController;
  final TextEditingController semesterController;
  final TextEditingController unitsController;
  final TextEditingController meetingsController;
  final TextEditingController roomTypeController;

  // final String title;
  // final List<String> facultyDropdownItems;
  // final String selectedFacultyDropdownItem;
  // final String position;
  // final List<String> courseDropdownItems;
  // final String selectedCourseDropdownItem;
  // final String description;
  // final int units;
  // final String meeting;
  // final List<String> roomDropdownItems;
  // final String selectedRoomDropdownItem;
  // final Function(String, String, String, String, int, String, String) onSubmit;

  CustomScheduleDialog({
    Key? key,
    required this.selectedFacultyId,
    required this.selectedCourseId,
    required this.selectedRoomId,
    required this.positionController,
    required this.priorityController,
    required this.descriptionController,
    required this.yearController,
    required this.semesterController,
    required this.unitsController,
    required this.meetingsController,
    required this.roomTypeController,
  }) : super(key: key);

  @override
  _CustomScheduleDialogState createState() => _CustomScheduleDialogState();
}

class _CustomScheduleDialogState extends State<CustomScheduleDialog> {
  final dbHelper = DatabaseHelper();
  String? _selectedStartTime;
  String? _selectedEndTime;

  @override
  Widget build(BuildContext context) {
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
                        child: Text(
                            faculty['firstname'] + ' ' + faculty['lastname']),
                      ),
                    );
                  }
                  return DropdownButton<String>(
                    value: widget.selectedFacultyId,
                    items: facultyItems,
                    onChanged: (value) async {
                      setState(() {
                        widget.selectedFacultyId =
                            value; // This line will throw an error as selectedFacultyId is read-only
                      });
                      // Fetch faculty details based on selectedFacultyId
                      Map<String, dynamic> facultyDetails = await dbHelper
                          .getFacultyDetails(widget.selectedFacultyId);
                      setState(() {
                        widget.positionController.text =
                            facultyDetails['position'] ?? '';
                        widget.priorityController.text =
                            facultyDetails['priority_number']?.toString() ?? '';
                      });
                    },
                  );
                }
              },
            ),
            TextField(
              controller: widget.positionController,
              decoration: const InputDecoration(labelText: 'Position'),
            ),
            TextField(
              controller: widget.priorityController,
              decoration: const InputDecoration(labelText: 'Priority Number'),
            ),
            const SizedBox(height: 10),
            const Text('Select Course:'),
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
                    value: widget.selectedCourseId,
                    items: courseItems,
                    onChanged: (value) async {
                      setState(() {
                        widget.selectedCourseId = value;
                      });
                      // Fetch course details based on selectedCourseId
                      Map<String, dynamic> courseDetails = await dbHelper
                          .getCourseDetails(widget.selectedCourseId);
                      setState(() {
                        // Populate other fields for course if needed
                        widget.descriptionController.text =
                            courseDetails['description'] ?? '';
                        widget.yearController.text =
                            courseDetails['year'] ?? '';
                        widget.semesterController.text =
                            courseDetails['semester'] ?? '';
                        widget.unitsController.text =
                            courseDetails['units']?.toString() ?? '';
                        widget.meetingsController.text =
                            courseDetails['meeting'] ?? '';
                      });
                    },
                  );
                }
              },
            ),
            TextField(
              controller: widget.descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: widget.yearController,
              decoration: const InputDecoration(labelText: 'Year'),
            ),
            TextField(
              controller: widget.semesterController,
              decoration: const InputDecoration(labelText: 'Semester'),
            ),
            TextField(
              controller: widget.unitsController,
              decoration: const InputDecoration(labelText: 'Units'),
            ),
            TextField(
              controller: widget.meetingsController,
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
                  List<DropdownMenuItem<String>> roomItems = [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Select Room'),
                    ),
                  ];

                  for (var room in snapshot.data!) {
                    roomItems.add(
                      DropdownMenuItem(
                        value: room['id'].toString(),
                        child: Text(room['room']),
                      ),
                    );
                  }

                  return DropdownButton<String>(
                    value: widget.selectedRoomId,
                    items: roomItems,
                    onChanged: (value) async {
                      setState(() {
                        widget.selectedRoomId = value;
                      });
                      // Fetch room details based on selectedRoomId
                      Map<String, dynamic> roomDetails =
                          await dbHelper.getRoomDetails(widget.selectedRoomId);
                      setState(() {
                        widget.roomTypeController.text =
                            roomDetails['type'] ?? '';
                      });
                    },
                  );
                }
              },
            ),
            TextField(
              controller: widget.roomTypeController,
              decoration: const InputDecoration(labelText: 'Room Type'),
            ),
            const SizedBox(height: 30),
            // Start Time Dropdown
            Row(
              children: [
                const Text('Start Time: '),
                DropdownButton<String>(
                  value: _selectedStartTime,
                  onChanged: (value) {
                    setState(() {
                      _selectedStartTime = value;
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
            // End Time Dropdown
            Row(
              children: [
                const Text('End Time: '),
                DropdownButton<String>(
                  value: _selectedEndTime,
                  onChanged: (value) {
                    setState(() {
                      _selectedEndTime = value;
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
          onPressed: () {
            // Perform actions on Add button click
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
