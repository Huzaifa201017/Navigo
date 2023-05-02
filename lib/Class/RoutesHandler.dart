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
import 'package:collection/collection.dart';

class Node {
  int value;
  num distance;

  Node(this.value, this.distance);
}
class RoutesHandler {

  List<StopLocation> stations = [];
  DbHandler db = DbHandler();
  Map<int,StopLocation> locations = {};
  Map<int,List<Node>> graph = {};

  RoutesHandler() {}

  Future<void> populateStations() async{
    await readLocations();
    stations = locations.values.toList();
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
      this.locations[ row['Node'] ]!.nodeNum = row['Node'];
    });
    // PrintLocations();
    return;

  }

  Future<void> readGraph() async{

    List<Map> data = await db.getGraph();
    data.forEach((row) {
      if ( !this.graph.containsKey(row['Node']) ){
        this.graph[row['Node']] = [Node(row['NeighbourNode'], row['Distance'])];
      }else{
        this.graph[row['Node']]!.add(Node(row['NeighbourNode'], row['Distance']));
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

  // Future<double> getDistance(LatLng startLocation, LatLng endLocation) async {
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
  // Future<int> getClosestStation(StopLocation node) async{
  //   double minDist = double.infinity;
  //   int nodeNum = 0;
  //   List<int> keys = locations.keys.toList();
  //   for (var i = 0; i < keys.length; i++) {
  //     double dist = await getDistance(node.latts_longs, locations[keys[i]]!.latts_longs);
  //     if (dist < minDist) {
  //       minDist = dist;
  //       nodeNum = keys[i];
  //     }
  //   }
  //
  //   print(minDist);
  //   return  nodeNum;
  // }
  //
  // Future<void> Testfunc(StopLocation start) async{
  //   int closestStation = await getClosestStation(start);
  //   print(closestStation);
  //   if (locations[closestStation] != null) {
  //     print("Closest Stations is: " + locations[closestStation]!.name);
  //   }
  // }

  void Print(List<int> path, int currNode, List<StopLocation> result){
    if (path[currNode] == -2){
      print(locations[currNode]!.name);
      result.add(locations[currNode]!);
    }else{
      Print(path,path[currNode], result);

      print(locations[currNode]!.name);
      result.add(locations[currNode]!);
    }
  }

  int getClosestStation(StopLocation node) {
    double minDist = double.infinity;
    int nodeNum = 0;
    List<int> keys = locations.keys.toList();
    for (var i = 0; i < keys.length; i++) {
      double dist = Geolocator.distanceBetween(node.latts_longs.latitude, node.latts_longs.longitude,
          locations[keys[i]]!.latts_longs.latitude, locations[keys[i]]!.latts_longs.longitude);

      if (dist < minDist) {
        minDist = dist;
        nodeNum = keys[i];
      }
    }

    return  nodeNum;
  }

  Future<void> findMinPath(Map<int,List<Node>> graph, int s, int goal,List<StopLocation> result ) async{

    int compareByAgeDesc(Node a, Node b) => a.distance.compareTo(b.distance);
    HeapPriorityQueue<Node> q = HeapPriorityQueue(compareByAgeDesc);
    List<num> dist = List.filled(graph.length+1, 1.0/0.0);
    List<int> path = List.filled(graph.length+1, -1);

    dist[s] = 0;
    path[s] = -2;
    q.add(Node(s,0));
    while(! q.isEmpty) {

      Node u = q.first;
      q.removeFirst();
      if(u.value == goal){
        q.clear();
        break;
      }

      graph[u.value]!.forEach((node) {

        int v = node.value;
        num weight = node.distance;

        if (dist[u.value] + weight < dist[v] ){
          path[v] = u.value;
          dist[v] = dist[u.value] + weight;
          q.add(Node(v,dist[v]));
        }

      });
    }
    Print(path,goal, result);

  }

  Future<List<StopLocation>> getComputedPath(StopLocation start , StopLocation end , String criteria) async {
    // Testfunc(start);

    // get the graph if it is not already fetched
    if (graph.isEmpty){
      print("Yes");
      await readGraph();
    }

    List<StopLocation> result = [];
    // if graph is not empty(empty may be bcz of some synchronization issues) , then apply the algo.
    if(! graph.isEmpty){
      //Get closest possible station from start and end
      int startStationIndex = getClosestStation(start);
      int endStationIndex = getClosestStation(end);

      result.add(start);
      findMinPath(graph,startStationIndex,endStationIndex,result);
      //result.addAll([locations[21]!, locations[20]!]);
      result.add(end);


    }
    return result;

  }

  Future<List<StopLocation>> getNextPossiblePath(StopLocation start , StopLocation end,String criteria,int edgeStart , int edgeEnd){
    graph[edgeStart]!.remove(edgeEnd);

    // remove the edge, which the user clicked to remove.
    for(int i = 0 ; i < graph[edgeStart]!.length ; i++){
      if (graph[edgeStart]![i].value == edgeEnd){
        graph[edgeStart]!.removeAt(i);
        break;
      }
    }
    for(int i = 0 ; i < graph[edgeEnd]!.length ; i++){
      if (graph[edgeEnd]![i].value == edgeStart){
        graph[edgeEnd]!.removeAt(i);
        break;
      }
    }

    print(edgeStart.toString() + " "+ edgeEnd.toString());
    return getComputedPath(start,end,criteria);
  }
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

  void PrintGraph() {
    List<int> keys = graph.keys.toList();
    print(keys[0]);
    for(int i = 0 ;  i < graph[keys[0]]!.length ; i++){
      print(graph[keys[0]]![i].toString() + " ");
    }
    // graph.forEach((key, value) {
    //   print(key.toString() + " " + locations[key]!.name);
    //   print("----------");
    //   value.forEach((loc) {
    //     print(loc.toString() + " " + locations[loc]!.name);
    //   });
    //   print("----------\n");
    //
    //
    // });
  }
}