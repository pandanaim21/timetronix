import 'package:flutter/material.dart';
import 'package:timetronix/components/custom_textfield.dart';

class CustomClassroomDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final String room;
  final List<String> dropdownItems;
  final String selectedDropdownItem;
  final Function(String, String) onSubmit;

  const CustomClassroomDialog({
    Key? key,
    required this.title,
    required this.hintText,
    required this.room,
    required this.dropdownItems,
    required this.selectedDropdownItem,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _CustomClassroomDialogState createState() => _CustomClassroomDialogState();
}

class _CustomClassroomDialogState extends State<CustomClassroomDialog> {
  late String _room;
  late String _type;
  late TextEditingController _roomController;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _type = widget.selectedDropdownItem;

    _roomController = TextEditingController(text: _room);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 50),
          CustomTextField(
            borderColor: Colors.blue,
            hintText: 'Classroom',
            controller: _roomController,
            textAlign: TextAlign.center,
            symmetricPadding: const EdgeInsets.symmetric(horizontal: 45.0),
            leftPadding: const EdgeInsets.only(left: 0.0),
            onChanged: (value) {
              setState(() {
                _room = value;
              });
            },
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _type,
              onChanged: (String? newValue) {
                setState(() {
                  _type = newValue!;
                });
              },
              borderRadius: BorderRadius.circular(12.0),
              //alignment: Alignment.center,
              items: widget.dropdownItems
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
          const SizedBox(height: 50),
        ],
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
            widget.onSubmit(_room, _type);
            Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
