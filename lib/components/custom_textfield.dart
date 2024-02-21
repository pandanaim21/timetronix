import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final Color borderColor;
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextAlign textAlign;
  final EdgeInsets symmetricPadding;
  final EdgeInsets leftPadding;

  const CustomTextField({
    Key? key,
    required this.borderColor,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.textAlign = TextAlign.start,
    this.symmetricPadding = const EdgeInsets.symmetric(horizontal: 0.0),
    this.leftPadding = const EdgeInsets.only(left: 0.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: symmetricPadding,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: leftPadding,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            textAlign: textAlign,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
