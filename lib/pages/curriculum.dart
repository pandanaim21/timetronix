import 'package:flutter/material.dart';

class EditCurriculum extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Curriculum',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: Center(
        child: Text('Edit Curriculum Page'),
      ),
    );
  }
}
