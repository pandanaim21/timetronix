import 'dart:io';

import 'package:flutter/material.dart';
import 'package:timetronix/db/db_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

class AddClassroom extends StatefulWidget {
  @override
  _AddClassroomState createState() => _AddClassroomState();
}

class _AddClassroomState extends State<AddClassroom> {
  final dbHelper = DatabaseHelper();
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> classrooms = [];
  String selectedClassType = 'Lecture Class'; // Default value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Classroom',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: _showImportDialog,
                  child: Text('Add Classroom'),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _pickExcelFile,
                  child: Text('Import Excel'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: classrooms.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      title: Text('${classrooms[index]['room']}'),
                      subtitle: Text('${classrooms[index]['type']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          removeClassroom(classrooms[index]['room']);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'], // Allow only Excel file types
    );

    if (result != null) {
      // Extract the file path from the result
      String? filePath = result.files.single.path;

      // Process the selected Excel file
      if (filePath != null) {
        await _processExcelFile(filePath);
      }
    }
  }

  Future<void> _processExcelFile(String filePath) async {
    // Open the Excel file
    var bytes = File(filePath).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    // Get the first worksheet
    var sheet = excel.tables.keys.first;

    // Assuming first row is header, so start iterating from the second row
    for (var row in excel.tables[sheet]!.rows.skip(1)) {
      // Assuming first column is for lecture and second column is for laboratory
      String lecture = row[0]?.value?.toString() ?? '';
      String laboratory = row[1]?.value?.toString() ?? '';

      // Insert into database
      if (lecture.isNotEmpty) {
        await dbHelper.addClassroom(lecture, 'Lecture Class');
      }
      if (laboratory.isNotEmpty) {
        await dbHelper.addClassroom(laboratory, 'Laboratory Class');
      }
    }

    // Reload classrooms after adding
    loadClassrooms();
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Classroom Type'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedClassType,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedClassType = newValue!;
                      });
                    },
                    items: <String>['Lecture Class', 'Laboratory Class']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter Classroom Number or Name',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    addClassroom(_controller.text, selectedClassType);
                    Navigator.of(context).pop();
                  },
                  child: Text('Add Classroom'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void addClassroom(String room, String type) async {
    if (room.isNotEmpty) {
      await dbHelper.addClassroom(room, type);
      loadClassrooms(); // Reload classrooms after adding
      _controller.clear();
    }
  }

  void removeClassroom(String room) async {
    await dbHelper.removeClassroom(room);
    loadClassrooms(); // Reload classrooms after removing
  }

  @override
  void initState() {
    super.initState();
    loadClassrooms();
  }

  void loadClassrooms() async {
    List<Map<String, dynamic>> classroomData = await dbHelper.getClassrooms();
    setState(() {
      classrooms = classroomData;
    });
  }
}
