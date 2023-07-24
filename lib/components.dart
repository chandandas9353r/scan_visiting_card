import 'package:flutter/material.dart';

class CustomComponents {
  Widget customButton({
    required  color,
    required Widget child,
  }) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),
      child: child,
    );
  }

  Widget customText({
    String data = '',
    double size = 12.0,
    TextDirection direction = TextDirection.ltr,
  }) {
    return Text(
      data,
      style: TextStyle(
        color: Colors.white,
        fontSize: size,
        fontWeight: FontWeight.w400,
      ),
      textDirection: direction,
      textAlign: TextAlign.center,
    );
  }
}
