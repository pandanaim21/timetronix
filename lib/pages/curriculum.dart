import 'dart:io';

import 'package:flutter/material.dart';
import 'package:timetronix/components/custom_dialog.dart';
import 'package:timetronix/db/db_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

class AddCurriculum extends StatefulWidget {
  @override
  _AddCurriculumState createState() => _AddCurriculumState();
}

class _AddCurriculumState extends State<AddCurriculum> {
  final dbHelper = DatabaseHelper();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();
  final TextEditingController _unitsController = TextEditingController();
  final TextEditingController _meetingController = TextEditingController();

  List<Map<String, dynamic>> curriculums = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Curriculum',
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
                  onPressed: _showAddCurriculumDialog,
                  child: Text('Add Curriculum'),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _pickExcelFile,
                  child: Text('Import Curriculum'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: curriculums.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Course: ${curriculums[index]['course']}'),
                          Text(
                              'Description: ${curriculums[index]['description']}'),
                          Text('Year: ${curriculums[index]['year']}'),
                          Text('Semester: ${curriculums[index]['semester']}'),
                          Text('Units: ${curriculums[index]['units']}'),
                          Text('Meeting: ${curriculums[index]['meeting']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _showEditCurriculumDialog(curriculums[index]);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              removeCurriculum(curriculums[index]['id']);
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

    // Get the first worksheet
    var sheet = excel.tables.keys.first;

    // Skip, first and second row is header
    for (var row in excel.tables[sheet]!.rows.skip(2)) {
      String course = row[0]?.value?.toString() ?? '';
      String description = row[1]?.value?.toString() ?? '';
      String year = row[2]?.value?.toString() ?? '';
      String semester = row[3]?.value?.toString() ?? '';
      int units = int.tryParse(row[4]?.value?.toString() ?? '') ?? 0;
      String meeting = row[8]?.value?.toString() ?? '';

      await dbHelper.addCurriculum(
          course, description, year, semester, units, meeting);
    }

    loadCurriculums();
  }

  void _showAddCurriculumDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Curriculum'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _courseController,
                  decoration: InputDecoration(labelText: 'Course'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: _yearController,
                  decoration: InputDecoration(labelText: 'Year'),
                ),
                TextField(
                  controller: _semesterController,
                  decoration: InputDecoration(labelText: 'Semester'),
                ),
                TextField(
                  controller: _unitsController,
                  decoration: InputDecoration(labelText: 'Units'),
                ),
                TextField(
                  controller: _meetingController,
                  decoration: InputDecoration(labelText: 'Meeting'),
                ),
              ],
            ),
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
                addCurriculum(
                  _courseController.text,
                  _descriptionController.text,
                  _yearController.text,
                  _semesterController.text,
                  int.tryParse(_unitsController.text) ?? 0,
                  _meetingController.text,
                );
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCurriculumDialog(Map<String, dynamic> curriculum) {
    _courseController.text = curriculum['course'];
    _descriptionController.text = curriculum['description'];
    _yearController.text = curriculum['year'];
    _semesterController.text = curriculum['semester'];
    _unitsController.text = curriculum['units'].toString();
    _meetingController.text = curriculum['meeting'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Curriculum'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _courseController,
                  decoration: InputDecoration(labelText: 'Course'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: _yearController,
                  decoration: InputDecoration(labelText: 'Year'),
                ),
                TextField(
                  controller: _semesterController,
                  decoration: InputDecoration(labelText: 'Semester'),
                ),
                TextField(
                  controller: _unitsController,
                  decoration: InputDecoration(labelText: 'Units'),
                ),
                TextField(
                  controller: _meetingController,
                  decoration: InputDecoration(labelText: 'Meeting'),
                ),
              ],
            ),
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
                updateCurriculum(
                  curriculum['id'],
                  _courseController.text,
                  _descriptionController.text,
                  _yearController.text,
                  _semesterController.text,
                  int.tryParse(_unitsController.text) ?? 0,
                  _meetingController.text,
                );
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void addCurriculum(String course, String description, String year,
      String semester, int units, String meeting) async {
    await dbHelper.addCurriculum(
        course, description, year, semester, units, meeting);
    loadCurriculums();
  }

  void removeCurriculum(int id) async {
    await dbHelper.removeCurriculum(id);
    loadCurriculums();
  }

  void updateCurriculum(int id, String course, String description, String year,
      String semester, int units, String meeting) async {
    await dbHelper.editCurriculum(
        id, course, description, year, semester, units, meeting);
    loadCurriculums();
  }

  @override
  void initState() {
    super.initState();
    loadCurriculums();
  }

  void loadCurriculums() async {
    List<Map<String, dynamic>> curriculumData = await dbHelper.getCurriculum();
    setState(() {
      curriculums = curriculumData;
    });
  }
}
