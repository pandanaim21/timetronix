import 'dart:io';
import 'package:flutter/material.dart';
import 'package:timetronix/components/custom_curriculum_dialog.dart';
import 'package:timetronix/db/db_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

class AddCurriculum extends StatefulWidget {
  const AddCurriculum({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddCurriculumState createState() => _AddCurriculumState();
}

class _AddCurriculumState extends State<AddCurriculum> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> getCurriculum = [];
  List<Map<String, dynamic>> getFirstSemester = [];
  List<Map<String, dynamic>> getSecondSemester = [];
  String defaultSelectedYear = '1st';
  String defaultSelectedSemester = '1st semester';
  String defaultSelectedHasLab = 'NO';

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
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _showAddCurriculumDialog,
                    child: const Text('Add Course'),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: _pickExcelFile,
                    child: const Text('Import Curriculum'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: getCurriculum.isEmpty
                  ? const Center(
                      child: Text(
                        'Add Course',
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: getCurriculum.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: ListTile(
                            title: Text(
                                'Course Code: ${getCurriculum[index]['course']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Course Description: ${getCurriculum[index]['description']}',
                                ),
                                Text('Year: ${getCurriculum[index]['year']}'),
                                Text(
                                    'Semester: ${getCurriculum[index]['semester']}'),
                                Text('Units: ${getCurriculum[index]['units']}'),
                                Text(
                                    'Frequency: ${getCurriculum[index]['meeting']}'),
                                Text(
                                  'Laboratory Class: ${getCurriculum[index]['hasLab']}',
                                )
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditCurriculumDialog(
                                        getCurriculum[index]);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    removeCurriculum(
                                        getCurriculum[index]['id']);
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

  void _showCustomDialog(
      String title,
      String course,
      String description,
      String selectedYear,
      String selectedSemester,
      int units,
      String meeting,
      String selectedHasLab,
      Function(String, String, String, String, int, String, String) onSubmit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomCurriculumDialog(
          title: title,
          course: course,
          description: description,
          yearDropdownItems: const [
            '1st',
            '2nd',
            '3rd',
            '4th',
          ],
          semesterDropdownItems: const [
            '1st semester',
            '2nd semester',
            'Summer',
          ],
          hasLabDropdownItems: const [
            'NO',
            'YES',
          ],
          selectedYearDropdownItem: selectedYear,
          selectedSemesterDropdownItem: selectedSemester,
          units: units,
          meeting: meeting,
          onSubmit: onSubmit,
          selectedHasLabDropdownItem: selectedHasLab,
        );
      },
    );
  }

  void _showAddCurriculumDialog() {
    _showCustomDialog(
      'Add Course',
      '',
      '',
      defaultSelectedYear,
      defaultSelectedSemester,
      0,
      '',
      defaultSelectedHasLab,
      (course, description, selectedYear, selectedSemester, units, meeting,
          selectedHasLab) {
        addCurriculum(
          course,
          description,
          selectedYear,
          selectedSemester,
          units,
          meeting,
          selectedHasLab,
        );
      },
    );
  }

  void _showEditCurriculumDialog(Map<String, dynamic> curriculum) {
    _showCustomDialog(
      'Edit Course',
      curriculum['course'],
      curriculum['description'],
      curriculum['year'],
      curriculum['semester'],
      curriculum['units'],
      curriculum['meeting'],
      curriculum['hasLab'],
      (course, description, selectedYear, selectedSemester, units, meeting,
          hasLab) {
        updateCurriculum(
          curriculum['id'],
          course,
          description,
          selectedYear,
          selectedSemester,
          units,
          meeting,
          hasLab,
        );
      },
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
    // Skip, first and second row is header
    for (var row in excel.tables[sheet]!.rows.skip(2)) {
      String course = row[0]?.value?.toString() ?? '';
      String description = row[1]?.value?.toString() ?? '';
      String year = row[2]?.value?.toString() ?? '';
      String semester = row[3]?.value?.toString() ?? '';
      int units = int.tryParse(row[4]?.value?.toString() ?? '') ?? 0;
      int labUnits = int.tryParse(row[6]?.value?.toString() ?? '') ?? 0;
      String hasLab = labUnits > 0 ? 'YES' : 'NO';
      String meeting = row[8]?.value?.toString() ?? '';
      await dbHelper.addCurriculum(
          course, description, year, semester, units, meeting, hasLab);
    }
    loadCurriculums();
  }

  void addCurriculum(String course, String description, String year,
      String semester, int units, String meeting, String hasLab) async {
    await dbHelper.addCurriculum(
        course, description, year, semester, units, meeting, hasLab);
    loadCurriculums();
  }

  void removeCurriculum(int id) async {
    await dbHelper.removeCurriculum(id);
    loadCurriculums();
  }

  void updateCurriculum(int id, String course, String description, String year,
      String semester, int units, String meeting, String hasLab) async {
    await dbHelper.editCurriculum(
        id, course, description, year, semester, units, meeting, hasLab);
    loadCurriculums();
  }

  @override
  void initState() {
    super.initState();
    loadCurriculums();
  }

  void loadCurriculums() async {
    List<Map<String, dynamic>> curriculums = await dbHelper.getCurriculum();
    setState(
      () {
        getCurriculum = curriculums;
      },
    );
  }
}
