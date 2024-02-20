import 'dart:io';

import 'package:flutter/material.dart';
import 'package:timetronix/components/custom_curriculum_dialog.dart';
import 'package:timetronix/db/db_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

class AddCurriculum extends StatefulWidget {
  const AddCurriculum({super.key});

  @override
  _AddCurriculumState createState() => _AddCurriculumState();
}

class _AddCurriculumState extends State<AddCurriculum> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> curriculums = [];
  String selectedyear = 'Lecture Class'; // Default value
  String selected = 'Lecture Class'; // Default value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
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
                  child: const Text('Add Curriculum'),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _pickExcelFile,
                  child: const Text('Import Curriculum'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
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
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showEditCurriculumDialog(curriculums[index]);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
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

  void _showCustomDialog(
      String title,
      String course,
      String description,
      String selectedYear,
      String selectedSemester,
      int units,
      String meeting,
      Function(String, String, String, String, int, String) onSubmit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomCurriculumDialog(
          title: title,
          course: course,
          description: description,
          yearDropdownItems: const [
            '1st Year',
            '2nd Year',
            '3rd Year',
            '4th Year'
          ],
          semesterDropdownItems: const [
            '1st Semester',
            '2nd Semester',
            '3rd Semester',
            '4th Semester',
            'Summer',
          ],
          selectedYearDropdownItem: selectedYear,
          selectedSemesterDropdownItem: selectedSemester,
          units: units,
          meeting: meeting,
          onSubmit: onSubmit,
        );
      },
    );
  }

  void _showAddCurriculumDialog() {
    _showCustomDialog(
        'Add Curriculum', '', '', '1st Year', '1st Semester', 0, '',
        (course, description, selectedYear, selectedSemester, units, meeting) {
      addCurriculum(
          course, description, selectedYear, selectedSemester, units, meeting);
    });
  }

  void _showEditCurriculumDialog(Map<String, dynamic> curriculum) {
    _showCustomDialog(
        'Edit Curriculum',
        curriculum['course'],
        curriculum['description'],
        curriculum['year'],
        curriculum['semester'],
        curriculum['units'],
        curriculum['meeting'],
        (course, description, selectedYear, selectedSemester, units, meeting) {
      updateCurriculum(
        curriculum['id'],
        course,
        description,
        selectedYear,
        selectedSemester,
        units,
        meeting,
      );
    });
  }

  // void _showAddCurriculumDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Add Curriculum'),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             children: [
  //               TextField(
  //                 controller: _courseController,
  //                 decoration: const InputDecoration(labelText: 'Course'),
  //               ),
  //               TextField(
  //                 controller: _descriptionController,
  //                 decoration: const InputDecoration(labelText: 'Description'),
  //               ),
  //               DropdownButtonFormField<String>(
  //                 value: _selectedYear,
  //                 items: [
  //                   '1st Year',
  //                   '2nd Year',
  //                   '3rd Year',
  //                   '4th Year',
  //                 ].map((String year) {
  //                   return DropdownMenuItem<String>(
  //                     value: year,
  //                     child: Text(year),
  //                   );
  //                 }).toList(),
  //                 onChanged: (String? value) {
  //                   setState(() {
  //                     _selectedYear = value!;
  //                   });
  //                 },
  //                 decoration: const InputDecoration(labelText: 'Year'),
  //               ),
  //               DropdownButtonFormField<String>(
  //                 value: _selectedSemester,
  //                 items: [
  //                   '1st Semester',
  //                   '2nd Semester',
  //                   '3rd Semester',
  //                   '4th Semester',
  //                   'Summer',
  //                 ].map((String semester) {
  //                   return DropdownMenuItem<String>(
  //                     value: semester,
  //                     child: Text(semester),
  //                   );
  //                 }).toList(),
  //                 onChanged: (String? value) {
  //                   setState(() {
  //                     _selectedSemester = value!;
  //                   });
  //                 },
  //                 decoration: const InputDecoration(labelText: 'Semester'),
  //               ),
  //               TextField(
  //                 controller: _unitsController,
  //                 decoration: const InputDecoration(labelText: 'Units'),
  //               ),
  //               TextField(
  //                 controller: _meetingController,
  //                 decoration: const InputDecoration(labelText: 'Meeting'),
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               addCurriculum(
  //                 _courseController.text,
  //                 _descriptionController.text,
  //                 _selectedYear,
  //                 _selectedSemester,
  //                 int.tryParse(_unitsController.text) ?? 0,
  //                 _meetingController.text,
  //               );
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Add'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void _showEditCurriculumDialog(Map<String, dynamic> curriculum) {
  //   _courseController.text = curriculum['course'];
  //   _descriptionController.text = curriculum['description'];
  //   _selectedYear = curriculum['year'];
  //   _selectedSemester = curriculum['semester'];
  //   _unitsController.text = curriculum['units'].toString();
  //   _meetingController.text = curriculum['meeting'];

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Edit Curriculum'),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             children: [
  //               TextField(
  //                 controller: _courseController,
  //                 decoration: const InputDecoration(labelText: 'Course'),
  //               ),
  //               TextField(
  //                 controller: _descriptionController,
  //                 decoration: const InputDecoration(labelText: 'Description'),
  //               ),
  //               DropdownButtonFormField<String>(
  //                 value: _selectedYear,
  //                 items: [
  //                   '1st Year',
  //                   '2nd Year',
  //                   '3rd Year',
  //                   '4th Year',
  //                 ].map((String year) {
  //                   return DropdownMenuItem<String>(
  //                     value: year,
  //                     child: Text(year),
  //                   );
  //                 }).toList(),
  //                 onChanged: (String? value) {
  //                   setState(() {
  //                     _selectedYear = value!;
  //                   });
  //                 },
  //                 decoration: const InputDecoration(labelText: 'Year'),
  //               ),
  //               DropdownButtonFormField<String>(
  //                 value: _selectedSemester,
  //                 items: [
  //                   '1st Semester',
  //                   '2nd Semester',
  //                   '3rd Semester',
  //                   '4th Semester',
  //                   'Summer',
  //                 ].map((String semester) {
  //                   return DropdownMenuItem<String>(
  //                     value: semester,
  //                     child: Text(semester),
  //                   );
  //                 }).toList(),
  //                 onChanged: (String? value) {
  //                   setState(() {
  //                     _selectedSemester = value!;
  //                   });
  //                 },
  //                 decoration: const InputDecoration(labelText: 'Semester'),
  //               ),
  //               TextField(
  //                 controller: _unitsController,
  //                 decoration: const InputDecoration(labelText: 'Units'),
  //               ),
  //               TextField(
  //                 controller: _meetingController,
  //                 decoration: const InputDecoration(labelText: 'Meeting'),
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               updateCurriculum(
  //                 curriculum['id'],
  //                 _courseController.text,
  //                 _descriptionController.text,
  //                 _selectedYear,
  //                 _selectedSemester,
  //                 int.tryParse(_unitsController.text) ?? 0,
  //                 _meetingController.text,
  //               );
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Save'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void addCurriculum(String course, String description, String year,
      String semester, int units, String meeting) async {
    await dbHelper.addCurriculum(
        course, description, year, semester, units, meeting);
    // Reload curriculum after adding
    loadCurriculums();
  }

  void removeCurriculum(int id) async {
    await dbHelper.removeCurriculum(id);
    // Reload curriculum after removing
    loadCurriculums();
  }

  void updateCurriculum(int id, String course, String description, String year,
      String semester, int units, String meeting) async {
    await dbHelper.editCurriculum(
        id, course, description, year, semester, units, meeting);
    // Reload curriculum after updating
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
