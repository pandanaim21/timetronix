import 'package:flutter/material.dart';
import 'package:timetronix/db/db_helper.dart';
import 'package:timetronix/pages/assign.dart';
import 'package:timetronix/pages/classroom.dart';
import 'package:timetronix/pages/faculty.dart';
import 'package:timetronix/pages/curriculum.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TIMETRONIX',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue[800]),
              child: const Text('LOGO'),
            ),
            ListTile(
              leading: const Icon(Icons.add_box),
              title: const Text('Classroom'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddClassroom()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Curriculum'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddCurriculum()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Faculty'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddFaculty()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Assign Faculty'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddAssigns()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildStatisticBox(
                      context,
                      'Classrooms',
                      DatabaseHelper()
                          .getClassrooms()
                          .then((value) => value.length.toString()),
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Expanded(
                    child: _buildStatisticBox(
                      context,
                      'Courses',
                      DatabaseHelper()
                          .getCurriculum()
                          .then((value) => value.length.toString()),
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Expanded(
                    child: _buildStatisticBox(
                      context,
                      'Faculties',
                      DatabaseHelper()
                          .getFaculty()
                          .then((value) => value.length.toString()),
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Expanded(
                    child: _buildStatisticBox(
                      context,
                      'Assigns',
                      DatabaseHelper()
                          .getAssign()
                          .then((value) => value.length.toString()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Expanded(
                child: _buildStatisticBox(
                  context,
                  'Schedules',
                  DatabaseHelper()
                      .getAssign()
                      .then((value) => value.length.toString()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticBox(
      BuildContext context, String title, Future<String> value) {
    return FutureBuilder<String>(
      future: value,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 100,
            height: 100,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        } else {
          return Container(
            height: 200,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue[400],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  snapshot.data!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
