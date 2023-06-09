import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:navigo/LoginPage.dart';
import 'firebase_options.dart';
import 'package:navigo/SplashScreen.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FlutterApp());
}

class FlutterApp extends StatelessWidget {
  const FlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flutter App",
      theme: ThemeData(primarySwatch: Colors.red),
      // home: LoginPage(),
      home: SplashScreen(),
    );
  }
}
