import 'package:flutter/material.dart';

class CustomComponents {
  Widget customButton(String text) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.all(10.0),
      decoration: const BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 30,
        ),
      ),
    );
  }

  Widget customText({
    String key = '',
    double size = 12.0,
    FontWeight weight = FontWeight.w400,
    TextDirection direction = TextDirection.ltr,
  }) {
    return Text(
      key,
      style: TextStyle(
        color: Colors.white,
        fontSize: size,
        fontWeight: weight,
      ),
      textDirection: direction,
    );
  }
}
