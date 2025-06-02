import 'package:flutter/material.dart';

showCustomAssignDialog(
  BuildContext context,
  // List<DropdownMenuItem<String>> facultyDropdownItems,
  List<Map<String, dynamic>> facultyDropdownItems,
  List<Map<String, dynamic>> courseDropdownItems,
  Function(String?) onFacultySelected,
  Function(String?) onCourseSelected,
  Function() onClassSelected,
  Function() onSubmit,
  Function() resetVariable,
  String ClassButtonText,
) {
  //String? selectedFaculty;
  Map<String, dynamic>? selectedFaculty;
  Map<String, dynamic>? selectedCourse;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Assign'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuButton<Map<String, dynamic>>(
                  itemBuilder: (BuildContext context) {
                    return facultyDropdownItems.map((faculty) {
                      return PopupMenuItem<Map<String, dynamic>>(
                        value: faculty,
                        child: Text(
                          faculty['firstname'] + ' ' + faculty['lastname'],
                        ),
                      );
                    }).toList();
                  },
                  onSelected: (Map<String, dynamic> value) {
                    setState(() {
                      selectedFaculty = value;
                    });
                    onFacultySelected(value['faculty_id'].toString());
                  },
                  offset: const Offset(0, 50), // Always opens below
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Select faculty',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    child: Text(
                      '${selectedFaculty?['firstname'] ?? ''} ${selectedFaculty?['lastname'] ?? ''}'
                          .trim(),
                    ),
                  ), // Limit height
                ),
                // DropdownButton<String>(
                //   isExpanded: true,
                //   items: facultyDropdownItems,
                //   onChanged: (String? value) {
                //     setState(() {
                //       selectedFaculty = value;
                //     });
                //     onFacultySelected(value);
                //   },
                //   value: selectedFaculty,
                //   hint: const Text('Select Faculty'),
                //   dropdownColor: Colors.white,
                // ),
                const SizedBox(height: 10),
                PopupMenuButton<Map<String, dynamic>>(
                  itemBuilder: (BuildContext context) {
                    return courseDropdownItems.map((course) {
                      return PopupMenuItem<Map<String, dynamic>>(
                        value: course,
                        child: Text(course['course_id']),
                      );
                    }).toList();
                  },
                  onSelected: (Map<String, dynamic> value) {
                    setState(() {
                      selectedCourse = value;
                    });
                    onCourseSelected(value['course_id'].toString());
                  },
                  offset: const Offset(0, 50), // Always opens below
                  constraints: const BoxConstraints(maxHeight: 100),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Select Course',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    child: Text(selectedCourse?['course_id'] ?? ''),
                  ), // Limit height
                ),
                // DropdownButton<Map<String, dynamic>>(
                //   isExpanded: true,
                //   items: courseDropdownItems.map((course) {
                //     return DropdownMenuItem<Map<String, dynamic>>(
                //       value: course,
                //       child: Text(course['course_id']),
                //     );
                //   }).toList(),
                //   onChanged: (Map<String, dynamic>? value) {
                //     setState(() {
                //       selectedCourse = value;
                //     });
                //     onCourseSelected(value?['course_id'].toString());
                //   },
                //   value: selectedCourse,
                //   hint: const Text('Select Course'),
                //   dropdownColor: Colors.white,
                //   menuMaxHeight: 300, // Limit the maximum height
                //   itemHeight: 48, // Standard item height
                //   selectedItemBuilder: (BuildContext context) {
                //     return courseDropdownItems.take(5).map((course) {
                //       return Align(
                //         alignment: Alignment.centerLeft,
                //         child: Text(
                //           course['course_id'],
                //           overflow: TextOverflow.ellipsis,
                //         ),
                //       );
                //     }).toList();
                //   },
                // ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    onClassSelected();
                  },
                  child: Text(ClassButtonText),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Reset variables here
                        selectedFaculty = null;
                        selectedCourse = null;
                        resetVariable();
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        onSubmit();
                        // Reset variables here
                        selectedFaculty = null;
                        selectedCourse = null;
                        resetVariable();
                        Navigator.pop(context);
                      },
                      child: const Text('Submit'),
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
