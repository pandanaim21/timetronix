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
  // ignore: library_private_types_in_public_api
  _CustomClassroomDialogState createState() => _CustomClassroomDialogState();
}

class _CustomClassroomDialogState extends State<CustomClassroomDialog> {
  late String _room;
  late String _selectedType;
  late TextEditingController _roomController;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _selectedType = widget.selectedDropdownItem;

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
            hintText: 'Room',
            controller: _roomController,
            textAlign: TextAlign.center,
            //symmetricPadding: const EdgeInsets.symmetric(horizontal: 45.0),
            leftPadding: const EdgeInsets.only(left: 0.0),
            onChanged: (value) {
              setState(() {
                _room = value;
              });
            },
          ),
          const SizedBox(height: 20),
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return widget.dropdownItems.map((roomType) {
                return PopupMenuItem<String>(
                  value: roomType,
                  child: Text(roomType),
                );
              }).toList();
            },
            onSelected: (String newValue) {
              setState(() {
                _selectedType = newValue;
              });
            },
            offset: const Offset(0, 50), // Always opens below
            constraints: const BoxConstraints(maxHeight: 250), // Limit height
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Position',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              child: Text(_selectedType),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 30.0),
          //   child: DropdownButton<String>(
          //     isExpanded: true,
          //     value: _type,
          //     onChanged: (String? newValue) {
          //       setState(() {
          //         _type = newValue!;
          //       });
          //     },
          //     borderRadius: BorderRadius.circular(12.0),
          //     //alignment: Alignment.center,
          //     items: widget.dropdownItems
          //         .map<DropdownMenuItem<String>>((String value) {
          //       return DropdownMenuItem<String>(
          //         value: value,
          //         child: Padding(
          //           padding: const EdgeInsets.only(left: 10.0),
          //           child: Text(value),
          //         ),
          //       );
          //     }).toList(),
          //   ),
          // ),
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
            widget.onSubmit(_room, _selectedType);
            Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
