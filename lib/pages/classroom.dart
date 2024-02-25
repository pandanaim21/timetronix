import 'dart:io';
import 'package:flutter/material.dart';
import 'package:timetronix/components/custom_classroom_dialog.dart';
import 'package:timetronix/db/db_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

class AddClassroom extends StatefulWidget {
  const AddClassroom({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddClassroomState createState() => _AddClassroomState();
}

// Wasim A. Macasayan
class _AddClassroomState extends State<AddClassroom> {
  final dbHelper = DatabaseHelper();
  //Select All
  List<Map<String, dynamic>> getClassroom = [];
  //Specific Room Type
  List<Map<String, dynamic>> getLectureRoom = [];
  List<Map<String, dynamic>> getlaboratoryRoom = [];
  String defaultSelectedType = 'Lecture Class';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
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
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _showAddDialog,
                    child: const Text('Add Room'),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: _pickExcelFile,
                    child: const Text('Import Classroom'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child: Text(
                            'Lecture Class',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        getLectureRoom.isEmpty
                            ? const Expanded(
                                child: Center(
                                  child: Text('Add Room'),
                                ),
                              )
                            : Expanded(
                                child: ListView.builder(
                                  itemCount: getLectureRoom.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Card(
                                      child: ListTile(
                                        title: Text(
                                            'Room ${getLectureRoom[index]['room']}'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () {
                                                _showEditDialog(
                                                    getLectureRoom[index]);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {
                                                removeClassroom(
                                                    getLectureRoom[index]
                                                        ['room']);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child: Text(
                            'Laboratory Class',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        getlaboratoryRoom.isEmpty
                            ? const Expanded(
                                child: Center(
                                  child: Text('Add Room'),
                                ),
                              )
                            : Expanded(
                                child: ListView.builder(
                                  itemCount: getlaboratoryRoom.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Card(
                                      child: ListTile(
                                        title: Text(
                                            'Room ${getlaboratoryRoom[index]['room']}'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () {
                                                _showEditDialog(
                                                    getlaboratoryRoom[index]);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {
                                                removeClassroom(
                                                    getlaboratoryRoom[index]
                                                        ['room']);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
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
      allowedExtensions: ['xlsx', 'xls'],
    );
    if (result != null) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        await _processExcelFile(filePath);
      }
    }
  }

  Future<void> _processExcelFile(String filePath) async {
    var bytes = File(filePath).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    var sheet = excel.tables.keys.first;
    // Skip, first row is header
    for (var row in excel.tables[sheet]!.rows.skip(1)) {
      String lecture = row[0]?.value?.toString() ?? '';
      String laboratory = row[1]?.value?.toString() ?? '';
      if (lecture.isNotEmpty) {
        await dbHelper.addClassroom(lecture, 'Lecture Class');
      }
      if (laboratory.isNotEmpty) {
        await dbHelper.addClassroom(laboratory, 'Laboratory Class');
      }
    }
    loadClassrooms();
  }

  void _showCustomDialog(String title, String room, String selectedType,
      Function(String, String) onSubmit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomClassroomDialog(
          title: title,
          hintText: 'Enter Classroom',
          room: room,
          dropdownItems: const ['Lecture Class', 'Laboratory Class'],
          selectedDropdownItem: selectedType,
          onSubmit: onSubmit,
        );
      },
    );
  }

  void _showAddDialog() {
    _showCustomDialog(
      'Add Room',
      '',
      defaultSelectedType,
      addClassroom,
    );
  }

  void _showEditDialog(Map<String, dynamic> classroom) {
    _showCustomDialog(
      'Edit Room',
      classroom['room'],
      classroom['type'],
      (room, type) {
        updateClassroom(
          classroom['id'],
          room,
          type,
        );
      },
    );
  }

  void addClassroom(String room, String type) async {
    if (room.isNotEmpty) {
      await dbHelper.addClassroom(room, type);
      loadClassrooms();
    }
  }

  void removeClassroom(String room) async {
    await dbHelper.removeClassroom(room);
    loadClassrooms();
  }

  void updateClassroom(int id, String newRoom, String newType) async {
    if (newRoom.isNotEmpty) {
      await dbHelper.editClassroom(id, newRoom, newType);
      loadClassrooms();
    }
  }

  @override
  void initState() {
    super.initState();
    loadClassrooms();
  }

  void loadClassrooms() async {
    List<Map<String, dynamic>> classrooms = await dbHelper.getClassrooms();
    List<Map<String, dynamic>> lectureRooms = await dbHelper.getLectureRooms();
    List<Map<String, dynamic>> laboratoryRooms =
        await dbHelper.getLaboratoryRooms();
    setState(() {
      getClassroom = classrooms;
      getLectureRoom = lectureRooms;
      getlaboratoryRoom = laboratoryRooms;
    });
  }
}
