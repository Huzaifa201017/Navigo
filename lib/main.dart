import 'package:flutter/material.dart';
import 'package:navigo/LoginPage.dart' ;
import 'package:navigo/StartUpPage.dart';

import 'LoginPage.dart';

void main() {
  runApp(const FlutterApp());
}

class FlutterApp extends StatelessWidget {
  const FlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Ap",
      theme: ThemeData(primarySwatch: Colors.red),
      home:  LoginPage(),
    );
  }
}
