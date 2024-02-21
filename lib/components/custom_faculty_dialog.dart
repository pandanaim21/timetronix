import 'package:flutter/material.dart';
import 'package:timetronix/components/custom_textfield.dart';

class CustomFacultyDialog extends StatefulWidget {
  final String title;
  final String firstName;
  final String lastName;
  final List<String> positionDropdownItems;
  final List<int> priorityNumberDropdownItems;
  final String selectedPositionDropdownItem;
  final int selectedPriorityNumberDropdownItem;
  final Function(String, String, String, int) onSubmit;

  const CustomFacultyDialog({
    Key? key,
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.positionDropdownItems,
    required this.priorityNumberDropdownItems,
    required this.selectedPositionDropdownItem,
    required this.selectedPriorityNumberDropdownItem,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _CustomFacultyDialogState createState() => _CustomFacultyDialogState();
}

class _CustomFacultyDialogState extends State<CustomFacultyDialog> {
  late String _firstName;
  late String _lastName;
  late String _selectedPosition;
  late int _selectedPriorityNumber;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _firstName = widget.firstName;
    _lastName = widget.lastName;
    _selectedPosition = widget.selectedPositionDropdownItem;
    _selectedPriorityNumber = widget.selectedPriorityNumberDropdownItem;

    _firstNameController = TextEditingController(text: _firstName);
    _lastNameController = TextEditingController(text: _lastName);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          children: [
            CustomTextField(
              borderColor: Colors.blue,
              hintText: 'Firstname',
              controller: _firstNameController,
              textAlign: TextAlign.left,
              symmetricPadding: const EdgeInsets.symmetric(horizontal: 0.0),
              leftPadding: const EdgeInsets.only(left: 8.0),
              onChanged: (value) {
                setState(() {
                  _firstName = value;
                });
              },
            ),
            SizedBox(height: 10),
            CustomTextField(
              borderColor: Colors.blue,
              hintText: 'Lastname',
              controller: _lastNameController,
              textAlign: TextAlign.left,
              symmetricPadding: const EdgeInsets.symmetric(horizontal: 0.0),
              leftPadding: const EdgeInsets.only(left: 8.0),
              onChanged: (value) {
                setState(() {
                  _lastName = value;
                });
              },
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedPosition,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPosition = newValue!;
                  });
                },
                borderRadius: BorderRadius.circular(12.0),
                //alignment: Alignment.center,
                items: widget.positionDropdownItems
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(value),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: DropdownButton<int>(
                isExpanded: true,
                value: _selectedPriorityNumber,
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedPriorityNumber = newValue!;
                  });
                },
                borderRadius: BorderRadius.circular(12.0),
                //alignment: Alignment.center,
                items: widget.priorityNumberDropdownItems
                    .map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(value.toString()),
                    ),
                  );
                }).toList(),
              ),
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
              _firstName,
              _lastName,
              _selectedPosition,
              _selectedPriorityNumber,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
