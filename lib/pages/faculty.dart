import 'dart:io';
import 'package:flutter/material.dart';
import 'package:timetronix/components/custom_faculty_dialog.dart';
import 'package:timetronix/db/db_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

class AddFaculty extends StatefulWidget {
  const AddFaculty({Key? key}) : super(key: key);

  @override
  _AddFacultyState createState() => _AddFacultyState();
}

class _AddFacultyState extends State<AddFaculty> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> faculties = [];
  String defaultPosition = 'Faculty';
  int defaultPriorityNumber = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Faculty',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: _showAddFacultyDialog,
                    child: const Text('Add Faculty'),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: _pickExcelFile,
                    child: const Text('Import Faculty'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: faculties.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('First Name: ${faculties[index]['firstname']}'),
                          Text('Last Name: ${faculties[index]['lastname']}'),
                          Text('Position: ${faculties[index]['position']}'),
                          Text(
                              'Priority Number: ${faculties[index]['priority_number']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showEditFacultyDialog(faculties[index]);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              removeFaculty(faculties[index]['id']);
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

    // Skip, first row is header
    for (var row in excel.tables[sheet]!.rows.skip(1)) {
      String firstName = row[0]?.value?.toString() ?? '';
      String lastName = row[1]?.value?.toString() ?? '';
      String position = row[2]?.value?.toString() ?? '';
      int priorityNumber = int.tryParse(row[3]?.value?.toString() ?? '') ?? 1;

      await dbHelper.addFaculty(firstName, lastName, position, priorityNumber);
    }

    loadFaculties();
  }

  void _showCustomDialog(
      String title,
      String firstName,
      String lastName,
      String selectedPosition,
      int selectedPriorityNumber,
      Function(String, String, String, int) onSubmit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomFacultyDialog(
          title: title,
          firstName: firstName,
          lastName: lastName,
          positionDropdownItems: const [
            'Faculty',
            'Dean',
            'Assistant Dean',
            'Secretary',
            'Chairperson',
          ],
          selectedPositionDropdownItem: selectedPosition,
          priorityNumberDropdownItems: [1, 2, 3, 4, 5],
          selectedPriorityNumberDropdownItem: selectedPriorityNumber,
          onSubmit: onSubmit,
        );
      },
    );
  }

  void _showAddFacultyDialog() {
    _showCustomDialog(
        'Add Faculty', '', '', defaultPosition, defaultPriorityNumber,
        (firstName, lastName, selectedPosition, selectedPriorityNumber) {
      addFaculty(firstName, lastName, selectedPosition, selectedPriorityNumber);
    });
  }

  void _showEditFacultyDialog(Map<String, dynamic> faculty) {
    _showCustomDialog('Edit Faculty', faculty['firstname'], faculty['lastname'],
        faculty['position'], faculty['priority_number'],
        (firstName, lastName, selectedPosition, selectedPriorityNumber) {
      updateFaculty(
        faculty['id'],
        firstName,
        lastName,
        selectedPosition,
        selectedPriorityNumber,
      );
    });
  }

  void addFaculty(String firstName, String lastName, String position,
      int priorityNumber) async {
    await dbHelper.addFaculty(firstName, lastName, position, priorityNumber);
    // Reload faculty after adding
    loadFaculties();
  }

  void removeFaculty(int id) async {
    await dbHelper.removeFaculty(id);
    // Reload faculty after removing
    loadFaculties();
  }

  void updateFaculty(int id, String firstName, String lastName, String position,
      int priorityNumber) async {
    await dbHelper.editFaculty(
        id, firstName, lastName, position, priorityNumber);
    // Reload faculty after updating
    loadFaculties();
  }

  @override
  void initState() {
    super.initState();
    loadFaculties();
  }

  void loadFaculties() async {
    List<Map<String, dynamic>> facultyData = await dbHelper.getFaculty();
    setState(() {
      faculties = facultyData;
    });
  }
}
