import 'package:flutter/material.dart';

class AddFaculty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Faculty',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: Center(
        child: Text('Add Faculty Page'),
      ),
    );
  }
}
