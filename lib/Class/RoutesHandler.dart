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
import 'package:navigo/Class/DbHandler.dart';

class RoutesHandler {

  List<StopLocation> stations = [];
  DbHandler db = DbHandler();
  // TODO: May be we will have to change this as Map<String,List<StopLocation>> ..
  Map<int,StopLocation> locations = {};
  Map<int,List<int>> graph = {};

  RoutesHandler() {
    _populateStations();
    readLocations();
    readGraph();
  }

  void _populateStations() {
    stations.add(StopLocation(
        LatLng(31.506621004611624, 74.37830243389809), 'Nadeem Chowk', false,
        true));
    stations.add(StopLocation(
        LatLng(31.506238484612883, 74.38494682631604), 'RA-Bazar', false,
        true));
  }

  void parseStringToBool(String boolString, StopLocation loc){
    if(boolString == "M") {
      loc.isMetro = true;
    }else if(boolString == "S"){
      loc.isSpeedo = true;
    }else{
      loc.isTrain = true;
    }
  }

  Future<void> readLocations() async{

    List<Map> data = await db.getLocations();
    data.forEach((row) {
      this.locations[row['Node']] = StopLocation(LatLng(row['Lattitude'], row['Longitude']), row['LocationName']);
      parseStringToBool(row['StationType'], this.locations[ row['Node'] ]! );
      this.locations[ row['Node'] ]!.route_num = row['RouteNum'];
    });
    // PrintLocations();
    return;

  }
  Future<void> readGraph() async{

    List<Map> data = await db.getGraph();
    data.forEach((row) {
      if ( !this.graph.containsKey(row['Node']) ){
        this.graph[row['Node']] = [row['NeighbourNode']];
      }else{
        this.graph[row['Node']]!.add(row['NeighbourNode']);
      }
    });
    //PrintGraph();
    return;

  }


  List<LatLng> getStationCoordinates(List<StopLocation> stations) {
    List<LatLng> lats_langs = [];
    for (int i = 0; i < stations.length; i++) {
      lats_langs.add(stations[i].latts_longs);
    }
    return lats_langs;
  }

  List<StopLocation> getComputedPath() {
    //TODO: There would be some paramters
    List<StopLocation> result = [
      StopLocation(
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
    result.add(StopLocation(
        LatLng(31.50018037093097, 74.39487289494411),
        'Destination Point',
        false,
        false,
        false,
        false,
        true));

    return result;
  }

  // Future<double> getDistance(LatLng startLocation, LatLng endLocation) async {
  //   // startLocation = LatLng(31.5031007440085, 74.3492406466929);
  //   // endLocation = LatLng(31.482608024865634, 74.30323539847984);
  //
  //   List<LatLng> polylineCoordinates = [];
  //   PolylinePoints polylinePoints = PolylinePoints();
  //   String googleAPiKey = "AIzaSyApvWQgBKFUgwcJ91suH3wGogD4WhAa6WM";
  //
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //     googleAPiKey,
  //     PointLatLng(startLocation.latitude, startLocation.longitude),
  //     PointLatLng(endLocation.latitude, endLocation.longitude),
  //     travelMode: TravelMode.walking,
  //   );
  //
  //   if (result.points.isNotEmpty) {
  //     result.points.forEach((PointLatLng point) {
  //       polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //     });
  //   } else {
  //     print(result.errorMessage);
  //   }
  //
  //   //polyline Coordinates is the List of longitude and latitude.
  //   double totalDistance = 0;
  //   for (var i = 0; i < polylineCoordinates.length - 1; i++) {
  //     totalDistance += Geolocator.distanceBetween(
  //         polylineCoordinates[i].latitude,
  //         polylineCoordinates[i].longitude,
  //         polylineCoordinates[i + 1].latitude,
  //         polylineCoordinates[i + 1].longitude);
  //
  //   }
  //
  //   return totalDistance;
  // }
  //

  void PrintLocations(){
    locations.forEach((key, value) {
      locations[key]?.Print();
      // print("----------");
      // value.forEach((loc) {
      //   locations[loc]?.Print();
      // });
      // print("----------\n");

    });

  }
  void PrintGraph(){
    graph.forEach((key, value) {
      print(key.toString() + " " + locations[key]!.name);
      print("----------");
      value.forEach((loc) {
        print(loc.toString() + " " + locations[loc]!.name);
      });
      print("----------\n");

    });
  }
}