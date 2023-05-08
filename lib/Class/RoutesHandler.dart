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
  bool isCalculatingNextPath = false;

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

  void addEdge(int nodeNum, Node node) {

    if ( !this.graph.containsKey(nodeNum) ) {
      this.graph[nodeNum] = [node];
    }else{
      this.graph[nodeNum]!.add(node);
    }

  }

  void findClosestStation(StopLocation terminalLocation) {

    num minDist_Metro = double.infinity;
    num minDist_Speedo = double.infinity;
    int nodeNum_Metro = 0,nodeNum_Speedo = 0 ;

    List<int> keys = locations.keys.toList();

    for (var i = 0; i < keys.length; i++) {

      if (locations[keys[i]]!.isMetro) {

        double dist1 = Geolocator.distanceBetween(terminalLocation.latts_longs.latitude, terminalLocation.latts_longs.longitude,
            locations[keys[i]]!.latts_longs.latitude, locations[keys[i]]!.latts_longs.longitude);

        if (dist1 < minDist_Metro) {
          minDist_Metro = dist1;
          nodeNum_Metro = keys[i];
        }

      }else if(locations[keys[i]]!.isSpeedo){

        double dist2 = Geolocator.distanceBetween(terminalLocation.latts_longs.latitude, terminalLocation.latts_longs.longitude,
            locations[keys[i]]!.latts_longs.latitude, locations[keys[i]]!.latts_longs.longitude);

        if (dist2 < minDist_Speedo) {
          minDist_Speedo = dist2;
          nodeNum_Speedo = keys[i];
        }

      }

    }

    terminalLocation.nodeNum = this.locations.length+1;

    this.locations[terminalLocation.nodeNum] = terminalLocation;
    //print(this.locations.length);

    if(terminalLocation.isStartingPoint){

      if (minDist_Speedo < minDist_Metro){
        addEdge(terminalLocation.nodeNum,Node(nodeNum_Speedo, minDist_Speedo));
        print("Yes");
      }else{
        addEdge(terminalLocation.nodeNum,Node(nodeNum_Metro, minDist_Metro));
      }


    }else if(terminalLocation.isDestination){

      if (minDist_Speedo < minDist_Metro) {
        addEdge(nodeNum_Speedo,Node(terminalLocation.nodeNum,minDist_Speedo));
      }else{
        addEdge(nodeNum_Metro,Node(terminalLocation.nodeNum,minDist_Metro));
      }
    }

  }

  Future<void> getRouteWithShortestTotalDistance(Map<int,List<Node>> graph, int s, int goal,List<StopLocation> result ) async{

    int compareByAgeDesc(Node a, Node b) => a.distance.compareTo(b.distance);
    HeapPriorityQueue<Node> q = HeapPriorityQueue(compareByAgeDesc);
    List<num> dist = List.filled(locations.length+1, 1.0/0.0);
    List<int> path = List.filled(locations.length+1, -1);

    dist[s] = 0;
    path[s] = -2;
    q.add(Node(s,0));

    while(! q.isEmpty) {

      Node u = q.first;
      q.removeFirst();

      if(u.value == goal){

        print(dist[u.value]);
        q.clear();
        break;

      }

      for(int i=0 ; i < graph[u.value]!.length ; i++){

        Node node = graph[u.value]![i];

        int v = node.value;
        num weight = node.distance;


        if( !( (this.locations[u.value]!.isMetro && this.locations[v]!.isMetro) ||
               (this.locations[u.value]!.route_num == this.locations[v]!.route_num) ) ){

          // if (weight > 1000){
          //   continue;
          // }
          // if (this.locations[u.value]!.name == "Nadeem Chowk" && this.locations[v]!.name == "Model Town"){
          //   print("This edge weight is :"+ weight.toString());
          // }
          if (!this.locations[u.value]!.isStartingPoint){
            weight *= 3.1;
          }


        }


        if (dist[u.value] + weight < dist[v] ){
          path[v] = u.value;
          dist[v] = dist[u.value] + weight;

          q.add(Node(v,dist[v]));
        }
      }

    }
    Print(path,goal, result);

  }

  Future<void> getRouteWithShortestWalkingDistance(Map<int,List<Node>> graph, int s, int goal,List<StopLocation> result ) async{

    int compareByAgeDesc(Node a, Node b) => a.distance.compareTo(b.distance);
    HeapPriorityQueue<Node> q = HeapPriorityQueue(compareByAgeDesc);
    List<num> dist = List.filled(locations.length+1, 1.0/0.0);
    List<int> path = List.filled(locations.length+1, -1);

    dist[s] = 0;
    path[s] = -2;
    q.add(Node(s,0));

    while(! q.isEmpty) {

      Node u = q.first;
      q.removeFirst();

      if(u.value == goal){

        print("Reached at Line 246");
        print("Distance: " + dist[u.value].toString());
        Print(path,goal, result);
        q.clear();
        break;

      }

      for(int i=0 ; i < graph[u.value]!.length ; i++){

        Node node = graph[u.value]![i];

        int v = node.value;
        num weight = 0;


        if( !( (this.locations[u.value]!.isMetro && this.locations[v]!.isMetro) ||
               (this.locations[u.value]!.route_num == this.locations[v]!.route_num) ||
                this.locations[u.value]!.isStartingPoint || this.locations[u.value]!.isDestination ) ) {

          weight = node.distance;
        }
        if (dist[u.value] + weight < dist[v] ){
          path[v] = u.value;
          dist[v] = dist[u.value] + weight;
          q.add(Node(v,dist[v]));
        }

      }

    }

  }

  Future<void> getRouteWithMinimumStationSwitching(Map<int,List<Node>> graph, int s, int goal,List<StopLocation> result ) async{

    int compareByAgeDesc(Node a, Node b) => a.distance.compareTo(b.distance);
    HeapPriorityQueue<Node> q = HeapPriorityQueue(compareByAgeDesc);
    List<num> dist = List.filled(locations.length+1, 1.0/0.0);
    List<int> path = List.filled(locations.length+1, -1);

    dist[s] = 0;
    path[s] = -2;
    q.add(Node(s,0));

    while(! q.isEmpty) {

      Node u = q.first;
      q.removeFirst();

      if(u.value == goal){

        print("Reached at Line 296");
        Print(path,goal, result);
        q.clear();
        break;

      }

      for(int i=0 ; i < graph[u.value]!.length ; i++){

        Node node = graph[u.value]![i];

        int v = node.value;
        num weight = 0;


        if( !( (this.locations[u.value]!.isMetro && this.locations[v]!.isMetro) ||
            (this.locations[u.value]!.route_num == this.locations[v]!.route_num)) ) {

          if (node.distance > 1000){
            continue;
          }

          weight = 1;
        }
        if (dist[u.value] + weight < dist[v] ) {
          path[v] = u.value;
          dist[v] = dist[u.value] + weight;
          q.add( Node(v,dist[v]) );
        }

      }

    }
  }
  Future<List<StopLocation>> getComputedPath(StopLocation start , StopLocation end , String criteria) async {

    // get the graph if it is not already fetched
    if (graph.isEmpty) {
      await readGraph();
    }

    List<StopLocation> result = [];
    // if graph is not empty(empty may be bcz of some synchronization issues) , then apply the algo.
    if(! graph.isEmpty) {
      //Get closest possible station from start and end
      if (! isCalculatingNextPath) {
        findClosestStation(start);
        findClosestStation(end);
      }
      //print(end.nodeNum);
      //getRouteWithShortestTotalDistance(graph,start.nodeNum,end.nodeNum,result);
      //print("Reached at Line 296");
      //getRouteWithShortestWalkingDistance(graph,start.nodeNum,end.nodeNum,result);

      if (criteria == "Minimum Total Distance"){

        print("Criteria: Minimum Total Distance");
        getRouteWithShortestTotalDistance(graph,start.nodeNum,end.nodeNum,result);

      }else if(criteria == "Minimum Walking Distance"){
        print("Criteria: Minimum Walking Distance");
        getRouteWithShortestWalkingDistance(graph,start.nodeNum,end.nodeNum,result);
      }else{
        print("Criteria: Minimum Station Switching");
        getRouteWithMinimumStationSwitching(graph,start.nodeNum,end.nodeNum,result);
      }
    }
    return result;

  }

  Future<List<StopLocation>> getNextPossiblePath(StopLocation start , StopLocation end,String criteria,int edgeStart , int edgeEnd) async{
    isCalculatingNextPath = true;
    // remove the edge, which the user clicked to remove.
    for(int i = 0 ; i < graph[edgeStart]!.length ; i++){
      if (graph[edgeStart]![i].value == edgeEnd){
        graph[edgeStart]!.removeAt(i);
        print("Removed" );
        break;
      }
    }
    for(int i = 0 ; i < graph[edgeEnd]!.length ; i++){
      if (graph[edgeEnd]![i].value == edgeStart){
        graph[edgeEnd]!.removeAt(i);
        print("Removed" );
        break;
      }
    }

    print("Edge Removed:" + edgeStart.toString() + " "+ edgeEnd.toString());
    print("Starting and Destination: " + start.isStartingPoint.toString() + end.isDestination.toString());
    List<StopLocation> result =  await getComputedPath(start,end,criteria);
    print("New result length: " + result.length.toString() );
    return result;
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