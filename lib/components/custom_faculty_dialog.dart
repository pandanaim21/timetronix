import 'package:flutter/material.dart';
import 'package:timetronix/components/custom_textfield.dart';

class CustomFacultyDialog extends StatefulWidget {
  final String title;
  final String firstName;
  final String lastName;
  final List<String> positionDropdownItems;
  final String selectedPositionDropdownItem;
  final int minimumLoad;
  final int maximumLoad;
  final List<int> priorityNumberDropdownItems;
  final int selectedPriorityNumberDropdownItem;
  final Function(String, String, String, int, int, int) onSubmit;

  const CustomFacultyDialog({
    Key? key,
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.positionDropdownItems,
    required this.selectedPositionDropdownItem,
    required this.minimumLoad,
    required this.maximumLoad,
    required this.priorityNumberDropdownItems,
    required this.selectedPriorityNumberDropdownItem,
    required this.onSubmit,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CustomFacultyDialogState createState() => _CustomFacultyDialogState();
}

class _CustomFacultyDialogState extends State<CustomFacultyDialog> {
  late String _firstName;
  late String _lastName;
  late String _selectedPosition;
  late int _minimumLoad;
  late int _maximumLoad;
  late int _selectedPriorityNumber;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _minimumLoadController;
  late TextEditingController _maximumLoadController;

  @override
  void initState() {
    super.initState();
    _firstName = widget.firstName;
    _lastName = widget.lastName;
    _selectedPosition = widget.selectedPositionDropdownItem;
    _minimumLoad = widget.minimumLoad;
    _maximumLoad = widget.maximumLoad;
    _selectedPriorityNumber = widget.selectedPriorityNumberDropdownItem;

    _firstNameController = TextEditingController(text: _firstName);
    _lastNameController = TextEditingController(text: _lastName);
    _minimumLoadController =
        TextEditingController(text: _minimumLoad.toString());
    _maximumLoadController =
        TextEditingController(text: _maximumLoad.toString());

    _updatePriorityNumber();
  }

  void _updatePriorityNumber() {
    switch (_selectedPosition) {
      case 'Dean':
        _selectedPriorityNumber = 1;
        break;
      case 'Assistant Dean':
        _selectedPriorityNumber = 2;
        break;
      case 'Secretary':
        _selectedPriorityNumber = 3;
        break;
      case 'Chairperson':
        _selectedPriorityNumber = 4;
        break;
      case 'Faculty':
        _selectedPriorityNumber = 5;
        break;
    }
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
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            CustomTextField(
              borderColor: Colors.blue,
              hintText: 'Min Units',
              controller: _minimumLoadController,
              textAlign: TextAlign.left,
              symmetricPadding: const EdgeInsets.symmetric(horizontal: 0.0),
              leftPadding: const EdgeInsets.only(left: 8.0),
              onChanged: (value) {
                setState(() {
                  _minimumLoad = int.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 10),
            CustomTextField(
              borderColor: Colors.blue,
              hintText: 'Max Units',
              controller: _maximumLoadController,
              textAlign: TextAlign.left,
              symmetricPadding: const EdgeInsets.symmetric(horizontal: 0.0),
              leftPadding: const EdgeInsets.only(left: 8.0),
              onChanged: (value) {
                setState(() {
                  _maximumLoad = int.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Position'),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedPosition,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPosition = newValue!;
                        _updatePriorityNumber();
                      });
                    },
                    borderRadius: BorderRadius.circular(12.0),
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
              ],
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Priority Number'),
                const SizedBox(height: 10),
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
              _minimumLoad,
              _maximumLoad,
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
