import 'dart:io';
import 'dart:async';
import 'package:navigo/Class/Location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';

class DbHandler {
  var db = FirebaseFirestore.instance;
  Future<void> loadSavedPlaceToDb(String name,  String id) async{

  }
  // Future<List<Location>> fetchSavedPlaceFromDb(String id) async{
  //   return null;
  // }
  Future<void> copyDatabase() async {
    // Get the path to the app's database directory
    String databasesPath = await getDatabasesPath();

    // Create the directory if it doesn't already exist
    await Directory(databasesPath).create(recursive: true);

    // Construct the path to the database file
    String dbPath = join(databasesPath, 'Routes.db');

    // Check if the database file already exists
    bool exists = await databaseExists(dbPath);
    print(dbPath);

    // Delete the database
    // await deleteDatabase(dbPath);

    if (!exists) {
      // If the database doesn't exist, copy it from the assets folder
      ByteData data = await rootBundle.load('assets/Modals/sqlite.db');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes);
    }
  }

  Future<Database> open_Database() async {

    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'Routes.db');
    // Open the database
    return openDatabase(path);

  }

  Future<List<Map>> getGraph() async {
    var db = await this.open_Database();
    List<Map> list = await db.rawQuery('select * from Graph');
    db.close();
    return list;
  }
  Future<List<Map>> getLocations() async {
    var db = await this.open_Database();
    List<Map> list = await db.rawQuery('select * from "Locations"');
    db.close();
    return list;
  }

  // import 'package:sqflite/sqflite.dart';
  // import 'package:path/path.dart';

  // Future<Database> openDatabase() async {
  //   String databasesPath = await getDatabasesPath();
  //   String path = join(databasesPath, 'my_database.db');
  //
  //   // Copy the database from assets if it doesn't exist
  //   ByteData data = await rootBundle.load(join("assets", "my_database.db"));
  //   List<int> bytes =
  //   data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  //   await File(path).writeAsBytes(bytes);
  //
  //   // Open the database
  //   return openDatabase(path);
  // }
  //
  // Future<List<Map<String, dynamic>>> getItems() async {
  //   Database db = await openDatabase();
  //   return db.query('my_table');
  // }


}