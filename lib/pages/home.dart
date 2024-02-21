import 'package:flutter/material.dart';
import 'package:timetronix/pages/classroom.dart';
import 'package:timetronix/pages/faculty.dart';
import 'package:timetronix/pages/curriculum.dart';
import 'package:timetronix/pages/schedule.dart';


class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
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
              child: Text('Sidebar'),
              decoration: BoxDecoration(color: Colors.blue[800]),
            ),
            ListTile(
              leading: Icon(Icons.add_box),
              title: Text('Classroom'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddClassroom()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Curriculum'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCurriculum()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Faculty'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddFaculty()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.schedule),
              title: Text('Schedule'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditSchedule()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Main Page'),
      ),
    );
  }
}
