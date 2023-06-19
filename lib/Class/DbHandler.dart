import 'dart:io';
import 'dart:async';
import 'package:navigo/Class/Location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:navigo/Toast.dart';

class DbHandler {
  var db = FirebaseFirestore.instance;

  Future<void> loadSavedPlaceToDb(String name,  String id, LatLng location) async{
    List<StopLocation> list = await fetchSavedPlaceFromDb(id);
    for (int i = 0 ; i < list.length ; i++){
      if (list[i].latts_longs == location){
        Message().show("Already Saved!");
        return ;
      }
    }

    db.collection('Users').doc(id).set(
        {
          'savedPlaces': FieldValue.arrayUnion(
            [
                {
                  'name': name,
                  'lattitude': location.latitude,
                  'longitude': location.longitude
                },
            ]
          )

        }

    ).catchError((error) {
      // If the document doesn't exist, create a new one and add the array.
      if (error.code == 'not-found') {
        db.collection('Users').doc(id).set({
          'savedPlaces': [
            {
              'name': name,
              'lattitude': location.latitude,
              'longitude': location.longitude
            }
          ]
        });
      }
    });
    Message().show("Saved Successfully!");
  }
  Future<List<StopLocation>> fetchSavedPlaceFromDb(String id) async {

    final docRef = db.collection("Users").doc(id);
    List<StopLocation> result = [];

    try {
      DocumentSnapshot doc = await docRef.get();
      final data = doc.data();

      if (data != null) {
        final dataMap = data as Map<String, dynamic>;
        var list = dataMap['savedPlaces'] as List<dynamic>;
        list.forEach((place) {
          result.add(StopLocation(LatLng(place['lattitude'], place['longitude'] ), place['name']));
        });

      } else {
        print("No Data Found!");
      }
    } catch(e) {
      print("Error getting document: $e");
    }
    return result;
  }

  Future<void> copyDatabase() async {
    // Get the path to the app's database directory
    String databasesPath = await getDatabasesPath();

    // Create the directory if it doesn't already exist
    await Directory(databasesPath).create(recursive: true);

    // Construct the path to the database file
    String dbPath = join(databasesPath, 'Routes.db');

    // Check if the database file already exists
    bool exists = await databaseExists(dbPath);

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

  Future<List<String>> getStationsForSpeedoRoute(int routeNum) async {
    var db = await this.open_Database();
    List<String> stationsList = [];
    List<Map> list = await db.rawQuery('select * from "Locations" where routenum = $routeNum');
    list.forEach((row) {
      stationsList.add(row['LocationName']);
    });

    db.close();
    return stationsList;
  }

  Future<List<Map>> getMetro() async {
    List<Map> getMetroRoutes = [];
    var db = await this.open_Database();
    getMetroRoutes =
    await db.rawQuery('select * from Locations where routenum = "-1"');
    db.close();
    return getMetroRoutes;
  }




}