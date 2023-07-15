import 'package:flutter/material.dart';
import 'package:scan_visiting_card/pages/details.dart';
import 'package:scan_visiting_card/pages/user_details.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/userdetails',
      routes: {
        '/details' : (context) => const Details(),
      },
      debugShowCheckedModeBanner: false,
      title: "Scan-Visiting-Card",
      home: const UserDetails(),
    );
  }
}