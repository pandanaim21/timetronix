// import 'package:flutter/material.dart';
// import 'package:timetronix/components/custom_assignment_dialog.dart';
// import 'package:timetronix/db/db_helper.dart';

// class AddAssigns extends StatefulWidget {
//   const AddAssigns({Key? key}) : super(key: key);

//   @override
//   // ignore: library_private_types_in_public_api
//   _AddAssignsState createState() => _AddAssignsState();
// }

// class _AddAssignsState extends State<AddAssigns> {
//   final dbHelper = DatabaseHelper();

//   String? _selectedFaculty;
//   String? _selectedCourse;

//   List<DropdownMenuItem<String>> _facultyDropdownItems = [];
//   List<Map<String, dynamic>> _courseDropdownItems = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     final faculties = await dbHelper.getFaculty();
//     final courses = await dbHelper.getCurriculum();

//     setState(
//       () {
//         _facultyDropdownItems =
//             faculties.map<DropdownMenuItem<String>>((faculty) {
//           return DropdownMenuItem<String>(
//             value: faculty['id'].toString(),
//             child: Text(faculty['firstname'] + ' ' + faculty['lastname']),
//           );
//         }).toList();

//         _courseDropdownItems = courses.map<Map<String, dynamic>>((course) {
//           return {
//             'id': course['id'].toString(),
//             'course': course['course'],
//             'hasLab': course['hasLab'],
//           };
//         }).toList();
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Assign Faculty'),
//         backgroundColor: Colors.blue[800],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(15.0),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(15.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {
//                       showCustomAssignDialog(
//                         context,
//                         _facultyDropdownItems,
//                         _courseDropdownItems,
//                         (String? value) {
//                           _selectedFaculty = value;
//                         },
//                         (String? value) {
//                           _selectedCourse = value;
//                         },
//                         () {
//                           addAssign();
//                         },
//                       );
//                     },
//                     child: const Text('Assign Faculty'),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: FutureBuilder<List<Map<String, dynamic>>>(
//                 future: dbHelper.getAssignment(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   } else if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   } else {
//                     final assignments = snapshot.data!;
//                     return ListView.builder(
//                       itemCount: assignments.length,
//                       itemBuilder: (context, index) {
//                         final assignment = assignments[index];
//                         final facultyName =
//                             '${assignment['firstname']} ${assignment['lastname']}';
//                         final courseName = assignment['course'];
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8.0),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: Card(
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Text(
//                                       'Faculty: $facultyName',
//                                       style: const TextStyle(fontSize: 16.0),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Card(
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Text(
//                                       'Course: $courseName',
//                                       style: const TextStyle(fontSize: 16.0),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void addAssign() async {
//     await dbHelper.addAssign(
//       int.parse(_selectedFaculty!),
//       int.parse(_selectedCourse!),
//     );
//     _loadData();
//   }
// }
