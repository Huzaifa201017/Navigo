import 'package:flutter/material.dart';
import 'package:navigo/HomePage.dart';

void main() {
  runApp(const FlutterApp());
}

class FlutterApp extends StatelessWidget {
  const FlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flutter Ap",
      theme: ThemeData(primarySwatch: Colors.red),
      home: HomePage(),
    );
  }
}
