import 'dart:async';
import 'package:timetronix/db/db_helper.dart';

// Declare variables at a higher scope
List<Map<String, dynamic>> lecRoom = [];
List<Map<String, dynamic>> labRoom = [];
List<Map<String, dynamic>> courseAssignments = [];

void main() async {
  try {
    await initializeData();
  } catch (e) {
    print("Error: $e");
  }
}

Future<void> initializeData() async {
  final dbHelper = DatabaseHelper();
  lecRoom = await dbHelper.getLectureRooms();
  labRoom = await dbHelper.getLaboratoryRooms();
  courseAssignments = await dbHelper.getAssign();

  // Declare variables to hold assignment details outside the loop
  Map<String, dynamic> lectureAssignmentDetails;
  Map<String, dynamic> laboratoryAssignmentDetails;

  // Get lecture assignment details outside the loop
  for (final assignment in courseAssignments) {
    final facultyId = assignment['faculty_id'];
    final courseId = assignment['course_id'];

    lectureAssignmentDetails =
        await dbHelper.getLectureAssignment(facultyId, courseId);

    // Process lecture details
    processLectureDetails(lectureAssignmentDetails);

    // Process laboratory details if applicable
    if (lectureAssignmentDetails['hasLab'] == 'YES') {
      laboratoryAssignmentDetails = await dbHelper.getLaboratoryAssignment(
          facultyId, courseId, 'Laboratory Class');
      processLaboratoryDetails(laboratoryAssignmentDetails);
    }
  }
}

void processLectureDetails(Map<String, dynamic> details) {
  final facultyFirstname = details['faculty_firstname'];
  final facultyLastname = details['faculty_lastname'];
  final priorityNumber = details['priority_number'];
  final course = details['course'];
  final description = details['description'];
  final lecRoom = details['room'];
  final lecDay = details['day'];
  final lecStarTime = details['start_time'];
  final lecEndTime = details['end_time'];

  // Print lecture details
  print('Faculty Name: $facultyFirstname $facultyLastname');
  print('Priority Number: $priorityNumber');
  print('Course: $course');
  print('Description: $description');
  print('Lecture Details:');
  print('Classroom: $lecRoom');
  print('Day: $lecDay');
  print('Start Time: $lecStarTime - End Time: $lecEndTime');
}

void processLaboratoryDetails(Map<String, dynamic> details) {
  final labRoom = details['room'];
  final labDay = details['day'];
  final labStarTime = details['start_time'];
  final labEndTime = details['end_time'];

  // Print laboratory details
  print('Laboratory Details:');
  print('Classroom: $labRoom');
  print('Day: $labDay');
  print('Start Time: $labStarTime - End Time: $labEndTime');
}
