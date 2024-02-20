import 'package:flutter/material.dart';

class CustomCurriculumDialog extends StatefulWidget {
  final String title;
  final String course;
  final String description;
  final List<String> yearDropdownItems;
  final List<String> semesterDropdownItems;
  final String selectedYearDropdownItem;
  final String selectedSemesterDropdownItem;
  final int units;
  final String meeting;
  final Function(String, String, String, String, int, String) onSubmit;

  const CustomCurriculumDialog({
    Key? key,
    required this.title,
    required this.course,
    required this.description,
    required this.yearDropdownItems,
    required this.semesterDropdownItems,
    required this.selectedYearDropdownItem,
    required this.selectedSemesterDropdownItem,
    required this.units,
    required this.meeting,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _CustomCurriculumDialogState createState() => _CustomCurriculumDialogState();
}

class _CustomCurriculumDialogState extends State<CustomCurriculumDialog> {
  late String _course;
  late String _description;
  late String _selectedYear;
  late String _selectedSemester;
  late int _units;
  late String _meeting;

  late TextEditingController _courseController;
  late TextEditingController _descriptionController;
  late TextEditingController _unitsController;
  late TextEditingController _meetingController;

  @override
  void initState() {
    super.initState();
    _course = widget.course;
    _description = widget.description;
    _selectedYear = widget.selectedYearDropdownItem;
    _selectedSemester = widget.selectedSemesterDropdownItem;
    _units = widget.units;
    _meeting = widget.meeting;

    _courseController = TextEditingController(text: _course);
    _descriptionController = TextEditingController(text: _description);
    _unitsController = TextEditingController(text: _units.toString());
    _meetingController = TextEditingController(text: _meeting);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _courseController,
              onChanged: (value) {
                setState(() {
                  _course = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Course'),
            ),
            TextField(
              controller: _descriptionController,
              onChanged: (value) {
                setState(() {
                  _description = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            DropdownButton<String>(
              value: _selectedYear,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedYear = newValue!;
                });
              },
              borderRadius: BorderRadius.circular(15.0),
              alignment: Alignment.center,
              items: widget.yearDropdownItems
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Center(child: Text(value)),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: _selectedSemester,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSemester = newValue!;
                });
              },
              borderRadius: BorderRadius.circular(15.0),
              alignment: Alignment.center,
              items: widget.semesterDropdownItems
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Center(child: Text(value)),
                );
              }).toList(),
            ),
            TextField(
              controller: _unitsController,
              onChanged: (value) {
                setState(() {
                  _units = int.tryParse(value) ?? 0;
                });
              },
              decoration: const InputDecoration(labelText: 'Units'),
            ),
            TextField(
              controller: _meetingController,
              onChanged: (value) {
                setState(() {
                  _meeting = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Meeting'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSubmit(
              _course,
              _description,
              _selectedYear,
              _selectedSemester,
              _units,
              _meeting,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
