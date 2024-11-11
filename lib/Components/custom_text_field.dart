// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  String hintText = "";
  String? Function(String?) customValidator;
  TextEditingController fieldController = TextEditingController();
  TextInputType type;
  Icon icon;

  CustomTextField(
      {super.key,
      required this.hintText,
      required this.customValidator,
      required this.fieldController,
      required this.type,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.018),
      child: TextFormField(
        style: TextStyle(
            color: const Color.fromARGB(255, 0, 0, 0),
            fontSize: MediaQuery.of(context).size.height * 0.016),
        controller: fieldController,
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: MediaQuery.of(context).size.height * 0.016,
                fontWeight: FontWeight.w100),
            filled: false,
            prefixIcon: icon,
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide:
                  BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 1),
            ),
            errorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 1))),
        keyboardType: type,
        validator: customValidator,
      ),
    );
  }
}
