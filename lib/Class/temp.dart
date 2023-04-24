import 'dart:io';
import 'dart:convert';
import 'dart:async';

const int speedo_routes = 2;
class Location1 {

  double latts;
  double longs;
  String name;
  bool isMetro , isSpeedo , isTrain, isYourLocation, isDestination, isStartingPoint;
  Set<int> route_num = {};
  double distance=0.0;

  Location1(this.latts,this.longs ,this.name,[this.isMetro=false , this.isSpeedo=false , this.isTrain=false, this.isYourLocation=false, this.isDestination=false, this.isStartingPoint=false]);

  void setDistance(double dist){
    this.distance = dist;
  }
  void Print(){
    String temp  = this.name+ " "+ this.latts.toString() +" "+ this.longs.toString()+" "+this.isMetro.toString() + " "+ this.isSpeedo.toString()+ " "+ this.isTrain.toString();
    if (this.route_num.length != 0){
      this.route_num.forEach((num) {
        temp += " " + num.toString();
      });
    }
    print(temp);
  }

}

bool isLocationAlreadyExist(Location1 loc, List<String>? list){
  if (list == null) {
    return false;
  }
  for(int i = 0 ; i < list.length ; i++){
    if (list[i] == loc.name){
      return true;
    }
  }
  return false;
}

Future<void> populateMetroStations(Map<String, List<String>> graph, Map<String,Location1> locations) async{
  List<Location1> metroLocs = [];
  await readLocationsFromFile('./lib/RoutesFolder/Metro.txt',metroLocs);

  // First Station
  metroLocs[0].isMetro = true;
  metroLocs[1].isMetro = true;
  graph[metroLocs[0].name] = [metroLocs[1].name];
  locations[metroLocs[0].name] = metroLocs[0];

  // Middle Stations
  for(int i = 1; i < metroLocs.length-1 ; i++){
    metroLocs[i+1].isMetro = true;
    graph[metroLocs[i].name] = [metroLocs[i-1].name, metroLocs[i+1].name];
    locations[metroLocs[i].name] = metroLocs[i];
  }

  // Last Station
  graph[metroLocs[metroLocs.length-1].name] = [metroLocs[metroLocs.length-2].name];
  locations[metroLocs[metroLocs.length-1].name] = metroLocs[metroLocs.length-1];


}

Future<void> populateSpeedoStations(Map<String, List<String>> graph,Map<String,Location1> locations) async{

  for (int i=1 ; i <= speedo_routes ; i++){

    List<Location1> trainLocs = [];
    await readLocationsFromFile('./lib/RoutesFolder/Speedo_$i.txt',trainLocs);

    // First Station
    trainLocs[0].isSpeedo = true;
    trainLocs[0].route_num.add(i);
    trainLocs[1].isSpeedo = true;
    trainLocs[1].route_num.add(i);

    if(graph.containsKey(trainLocs[0].name)) {
      locations[trainLocs[0].name]!.isSpeedo = true;
      locations[trainLocs[0].name]!.route_num.add(i);

      if(! isLocationAlreadyExist(trainLocs[1],graph[trainLocs[0].name]) ){
        graph[trainLocs[0].name]!.add(trainLocs[1].name);
      }

    }else{
      graph[trainLocs[0].name] = [trainLocs[1].name];
      locations[trainLocs[0].name] = trainLocs[0];
    }

    // Middle Stations
    for(int j = 1; j < trainLocs.length-1 ; j++){

      trainLocs[j+1].isSpeedo = true;
      trainLocs[j+1].route_num.add(i);
      if(graph.containsKey(trainLocs[j].name)) {
        locations[trainLocs[j].name]!.isSpeedo = true;
        locations[trainLocs[j].name]!.route_num.add(i);

        if(! isLocationAlreadyExist(trainLocs[j-1],graph[trainLocs[j].name]) ){
          graph[trainLocs[j].name]!.add(trainLocs[j-1].name);
        }

        if(! isLocationAlreadyExist(trainLocs[j+1],graph[trainLocs[j].name]) ){
          graph[trainLocs[j].name]!.add(trainLocs[j+1].name);
        }

      }else{
        graph[trainLocs[j].name] = [trainLocs[j-1].name, trainLocs[j+1].name];
        locations[trainLocs[j].name] = trainLocs[j];
      }

    }

    // Last Station
    if(graph.containsKey(trainLocs[trainLocs.length-1].name)) {
      locations[trainLocs[trainLocs.length-1].name]!.isSpeedo = true;
      locations[trainLocs[trainLocs.length-1].name]!.route_num.add(i);

      if(! isLocationAlreadyExist(trainLocs[trainLocs.length-2],graph[trainLocs[trainLocs.length-1].name]) ){
        graph[trainLocs[trainLocs.length-1].name]!.add(trainLocs[trainLocs.length-2].name);
      }

    }else{
      graph[trainLocs[trainLocs.length-1].name] = [trainLocs[trainLocs.length-2].name];
      locations[trainLocs[trainLocs.length-1].name] = trainLocs[trainLocs.length-1];
    }
  }
}

Future<void> populateTrainStations(Map<String, List<String>> graph,Map<String,Location1> locations) async{

  List<Location1> trainLocs = [];
  await readLocationsFromFile('./lib/RoutesFolder/Train.txt',trainLocs);

  // First Station
  trainLocs[0].isTrain = true;
  trainLocs[1].isTrain = true;
  if(graph.containsKey(trainLocs[0].name)) {
    locations[trainLocs[0].name]!.isTrain = true;

    if(! isLocationAlreadyExist(trainLocs[1],graph[trainLocs[0].name]) ){
      graph[trainLocs[0].name]!.add(trainLocs[1].name);
    }

  }else{
    graph[trainLocs[0].name] = [trainLocs[1].name];
    locations[trainLocs[0].name] = trainLocs[0];
  }

  // Middle Stations
  for(int i = 1; i < trainLocs.length-1 ; i++){

    trainLocs[i+1].isTrain = true;
    if(graph.containsKey(trainLocs[i].name)) {
      locations[trainLocs[i].name]!.isTrain = true;


      if(! isLocationAlreadyExist(trainLocs[i-1],graph[trainLocs[i].name]) ){
        graph[trainLocs[i].name]!.add(trainLocs[i-1].name);
      }

      if(! isLocationAlreadyExist(trainLocs[i+1],graph[trainLocs[i].name]) ){
        graph[trainLocs[i].name]!.add(trainLocs[i+1].name);
      }

    }else{
      graph[trainLocs[i].name] = [trainLocs[i-1].name, trainLocs[i+1].name];
      locations[trainLocs[i].name] = trainLocs[i];
    }

  }

  // Last Station
  if(graph.containsKey(trainLocs[trainLocs.length-1].name)) {
    locations[trainLocs[trainLocs.length-1].name]!.isTrain = true;

    if(! isLocationAlreadyExist(trainLocs[trainLocs.length-2],graph[trainLocs[trainLocs.length-1].name]) ){
      graph[trainLocs[trainLocs.length-1].name]!.add(trainLocs[trainLocs.length-2].name);
    }

  }else{
    graph[trainLocs[trainLocs.length-1].name] = [trainLocs[trainLocs.length-2].name];
    locations[trainLocs[trainLocs.length-1].name] = trainLocs[trainLocs.length-1];
  }

}

Future<void> readLocationsFromFile(String fileName,List<Location1> locs) async{
  // './lib/RoutesFolder/Metro.txt'

  File file = File(fileName);
  List<String> lines =  await file.readAsLines();

  lines.forEach((line) {
    var list = line.split(' ');
    String name = list[0];
    double latts = double.parse(list[1]);
    double longs = double.parse(list[2]);
    locs.add(Location1(latts, longs, name));
  });


}

Future<void> makeGraphCompletelyConnected(Map<String, List<String>> graph,Map<String,Location1> locations) async{

  List<String> keys = locations.keys.toList() ;

  for(int i= 0; i < keys.length-1 ;i++){
    for (int j = i+1 ; j < keys.length ; j++){

      if(!(locations[keys[i]]!.isMetro && locations[keys[j]]!.isMetro)){
        if(!(locations[keys[i]]!.isTrain && locations[keys[j]]!.isTrain)) {

          if(locations[keys[i]]!.route_num.intersection(locations[keys[j]]!.route_num).length == 0){

            graph[keys[i]]?.add(keys[j]);
            graph[keys[j]]?.add(keys[i]);
          }
        }
      }
    }
  }
}

void saveGraph(Map<String, List<String>> graph,Map<String,Location1> locations){
  saveLocations(locations);
  saveAdjacencyList(graph);

}
void saveLocations(Map<String,Location1> locations) {
  String data = "Lattitude  Longitue  LocationName  isMetro  isSpeedo  isTrain  StationRouteNum(For Speedo)\n";
  locations.forEach((locName, locDetails) {
    
    data += locations[locName]!.latts.toString() + " ";
    data += locations[locName]!.longs.toString() + " ";
    data += locations[locName]!.name + " ";
    data += locations[locName]!.isMetro.toString() + " ";
    data += locations[locName]!.isSpeedo.toString() + " ";
    data += locations[locName]!.isTrain.toString() + " ";

    locations[locName]!.route_num.forEach((num) {
      data += num.toString() + " ";
    });
    data += "\n";

  });
  var file = File('./assets/Modals/Locations.txt');
  var sink = file.openWrite();
  sink.write(data);
  sink.close();
}
void saveAdjacencyList(Map<String, List<String>> graph) {
  //TODO: Store distance also
  String data = "";
  graph.forEach((node, neighbours) {

    data += graph[node]!.join(" ");
    data += "\n";

  });
  var file = File('./assets/Modals/AdjacencyList.txt');
  var sink = file.openWrite();
  sink.write(data);
  sink.close();
}

bool parseBool(String boolString){
  if(boolString == "true"){
    return true;
  }
  return false;
}
// Future<void> readLocations(Map<String,Location1> locations) async{
//
//   final file = File('./lib/RoutesFolder/Locations.txt');
//   Stream<String> lines = file.openRead()
//       .transform(utf8.decoder)       // Decode bytes to UTF-8.
//       .transform(LineSplitter());    // Convert stream to individual lines.
//   try {
//     int index = 0;
//     await for (var line in lines) {
//       if(index != 0){
//         var list = line.split(' ');
//         double latts = double.parse(list[0]);
//         double longs = double.parse(list[1]);
//         String name = list[2];
//         bool isMetro = parseBool(list[3]);
//         bool isSpeedo = parseBool(list[4]);
//         bool isTrain = parseBool(list[5]);
//
//         Location1 loc = Location1(latts, longs, name,isMetro,isSpeedo,isTrain);
//         for (int i = 6 ; i < list.length-1 ; i++){
//           loc.route_num.add(int.parse(list[i]));
//         }
//         locations[name] = loc;
//
//       }else{
//         index ++;
//       }
//
//
//     }
//   } catch (e) {
//     print('Error: $e');
//   }
// }
// Future<void> readAdjacencyList(Map<String,List<String>> graph,Map<String,Location1> locations) async{
//   final file = File('./lib/RoutesFolder/AdjacencyList.txt');
//   Stream<String> lines = file.openRead()
//       .transform(utf8.decoder)       // Decode bytes to UTF-8.
//       .transform(LineSplitter());    // Convert stream to individual lines.
//   try {
//     List<String> keys = locations.keys.toList() ;
//     int i = 0;
//     await for (var line in lines) {
//       List<String> list = line.split(' ').toList();
//       graph[keys[i]] = list;
//       i++;
//     }
//
//   } catch (e) {
//     print('Error: $e');
//   }
// }

void main() async {
  Map<String,List<String>> graph = {};
  Map<String,Location1> locations = {};

  await populateMetroStations(graph, locations);
  await populateTrainStations(graph, locations);
  await populateSpeedoStations(graph, locations);
  await makeGraphCompletelyConnected(graph,locations);

  // await readLocations(locations);
  // await readAdjacencyList(graph, locations);

  graph.forEach((key, value) {
    locations[key]?.Print();
    print("----------");
    value.forEach((loc) {
      locations[loc]?.Print();
    });
    print("----------\n");

  });

  saveGraph(graph, locations);




}