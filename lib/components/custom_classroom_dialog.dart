import 'package:flutter/material.dart';

class CustomClassroomDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final String initialValue; // New property to hold the initial value
  final List<String> dropdownItems;
  final String selectedDropdownItem;
  final Function(String, String) onSubmit;

  const CustomClassroomDialog({
    Key? key,
    required this.title,
    required this.hintText,
    required this.initialValue,
    required this.dropdownItems,
    required this.selectedDropdownItem,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _CustomClassroomDialogState createState() => _CustomClassroomDialogState();
}

class _CustomClassroomDialogState extends State<CustomClassroomDialog> {
  late String room;
  late String type;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    room = widget.initialValue;
    type = widget.selectedDropdownItem;
    _textController = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: TextField(
              controller: _textController,
              onChanged: (value) {
                setState(() {
                  room = value;
                });
              },
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          DropdownButton<String>(
            value: type,
            onChanged: (String? newValue) {
              setState(() {
                type = newValue!;
              });
            },
            borderRadius: BorderRadius.circular(15.0),
            alignment: Alignment.center,
            items: widget.dropdownItems
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Center(child: Text(value)),
              );
            }).toList(),
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
            widget.onSubmit(room, type);
            Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
