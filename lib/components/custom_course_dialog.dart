import 'package:flutter/material.dart';
import 'package:timetronix/components/format_time.dart';

String _formatTime(int hour, int minute) {
  return formatTime(hour, minute);
}

void showCustomClassDialog(
  BuildContext context,
  String className,
  // List<DropdownMenuItem<String>> roomDropdownItems,
  List<Map<String, dynamic>> roomDropdownItems,
  //List<DropdownMenuItem<String>> laboratoryRoomDropdownItems,
  Set<String> selectedDays,
  //Set<String> selectedLabDays,
  String? selectedRoom,
  //String? selectedLaboratoryRoom,
  String? selectedStartTime,
  String? selectedEndTime,
  // String? selectedLabStartTime,
  // String? selectedLabEndTime,
  List<String> days,
  Function(String?) onRoomSeleceted,
  Function(String) onDaySeleceted,
  Function(int, int) onStartTimeSelected,
  Function(int, int) onEndTimeSelected,
  Function() resetVariable,
) {
  Map<String, dynamic>? selectedRoom;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(className),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuButton<Map<String, dynamic>>(
                  itemBuilder: (BuildContext context) {
                    return roomDropdownItems.map((room) {
                      return PopupMenuItem<Map<String, dynamic>>(
                        value: room,
                        child: Text(room['room']),
                      );
                    }).toList();
                  },
                  onSelected: (Map<String, dynamic> value) {
                    setState(() {
                      selectedRoom = value;
                    });
                    onRoomSeleceted(value['room_id'].toString());
                  },
                  offset: const Offset(0, 50), // Always opens below
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Select Room',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                    ),
                    child: Text(selectedRoom?['room'] ?? ''),
                  ), // Limit height
                ),
                // DropdownButton<String>(
                //   isExpanded: true,
                //   items: roomDropdownItems,
                //   onChanged: (value) {
                //     onRoomChanged(value);
                //     setState(() {
                //       selectedRoom = value;
                //     });
                //   },
                //   value: selectedRoom,
                //   hint: const Text('Select Room'),
                // ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: days.map((day) {
                    bool isSelected = (selectedDays).contains(day);
                    return IconButton(
                      onPressed: () {
                        onDaySeleceted(day);
                        setState(() {}); // State changed, trigger rebuild
                      },
                      icon: CircleAvatar(
                        backgroundColor:
                            isSelected ? Colors.blue[800] : Colors.grey[400],
                        child: Text(
                          day,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          onStartTimeSelected(picked.hour, picked.minute);
                          setState(() {
                            selectedStartTime =
                                _formatTime(picked.hour, picked.minute);
                          });
                        }
                      },
                      child: SizedBox(
                        width: 150,
                        child: Text(
                          selectedStartTime ?? 'Select Start Time',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(' - '),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          onEndTimeSelected(picked.hour, picked.minute);
                          setState(() {
                            selectedEndTime =
                                _formatTime(picked.hour, picked.minute);
                          });
                        }
                      },
                      child: SizedBox(
                        width: 150,
                        child: Text(
                          selectedEndTime ?? 'Select End Time',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        resetVariable();
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
