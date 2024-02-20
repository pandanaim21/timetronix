import 'package:flutter/material.dart';

class EditSchedule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Schedule',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: Center(
        child: Text('Edit Schedule Page'),
      ),
    );
  }
}
