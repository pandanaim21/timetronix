import 'package:flutter/material.dart';

showCustomAssignDialog(
    BuildContext context,
    List<DropdownMenuItem<String>> facultyDropdownItems,
    List<DropdownMenuItem<String>> courseDropdownItems,
    Function(String?) onFacultySelected,
    Function(String?) onCourseSelected,
    Function() onLectureClassSelected,
    Function() onLaboratoryClassSelected,
    Function() onSubmit) {
  String? selectedFaculty;
  String? selectedCourse;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Assign'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              isExpanded: true,
              items: facultyDropdownItems,
              onChanged: (String? value) {
                onFacultySelected(value);
              },
              value: selectedFaculty,
              hint: const Text('Select Faculty'),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              isExpanded: true,
              items: courseDropdownItems,
              onChanged: (String? value) {
                onCourseSelected(value);
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
                  onPressed: () {
                    onLaboratoryClassSelected();
                  },
                  child: const Text('Laboratory Class'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                onSubmit();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      );
    },
  );
}
