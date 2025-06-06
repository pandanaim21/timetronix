import 'package:flutter/material.dart';
import 'package:timetronix/components/custom_textfield.dart';

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
  final List<String> hasLabDropdownItems;
  final String selectedHasLabDropdownItem;
  final Function(String, String, String, String, int, String, String) onSubmit;

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
    required this.hasLabDropdownItems,
    required this.selectedHasLabDropdownItem,
    required this.onSubmit,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CustomCurriculumDialogState createState() => _CustomCurriculumDialogState();
}

class _CustomCurriculumDialogState extends State<CustomCurriculumDialog> {
  late String _course;
  late String _description;
  late String _selectedYear;
  late String _selectedSemester;
  late int _units;
  late String _meeting;
  late String _selectedHasLab;

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
    _selectedHasLab = widget.selectedHasLabDropdownItem;

    _courseController = TextEditingController(text: _course);
    _descriptionController = TextEditingController(text: _description);
    _unitsController = TextEditingController(text: _units.toString());
    _meetingController = TextEditingController(text: _meeting);
  }

  @override
  Widget build(BuildContext context) {
    final isEditDialog = widget.title == 'Edit Course';
    return AlertDialog(
      title: Center(
          child: Text(
        isEditDialog ? widget.course : widget.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      )),
      content: SingleChildScrollView(
        child: Column(
          children: [
            if (!isEditDialog) ...[
              CustomTextField(
                borderColor: Colors.blue,
                hintText: 'Course Code',
                controller: _courseController,
                textAlign: TextAlign.left,
                symmetricPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                leftPadding: const EdgeInsets.only(left: 8.0),
                onChanged: (value) {
                  setState(() {
                    _course = value;
                  });
                },
              ),
              const SizedBox(height: 10),
            ],
            CustomTextField(
              borderColor: Colors.blue,
              hintText: 'Course Description',
              controller: _descriptionController,
              textAlign: TextAlign.left,
              symmetricPadding: const EdgeInsets.symmetric(horizontal: 0.0),
              leftPadding: const EdgeInsets.only(left: 8.0),
              onChanged: (value) {
                setState(() {
                  _description = value;
                });
              },
            ),
            const SizedBox(height: 10),
            CustomTextField(
              borderColor: Colors.blue,
              hintText: 'Units',
              controller: _unitsController,
              textAlign: TextAlign.left,
              symmetricPadding: const EdgeInsets.symmetric(horizontal: 0.0),
              leftPadding: const EdgeInsets.only(left: 8.0),
              onChanged: (value) {
                setState(() {
                  _units = int.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 10),
            CustomTextField(
              borderColor: Colors.blue,
              hintText: 'Frequency',
              controller: _meetingController,
              textAlign: TextAlign.left,
              symmetricPadding: const EdgeInsets.symmetric(horizontal: 0.0),
              leftPadding: const EdgeInsets.only(left: 8.0),
              onChanged: (value) {
                setState(() {
                  _meeting = value;
                });
              },
            ),
            const SizedBox(height: 20),
            PopupMenuButton<String>(
              itemBuilder: (BuildContext context) {
                return widget.hasLabDropdownItems.map((hasLab) {
                  return PopupMenuItem<String>(
                    value: hasLab,
                    child: Text(hasLab),
                  );
                }).toList();
              },
              onSelected: (String newValue) {
                setState(() {
                  _selectedHasLab = newValue;
                });
              },
              offset: const Offset(0, 50), // Always opens below
              constraints: const BoxConstraints(maxHeight: 250), // Limit height
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Has Labolatory?',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                child: Text(_selectedHasLab),
              ),
            ),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     const Text('Has Laboratory Class?'),
            //     const SizedBox(height: 10),
            //     Padding(
            //       padding: const EdgeInsets.only(right: 8.0),
            //       child: DropdownButton<String>(
            //         isExpanded: true,
            //         value: _selectedHasLab,
            //         onChanged: (String? newValue) {
            //           setState(() {
            //             _selectedHasLab = newValue!;
            //           });
            //         },
            //         borderRadius: BorderRadius.circular(12.0),
            //         items: widget.hasLabDropdownItems
            //             .map<DropdownMenuItem<String>>((String value) {
            //           return DropdownMenuItem<String>(
            //             value: value,
            //             child: Padding(
            //               padding: const EdgeInsets.only(left: 10.0),
            //               child: Text(value),
            //             ),
            //           );
            //         }).toList(),
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 20),
            PopupMenuButton<String>(
              itemBuilder: (BuildContext context) {
                return widget.yearDropdownItems.map((year) {
                  return PopupMenuItem<String>(
                    value: year,
                    child: Text(year),
                  );
                }).toList();
              },
              onSelected: (String newValue) {
                setState(() {
                  _selectedYear = newValue;
                });
              },
              offset: const Offset(0, 50), // Always opens below
              constraints: const BoxConstraints(maxHeight: 250), // Limit height
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Select Year',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                child: Text(_selectedYear),
              ),
            ),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     const Text('Select Year:'),
            //     const SizedBox(height: 10),
            //     Padding(
            //       padding: const EdgeInsets.only(right: 8.0),
            //       child: DropdownButton<String>(
            //         isExpanded: true,
            //         value: _selectedYear,
            //         onChanged: (String? newValue) {
            //           setState(() {
            //             _selectedYear = newValue!;
            //           });
            //         },
            //         borderRadius: BorderRadius.circular(12.0),
            //         items: widget.yearDropdownItems
            //             .map<DropdownMenuItem<String>>((String value) {
            //           return DropdownMenuItem<String>(
            //             value: value,
            //             child: Padding(
            //               padding: const EdgeInsets.only(left: 10.0),
            //               child: Text(value),
            //             ),
            //           );
            //         }).toList(),
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 20),
            PopupMenuButton<String>(
              itemBuilder: (BuildContext context) {
                return widget.semesterDropdownItems.map((semester) {
                  return PopupMenuItem<String>(
                    value: semester,
                    child: Text(semester),
                  );
                }).toList();
              },
              onSelected: (String newValue) {
                setState(() {
                  _selectedSemester = newValue;
                });
              },
              offset: const Offset(0, 50), // Always opens below
              constraints: const BoxConstraints(maxHeight: 250), // Limit height
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Select Semester',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                child: Text(_selectedSemester),
              ),
            ),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     const Text('Select Semester:'),
            //     const SizedBox(height: 10),
            //     Padding(
            //       padding: const EdgeInsets.only(right: 8.0),
            //       child: DropdownButton<String>(
            //         isExpanded: true,
            //         value: _selectedSemester,
            //         onChanged: (String? newValue) {
            //           setState(() {
            //             _selectedSemester = newValue!;
            //           });
            //         },
            //         borderRadius: BorderRadius.circular(12.0),
            //         items: widget.semesterDropdownItems
            //             .map<DropdownMenuItem<String>>((String value) {
            //           return DropdownMenuItem<String>(
            //             value: value,
            //             child: Padding(
            //               padding: const EdgeInsets.only(left: 10.0),
            //               child: Text(value),
            //             ),
            //           );
            //         }).toList(),
            //       ),
            //     ),
            //   ],
            // ),
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
              _selectedHasLab,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
