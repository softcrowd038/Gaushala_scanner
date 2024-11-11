import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Color color;
  final String buttonText;

  const CustomButton(
      {super.key, required this.color, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.018),
      child: Container(
        height: orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height * 0.06
            : MediaQuery.of(context).size.height * 0.12,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: color,
          borderRadius:
              BorderRadius.circular(MediaQuery.of(context).size.height * 0.12),
        ),
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.008),
          child: Center(
            child: Text(
              buttonText,
              style: TextStyle(
                fontSize: orientation == Orientation.portrait
                    ? MediaQuery.of(context).size.height * 0.020
                    : MediaQuery.of(context).size.height * 0.030,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
