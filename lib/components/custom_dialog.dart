import 'package:flutter/material.dart';

class CustomDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final String initialValue; // New property to hold the initial value
  final List<String> dropdownItems;
  final String selectedDropdownItem;
  final Function(String, String) onSubmit;

  const CustomDialog({
    Key? key,
    required this.title,
    required this.hintText,
    required this.initialValue,
    required this.dropdownItems,
    required this.selectedDropdownItem,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
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
          TextField(
            controller: _textController,
            onChanged: (value) {
              setState(() {
                room = value;
              });
            },
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: widget.hintText,
            ),
          ),
          SizedBox(height: 20),
          DropdownButton<String>(
            value: type,
            onChanged: (String? newValue) {
              setState(() {
                type = newValue!;
              });
            },
            items: widget.dropdownItems
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSubmit(room, type);
            Navigator.of(context).pop();
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
