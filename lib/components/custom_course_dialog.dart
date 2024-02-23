import 'package:flutter/material.dart';

void showCustomClassDialog(
  BuildContext context,
  String className,
  List<DropdownMenuItem<String>> lectureRoomDropdownItems,
  List<DropdownMenuItem<String>> laboratoryRoomDropdownItems,
  Set<String> selectedLectureDays,
  Set<String> selectedLabDays,
  String? selectedLectureRoom,
  String? selectedLaboratoryRoom,
  String? selectedLectureStartTime,
  String? selectedLectureEndTime,
  String? selectedLabStartTime,
  String? selectedLabEndTime,
  List<String> days,
  Function(String?) onRoomChanged,
  Function(String) onDayPressed,
  Function(int, int) onStartTimeSelected,
  Function(int, int) onEndTimeSelected,
) {
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
                DropdownButton<String>(
                  isExpanded: true,
                  items: className == 'Lecture Class'
                      ? lectureRoomDropdownItems
                      : laboratoryRoomDropdownItems,
                  onChanged: (value) {
                    if (className == 'Lecture Class') {
                      onRoomChanged(value);
                      setState(() {
                        selectedLectureRoom = value;
                      });
                    } else if (className == 'Laboratory Class') {
                      onRoomChanged(value);
                      setState(() {
                        selectedLaboratoryRoom = value;
                      });
                    }
                  },
                  value: className == 'Lecture Class'
                      ? selectedLectureRoom
                      : selectedLaboratoryRoom,
                  hint: className == 'Lecture Class'
                      ? const Text('Select Lecture Room')
                      : const Text('Select Laboratory Room'),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: days
                      .map(
                        (day) => IconButton(
                          onPressed: () {
                            onDayPressed(day);
                            setState(() {}); // State changed, trigger rebuild
                          },
                          icon: Text(
                            day,
                            style: TextStyle(
                              color: (className == 'Lecture Class'
                                          ? selectedLectureDays
                                          : selectedLabDays)
                                      .contains(day)
                                  ? Colors.red[900]
                                  : Colors.black,
                            ),
                          ),
                        ),
                      )
                      .toList(),
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
                          setState(() {}); // State changed, trigger rebuild
                        }
                      },
                      child: SizedBox(
                        width: 150,
                        child: Text(
                          (className == 'Lecture Class'
                                  ? selectedLectureStartTime
                                  : selectedLabStartTime) ??
                              'Select Start Time',
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
                          setState(() {}); // State changed, trigger rebuild
                        }
                      },
                      child: SizedBox(
                        width: 150,
                        child: Text(
                          (className == 'Lecture Class'
                                  ? selectedLectureEndTime
                                  : selectedLabEndTime) ??
                              'Select End Time',
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
