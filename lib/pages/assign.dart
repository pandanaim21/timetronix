import 'package:flutter/material.dart';
import 'package:timetronix/components/custom_assign_dialog.dart';
import 'package:timetronix/components/custom_course_dialog.dart';
import 'package:timetronix/components/format_time.dart';
import 'package:timetronix/db/db_helper.dart';

class AddAssigns extends StatefulWidget {
  const AddAssigns({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddAssignsState createState() => _AddAssignsState();
}

class _AddAssignsState extends State<AddAssigns> {
  final dbHelper = DatabaseHelper();

  String? _selectedFaculty;
  String? _selectedCourse;
  String? _selectedRoom;

  final Set<String> _selectedDays = {};
  String? _selectedStartTime;
  String? _selectedEndTime;

  List<DropdownMenuItem<String>> _facultyDropdownItems = [];
  List<Map<String, dynamic>> _courseDropdownItems = [];
  List<DropdownMenuItem<String>> _lectureRoomDropdownItems = [];
  List<DropdownMenuItem<String>> _laboratoryRoomDropdownItems = [];
  List<Map<String, dynamic>> assigns = [];

  final List<String> _days = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<Map<String, dynamic>> assignData = await dbHelper.getAssign();
    final faculties = await dbHelper.getFaculty();
    final courses = await dbHelper.getCurriculum();
    final lecRooms = await dbHelper.getLectureRooms();
    final labRooms = await dbHelper.getLaboratoryRooms();

    setState(
      () {
        _facultyDropdownItems =
            faculties.map<DropdownMenuItem<String>>((faculty) {
          return DropdownMenuItem<String>(
            value: faculty['id'].toString(),
            child: Text(faculty['firstname'] + ' ' + faculty['lastname']),
          );
        }).toList();

        _courseDropdownItems = courses.map<Map<String, dynamic>>((course) {
          return {
            'id': course['id'].toString(),
            'course': course['course'],
            'hasLab': course['hasLab'],
          };
        }).toList();

        _lectureRoomDropdownItems =
            lecRooms.map<DropdownMenuItem<String>>((lecRoom) {
          return DropdownMenuItem<String>(
            value: lecRoom['id'].toString(),
            child: Text(lecRoom['room']),
          );
        }).toList();

        _laboratoryRoomDropdownItems =
            labRooms.map<DropdownMenuItem<String>>((labRoom) {
          return DropdownMenuItem<String>(
            value: labRoom['id'].toString(),
            child: Text(labRoom['room']),
          );
        }).toList();

        assigns = assignData;
      },
    );
  }

  String _formatTime(int hour, int minute) {
    return formatTime(hour, minute);
  }

  _showClassDialog(
      String className, List<DropdownMenuItem<String>> roomDropdownItems) {
    showCustomClassDialog(
      context,
      className,
      roomDropdownItems,
      _selectedDays,
      _selectedRoom,
      _selectedStartTime,
      _selectedEndTime,
      _days,
      (String? value) {
        _selectedRoom = value;
      },
      (String day) {
        if (_selectedDays.contains(day)) {
          _selectedDays.remove(day);
        } else {
          _selectedDays.add(day);
        }
      },
      (int hour, int minute) {
        _selectedStartTime = _formatTime(hour, minute);
      },
      (int hour, int minute) {
        _selectedEndTime = _formatTime(hour, minute);
      },
      _resetVariables,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Faculty'),
        backgroundColor: Colors.blue[800],
      ),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCustomAssignDialog(
            context,
            _facultyDropdownItems,
            _courseDropdownItems,
            (String? value) {
              _selectedFaculty = value;
            },
            (String? value) {
              _selectedCourse = value;
            },
            () {
              _showClassDialog('Lecture Class', _lectureRoomDropdownItems);
            },
            () {
              _showClassDialog(
                  'Laboratory Class', _laboratoryRoomDropdownItems);
            },
            () {
              addAssign();
            },
            _resetVariables,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _resetVariables() {
    setState(() {
      _selectedRoom = null;
      _selectedDays.clear();
      _selectedStartTime = null;
      _selectedEndTime = null;
    });
  }

  void addAssign() async {
    await dbHelper.addAssign(
      int.parse(_selectedFaculty!),
      int.parse(_selectedCourse!),
      int.parse(_selectedRoom!),
      _selectedDays.join(', '),
      _selectedStartTime!,
      _selectedEndTime!,
    );
    _loadData();
  }

  void removeAssign(int id) async {
    await dbHelper.removeAssign(id);
    _loadData();
  }
}
