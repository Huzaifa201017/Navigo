import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:navigo/LoginPage.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
