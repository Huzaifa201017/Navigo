import 'dart:io';
import 'dart:async';
import 'package:navigo/Class/Location.dart';
import 'package:cloud_firestore/cloud_firestore.dart'

class DbHandler {
  var db = FirebaseFirestore.instance;

  Future<void> loadSavedPlaceToDb(String name,  String id) async{

  }
  Future<List<Location>> fetchSavedPlaceFromDb(String id) async{

  }
}