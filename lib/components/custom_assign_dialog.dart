import 'package:flutter/material.dart';

showCustomAssignDialog(
  BuildContext context,
  List<DropdownMenuItem<String>> facultyDropdownItems,
  List<Map<String, dynamic>> courseDropdownItems,
  Function(String?) onFacultySelected,
  Function(String?) onCourseSelected,
  Function() onLectureClassSelected,
  Function() onLaboratoryClassSelected,
  Function() onSubmit,
  Function() resetVariable,
) {
  String? selectedFaculty;
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
                DropdownButton<String>(
                  isExpanded: true,
                  items: facultyDropdownItems,
                  onChanged: (String? value) {
                    setState(() {
                      selectedFaculty = value;
                    });
                    onFacultySelected(value);
                  },
                  value: selectedFaculty,
                  hint: const Text('Select Faculty'),
                ),
                const SizedBox(height: 10),
                DropdownButton<Map<String, dynamic>>(
                  isExpanded: true,
                  items: courseDropdownItems.map((course) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: course,
                      child: Text(course['course']),
                    );
                  }).toList(),
                  onChanged: (Map<String, dynamic>? value) {
                    setState(() {
                      selectedCourse = value;
                    });
                    onCourseSelected(value?['id'].toString());
                  },
                  value: selectedCourse,
                  hint: const Text('Select Course'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        onLectureClassSelected();
                      },
                      child: const Text('Lecture Class'),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton(
                      onPressed: selectedCourse != null &&
                              selectedCourse!['hasLab'] == 'YES'
                          ? onLaboratoryClassSelected
                          : null,
                      child: const Text('Laboratory Class'),
                    ),
                  ],
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
