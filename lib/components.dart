import 'package:flutter/material.dart';

Widget customButton({
  required Color color,
  Alignment alignment = Alignment.center,
  double margin = 10.0,
  double padding = 20.0,
  double radius = 10.0,
  required Widget child,
}) {
  return Container(
    alignment: alignment,
    margin: EdgeInsets.all(margin),
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.all(Radius.circular(radius)),
    ),
    child: child,
  );
}

Widget customText({
  required String data,
  required Color color,
  double size = 12.0,
  FontWeight weight = FontWeight.w500,
  TextDirection direction = TextDirection.ltr,
  TextAlign textAlign = TextAlign.center,
}) {
  return Text(
    data,
    style: TextStyle(
      color: color,
      fontSize: size,
      fontWeight: weight,
    ),
    textDirection: direction,
    textAlign: textAlign,
  );
}
