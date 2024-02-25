// import 'dart:async';
// import 'package:timetronix/db/db_helper.dart';

// // Declare variables at a higher scope
// List<dynamic> lecRoom = [];
// List<dynamic> labRoom = [];
// Map<String, List<dynamic>> curriculum = {};
// List<dynamic> course_assignments = [];
// Map<String, Map<String, List<dynamic>>> schedules = {};

// void main() async {
//   try {
//     await initializeData();
//     generateSchedules();
//   } catch (e) {
//     print("Error: $e");
//   }
// }

// Future<void> initializeData() async {
//   final dbHelper = DatabaseHelper();

//   // Fetch classroom data
//   final allRooms = await dbHelper.getClassrooms();

//   // Separate rooms based on their type
//   for (var room in allRooms) {
//     if (room['type'] == 'Lecture Class') {
//       lecRoom.add(room);
//     } else if (room['type'] == 'Laboratory Class') {
//       labRoom.add(room);
//     }
//   }

//   // Fetch curriculum data
//   final curriculumData = await dbHelper.getCurriculum();
//   curriculumData.forEach((data) {
//     final course = data['course'] as String;
//     curriculum[course] = [
//       data['description'],
//       data['year'],
//       data['semester'],
//       data['units'],
//       data['lec_units'],
//       data['lab_units'],
//       data['total_units'],
//       data['meeting']
//     ];
//   });

//   // Fetch course assignments data
//   course_assignments = await dbHelper.getAssign();
// }

// void generateSchedules() {
//   for (var assignment in course_assignments) {
//     var faculty = assignment['faculty_id'];
//     var course = assignment['course_id'];
//     var lecDayPreference = assignment['lecture_day'];
//     var lectureTimePreference = assignment['lecture_start_time'];
//     var labDayPreference = assignment['laboratory_day'];
//     var laboratoryTimePreference = assignment['laboratory_start_time'];

//     // Extract course details from curriculum
//     var courseDetails = curriculum[course.toString()];
//     var courseDescription = courseDetails?[0];
//     var courseYear = courseDetails?[1];
//     var courseSemester = courseDetails?[2];
//     var courseUnits = courseDetails?[3];
//     var lecUnits = courseDetails?[4];
//     var labUnits = courseDetails?[5];
//     var totalUnits = courseDetails?[6];
//     var meetings = courseDetails?[7];

//     // Initialize variables
//     var lecDay;
//     var labDay;
//     var labDay1;
//     var labDay2;
//     var lecClassroom;
//     var lecClassroom2;
//     var labClassroom;
//     var lecStartTime;
//     var lecEndTime;
//     var labStartTime;
//     var labEndTime;
//     var classroomCorrection = false;
//     var scheduleCorrection = false;
//     var labSec1; // Define labSec1
//     var labSec2; // Define labSec2
//     var lecture; // Define lecture
//     var laboratory; // Define laboratory

//     // Get preferred days for lecture and lab
//     lecDay = lecDayPreference;
//     var days = getDaySched(lecDayPreference);
//     var day1 = days[0];
//     var day2 = days[1];
//     var day3 = days[2];
//     var day4 = days[3];

//     if (labUnits != 0) {
//       labDay = labDayPreference;
//       var labDays = getDaySched(labDayPreference);
//       labDay1 = labDays[0];
//       labDay2 = labDays[1];
//     }

//     // Generate schedules
//     while (true) {
//       var conflictFlagClassroom = false;
//       var conflictFlagSchedule = false;

//       // Generate schedule details for lecture
//       var lectureSchedule = getLectureSched(
//         day1,
//         day2,
//         meetings,
//         lectureTimePreference,
//         lecRoom,
//       );
//       var lecSec1 = lectureSchedule[0];
//       var lecSec2 = lectureSchedule[1];
//       lecStartTime = lectureSchedule[2];
//       lecEndTime = lectureSchedule[3];
//       lecClassroom = lectureSchedule[4];

//       if (day3 != null && (labUnits == 0)) {
//         var lectureSchedule2 = getLectureSched(
//           day3,
//           day4,
//           meetings,
//           lectureTimePreference,
//           lecRoom,
//         );
//         lecSec1 = lectureSchedule2[0];
//         lecSec2 = lectureSchedule2[1];
//         lecStartTime = lectureSchedule2[2];
//         lecEndTime = lectureSchedule2[3];
//         lecClassroom2 = lectureSchedule2[4];
//       }

//       // Generate schedule details for laboratory
//       if (labUnits != 0) {
//         var labSchedule = getLaboratorySched(
//           day1,
//           day2,
//           labDay1,
//           labDay2,
//           lecSec1,
//           lecSec2,
//           laboratoryTimePreference,
//           labRoom,
//           labUnits,
//           meetings,
//         );
//         var labSec1 = labSchedule[0];
//         var labSec2 = labSchedule[1];
//         labStartTime = labSchedule[2];
//         labEndTime = labSchedule[3];
//         labClassroom = labSchedule[4];
//       }

//       // Check for schedule conflicts
//       var conflictDetails = checkConflict(
//         schedules,
//         faculty,
//         course,
//         courseYear,
//         courseSemester,
//         lecDay,
//         lecStartTime,
//         lecEndTime,
//         lecClassroom,
//         labUnits,
//         labDay,
//         labStartTime,
//         labEndTime,
//         labClassroom,
//       );
//       conflictFlagClassroom = conflictDetails[0];
//       conflictFlagSchedule = conflictDetails[1];
//       var conflictFaculty = conflictDetails[2];
//       var conflictCourse = conflictDetails[3];

//       // Handle conflicts
//       if (!conflictFlagClassroom && !conflictFlagSchedule) {
//         // Insert generated data if no conflict
//         schedules.putIfAbsent(faculty.toString(), () => {});
//         schedules[faculty.toString()]?.putIfAbsent(course.toString(), () => []);

//         if (day2 != null) {
//           if (meetings == 3 || meetings == 4) {
//             schedules[faculty.toString()]![course.toString()]?.add([
//               day1 + day2,
//               courseSemester,
//               courseUnits,
//               lecUnits,
//               labUnits,
//               courseDescription,
//               courseYear,
//               lecSec1 + lecSec2,
//               lecStartTime,
//               lecEndTime,
//               lecClassroom,
//               meetings,
//               'Lecture'
//             ]);
//             if (labUnits == 0) {
//               schedules[faculty.toString()]![course.toString()]?.add([
//                 day3 + day4,
//                 courseSemester,
//                 courseUnits,
//                 lecUnits,
//                 labUnits,
//                 courseDescription,
//                 courseYear,
//                 lecSec1 + lecSec2,
//                 lecStartTime,
//                 lecEndTime,
//                 lecClassroom2,
//                 meetings,
//                 'Lecture'
//               ]);
//             } else if (day4 == null && labUnits == 3) {
//               schedules[faculty.toString()]![course.toString()]?.add([
//                 labDay1,
//                 courseSemester,
//                 courseUnits,
//                 lecUnits,
//                 labUnits,
//                 courseDescription,
//                 courseYear,
//                 labSec1 + labSec2,
//                 labStartTime,
//                 labEndTime,
//                 labClassroom,
//                 meetings,
//                 'Laboratory'
//               ]);
//             } else if (day4 != null && labUnits >= 3) {
//               schedules[faculty.toString()]![course.toString()]?.add([
//                 labDay1,
//                 courseSemester,
//                 courseUnits,
//                 lecUnits,
//                 labUnits,
//                 courseDescription,
//                 courseYear,
//                 labSec1 + labSec2,
//                 labStartTime,
//                 labEndTime,
//                 labClassroom,
//                 meetings,
//                 'Laboratory'
//               ]);
//             }
//           } else {
//             schedules[faculty.toString()]![course.toString()]?.add([
//               lecDay,
//               courseSemester,
//               courseUnits,
//               lecUnits,
//               labUnits,
//               courseDescription,
//               courseYear,
//               lecSec1 + lecSec2,
//               lecStartTime,
//               lecEndTime,
//               lecClassroom,
//               meetings,
//               'Lecture'
//             ]);
//             if (labUnits != 0) {
//               schedules[faculty.toString()]![course.toString()]?.add([
//                 labDay1,
//                 courseSemester,
//                 courseUnits,
//                 lecUnits,
//                 labUnits,
//                 courseDescription,
//                 courseYear,
//                 labSec1 + labSec2,
//                 labStartTime,
//                 labEndTime,
//                 labClassroom,
//                 meetings,
//                 'Laboratory'
//               ]);
//             }
//           }
//         } else {
//           if (meetings == 1) {
//             schedules[faculty.toString()]![course.toString()]?.add([
//               lecDay,
//               courseSemester,
//               courseUnits,
//               lecUnits,
//               labUnits,
//               courseDescription,
//               courseYear,
//               lecSec1 + lecSec2,
//               lecStartTime,
//               lecEndTime,
//               lecClassroom,
//               meetings,
//               'Lecture'
//             ]);
//           } else {
//             schedules[faculty.toString()]![course.toString()]?.add([
//               lecDay,
//               courseSemester,
//               courseUnits,
//               lecUnits,
//               labUnits,
//               courseDescription,
//               courseYear,
//               lecSec1,
//               lecStartTime,
//               lecEndTime,
//               lecClassroom,
//               meetings,
//               'Lecture'
//             ]);
//           }
//           if (labUnits != 0) {
//             schedules[faculty.toString()]![course.toString()]?.add([
//               labDay1,
//               courseSemester,
//               courseUnits,
//               lecUnits,
//               labUnits,
//               courseDescription,
//               courseYear,
//               labSec1,
//               labStartTime,
//               labEndTime,
//               labClassroom,
//               meetings,
//               'Laboratory'
//             ]);
//           }
//         }
//         break;
//       } else {
//         if (conflictFlagSchedule) {
//           print(
//               "$faculty: $course was conflicted to his/her other lec course: $conflictCourse");
//           if (labUnits != 0) {
//             print(
//                 "$faculty: $course was conflicted to his/her other lab course: $conflictCourse");
//           }
//           scheduleCorrection = conflictFlagSchedule;
//           lectureTimePreference = null;
//           laboratoryTimePreference = null;
//         } else if (conflictFlagClassroom) {
//           print(
//               "$faculty: $course was conflicted to $conflictFaculty: $conflictCourse lec room: $lecClassroom");
//           if (labUnits != 0) {
//             print(
//                 "$faculty: $course was conflicted to $conflictFaculty: $conflictCourse lab room: $labClassroom");
//           }
//           classroomCorrection = conflictFlagClassroom;
//           lecture = null;
//           laboratory = null;
//         }
//       }
//     }
//   }
//   printVariables();
// }

// List<dynamic> getDaySched(dayPreference) {
//   // Implement logic to convert day preference to actual schedule days
//   return [];
// }

// List<dynamic> getLectureSched(
//     day1, day2, meetings, lectureTimePreference, lecRoom) {
//   // Implement logic to generate lecture schedule
//   return [];
// }

// List<dynamic> getLaboratorySched(day1, day2, labDay1, labDay2, lecSec1, lecSec2,
//     laboratoryTimePreference, labRoom, labUnits, meetings) {
//   // Implement logic to generate laboratory schedule
//   return [];
// }

// List<dynamic> checkConflict(
//     schedules,
//     faculty,
//     course,
//     courseYear,
//     courseSemester,
//     lecDay,
//     lecStartTime,
//     lecEndTime,
//     lecClassroom,
//     labUnits,
//     labDay,
//     labStartTime,
//     labEndTime,
//     labClassroom) {
//   // Implement logic to check for conflicts
//   return [];
// }

// void printVariables() {
//   print("lecRoom: $lecRoom");
//   print("labRoom: $labRoom");
//   print("curriculum: $curriculum");
//   print("course_assignments: $course_assignments");
//   print("schedules: $schedules");
// }
