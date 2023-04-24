import 'package:navigo/Class/Location.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

class RoutesHandler {

  List<Location> stations = [];
  // TODO: May be we will have to change this as Map<String,List<Location>> ..
  Map<String,Location> locations = {};
  Map<String,List<String>> graph = {};

  RoutesHandler() {
    _populateStations();
    readLocations();
  }

  void _populateStations() {
    stations.add(Location(
        LatLng(31.506621004611624, 74.37830243389809), 'Nadeem Chowk', false,
        true));
    stations.add(Location(
        LatLng(31.506238484612883, 74.38494682631604), 'RA-Bazar', false,
        true));
  }

  bool parseBool(String boolString){
    if(boolString == "true"){
      return true;
    }
    return false;
  }

  Future<String> loadAsset(String filename) async {
    return await rootBundle.loadString('assets/Modals/${filename}');
  }

  Future<void> readLocations() async{

    String data = await loadAsset("Locations.txt");


    List<String> lines = data.split('\n').toList();

    for (int i = 1 ; i < lines.length-1 ; i++) {

        var list = lines[i].split(' ');
        double latts = double.parse(list[0].toString());
        double longs = double.parse(list[1]);
        String name = list[2];
        bool isMetro = parseBool(list[3]);
        bool isSpeedo = parseBool(list[4]);
        bool isTrain = parseBool(list[5]);

        Location loc = Location(LatLng(latts, longs), name,isMetro,isSpeedo,isTrain);
        for (int i = 6 ; i < list.length-1 ; i++){
          loc.route_num.add(int.parse(list[i]));
        }
        this.locations[name] = loc;

    }
    return;

  }

  Future<void> readAdjacencyList() async{
    String data = await loadAsset("AdjacencyList.txt");

    List<String> lines = data.split('\n').toList();

    List<String> keys = locations.keys.toList() ;

    for (int i=0 ; i < keys.length ; i++) {
      List<String> list = lines[i].split(' ').toList();

      graph[keys[i]] = list;
    }

    this.Print();

  }

  List<LatLng> getStationCoordinates(List<Location> stations) {
    List<LatLng> lats_langs = [];
    for (int i = 0; i < stations.length; i++) {
      lats_langs.add(stations[i].latts_longs);
    }
    return lats_langs;
  }

  List<Location> getComputedPath() {
    //TODO: There would be some paramters
    List<Location> result = [
      Location(
          LatLng(31.51214443738609, 74.37939589382803),
          'Starting Point',
          false,
          false,
          false,
          false,
          false,
          true)
    ];
    result.addAll(stations);
    result.add(Location(
        LatLng(31.50018037093097, 74.39487289494411),
        'Destination Point',
        false,
        false,
        false,
        false,
        true));

    return result;
  }

  void getDistance(LatLng startLocation, LatLng endLocation) async {
    // startLocation = LatLng(31.5031007440085, 74.3492406466929);
    // endLocation = LatLng(31.482608024865634, 74.30323539847984);

    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    String googleAPiKey = "AIzaSyApvWQgBKFUgwcJ91suH3wGogD4WhAa6WM";

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(startLocation.latitude, startLocation.longitude),
      PointLatLng(endLocation.latitude, endLocation.longitude),
      travelMode: TravelMode.walking,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }

    //polyline Coordinates is the List of longitude and latitude.
    double totalDistance = 0;
    for (var i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude);

    }
    print(totalDistance / 1000);
  }

  void Print(){
    graph.forEach((key, value) {
      locations[key]?.Print();
      print("----------");
      value.forEach((loc) {
        locations[loc]?.Print();
      });
      print("----------\n");

    });
  }
}