import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final Color borderColor;
  final double paddingSize;
  final String hintText;

  const CustomTextField({
    Key? key,
    this.borderColor = Colors.blue,
    this.paddingSize = 16.0,
    this.hintText = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(paddingSize),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
