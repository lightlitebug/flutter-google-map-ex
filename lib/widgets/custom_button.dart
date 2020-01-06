import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final Function onPressed;

  CustomButton({this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: Colors.indigo,
      textColor: Colors.white,
      minWidth: 300,
      height: 45,
      child: Text(
        title,
        style: TextStyle(fontSize: 18),
      ),
      onPressed: onPressed,
    );
  }
}
