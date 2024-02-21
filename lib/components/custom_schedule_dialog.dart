import 'package:flutter/material.dart';
import 'package:timetronix/components/dictionary.dart';
import 'package:timetronix/db/db_helper.dart';

class CustomScheduleDialog extends StatefulWidget {
  const CustomScheduleDialog({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CustomScheduleDialogState createState() => _CustomScheduleDialogState();
}

class _CustomScheduleDialogState extends State<CustomScheduleDialog> {
  final dbHelper = DatabaseHelper();

  String? selectedFacultyId;
  String? selectedCourseId;
  String? selectedLecRoomId;
  String? selectedLabRoomId;
  int units = 0;
  String? position;
  int priorityNumber = 0;
  String? selectedStartTime;
  String? selectedEndTime;

  late TextEditingController positionController;
  late TextEditingController priorityController;
  late TextEditingController descriptionController;
  late TextEditingController yearController;
  late TextEditingController semesterController;
  late TextEditingController unitsController;
  late TextEditingController meetingsController;

  @override
  void initState() {
    super.initState();
    positionController = TextEditingController(text: position ?? '');
    priorityController = TextEditingController(text: priorityNumber.toString());
    descriptionController = TextEditingController();
    yearController = TextEditingController();
    semesterController = TextEditingController();
    unitsController = TextEditingController(text: units.toString());
    meetingsController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
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
                        child: Text(
                            faculty['firstname'] + ' ' + faculty['lastname']),
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
                      Map<String, dynamic> facultyDetails =
                          await dbHelper.getFacultyDetails(selectedFacultyId);
                      setState(() {
                        positionController.text =
                            facultyDetails['position'] ?? '';
                        priorityController.text =
                            facultyDetails['priority_number']?.toString() ?? '';
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
            Row(
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: dbHelper.getClassrooms(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
  }
}
