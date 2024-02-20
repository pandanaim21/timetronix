import 'package:flutter/material.dart';
import 'package:timetronix/db/db_helper.dart';

class AddClassroom extends StatefulWidget {
  @override
  _AddClassroomState createState() => _AddClassroomState();
}

class _AddClassroomState extends State<AddClassroom> {
  final dbHelper = DatabaseHelper();
  final TextEditingController _controller = TextEditingController();
  List<String> classrooms = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Classroom',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter Classroom Number or Name',
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    addClassroom(_controller.text);
                  },
                  child: Text('Add Classroom'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: classrooms.length,
                itemBuilder: (BuildContext context, int roomNumber) {
                  return Card(
                    child: ListTile(
                      title: Text('${classrooms[roomNumber]}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          removeClassroom(classrooms[roomNumber]);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addClassroom(String roomNumber) async {
    if (roomNumber.isNotEmpty) {
      int id = await dbHelper.addClassroom(roomNumber);
      setState(() {
        classrooms.add(roomNumber);
        _controller.clear();
      });
    }
  }

  void removeClassroom(String roomNumber) async {
    await dbHelper.removeClassroom(roomNumber);
    setState(() {
      classrooms.remove(roomNumber);
    });
  }

  @override
  void initState() {
    super.initState();
    loadClassrooms();
  }

  void loadClassrooms() async {
    List<String> classroomNames = await dbHelper.getClassrooms();
    setState(() {
      classrooms = classroomNames;
    });
  }
}
