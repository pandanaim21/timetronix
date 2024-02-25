import 'dart:io';
import 'package:flutter/material.dart';
import 'package:timetronix/components/custom_faculty_dialog.dart';
import 'package:timetronix/db/db_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

class AddFaculty extends StatefulWidget {
  const AddFaculty({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddFacultyState createState() => _AddFacultyState();
}

class _AddFacultyState extends State<AddFaculty> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> faculties = [];
  String defaultPosition = 'Faculty';
  int defaultMinLoad = 0;
  int defaultMaxLoad = 0;
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
              child: faculties.isEmpty
                  ? const Center(
                      child: Text(
                        'Add Faculty',
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: faculties.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          color: Colors.blue[200],
                          child: ListTile(
                            title: Text(
                              'Faculty name: ${faculties[index]['lastname']}, ${faculties[index]['firstname']}',
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Position ${faculties[index]['position']}'),
                                Text(
                                    'Min Load: ${faculties[index]['min_load']}'),
                                Text(
                                    'Max Load: ${faculties[index]['max_load']}'),
                                Text(
                                  'Priority Number: ${faculties[index]['priority_number']}',
                                ),
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
    var sheet = excel.tables.keys.first;
    // Skip, first row is header
    for (var row in excel.tables[sheet]!.rows.skip(1)) {
      String firstName = row[0]?.value?.toString() ?? '';
      String lastName = row[1]?.value?.toString() ?? '';
      String position = row[2]?.value?.toString() ?? '';
      int minLoad = int.tryParse(row[3]?.value?.toString() ?? '') ?? 0;
      int maxLoad = int.tryParse(row[4]?.value?.toString() ?? '') ?? 0;
      int priorityNumber = int.tryParse(row[5]?.value?.toString() ?? '') ?? 0;
      await dbHelper.addFaculty(
        firstName,
        lastName,
        position,
        minLoad,
        maxLoad,
        priorityNumber,
      );
    }
    loadFaculties();
  }

  void _showCustomDialog(
      String title,
      String firstName,
      String lastName,
      String selectedPosition,
      int minimumLoad,
      int maximumLoad,
      int selectedPriorityNumber,
      Function(String, String, String, int, int, int) onSubmit) {
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
          minimumLoad: minimumLoad,
          maximumLoad: maximumLoad,
          priorityNumberDropdownItems: const [
            5,
            4,
            3,
            2,
            1,
          ],
          selectedPriorityNumberDropdownItem: selectedPriorityNumber,
          onSubmit: onSubmit,
        );
      },
    );
  }

  void _showAddFacultyDialog() {
    _showCustomDialog(
      'Add Faculty',
      '',
      '',
      defaultPosition,
      defaultMinLoad,
      defaultMaxLoad,
      defaultPriorityNumber,
      (firstName, lastName, selectedPosition, minLoad, maxLoad,
          selectedPriorityNumber) {
        addFaculty(
          firstName,
          lastName,
          selectedPosition,
          minLoad,
          maxLoad,
          selectedPriorityNumber,
        );
      },
    );
  }

  void _showEditFacultyDialog(Map<String, dynamic> faculty) {
    _showCustomDialog(
      'Edit Faculty',
      faculty['firstname'],
      faculty['lastname'],
      faculty['position'],
      faculty['min_load'],
      faculty['max_load'],
      faculty['priority_number'],
      (firstName, lastName, selectedPosition, minLoad, maxLoad,
          selectedPriorityNumber) {
        updateFaculty(
          faculty['id'],
          firstName,
          lastName,
          selectedPosition,
          minLoad,
          maxLoad,
          selectedPriorityNumber,
        );
      },
    );
  }

  void addFaculty(
    String firstName,
    String lastName,
    String position,
    int minLoad,
    int maxLoad,
    int priorityNumber,
  ) async {
    await dbHelper.addFaculty(
      firstName,
      lastName,
      position,
      minLoad,
      maxLoad,
      priorityNumber,
    );
    loadFaculties();
  }

  void updateFaculty(
    int id,
    String firstName,
    String lastName,
    String position,
    int minLoad,
    int maxLoad,
    int priorityNumber,
  ) async {
    await dbHelper.editFaculty(
      id,
      firstName,
      lastName,
      position,
      minLoad,
      maxLoad,
      priorityNumber,
    );
    loadFaculties();
  }

  void removeFaculty(int id) async {
    await dbHelper.removeFaculty(id);
    loadFaculties();
  }

  @override
  void initState() {
    super.initState();
    loadFaculties();
  }

  void loadFaculties() async {
    List<Map<String, dynamic>> facultyData = await dbHelper.getFaculty();
    setState(
      () {
        faculties = facultyData;
      },
    );
  }
}
