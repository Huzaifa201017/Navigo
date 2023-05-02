import 'package:google_maps_flutter_platform_interface/src/types/location.dart';


class StopLocation{
  LatLng latts_longs;
  String name;
  bool isMetro , isSpeedo , isTrain, isYourLocation, isDestination, isStartingPoint;
  int route_num = -1;
  double distance=0.0;
  int nodeNum = 0;
  final _routesName = {1:"R.A Bazar - Chungi Amar Sidhu ", 2:"Bhatti Chowk - Shadbagh Underpass ", 3:"Babu Sabu - Main Market ", 4:"R.A Bazar - Bhatti Chowk ", 5:"Canal - Thokar Niaz Baig", 6: "R.A Bazar - Nasir Bagh "};

  StopLocation(this.latts_longs ,this.name,[this.isMetro=false , this.isSpeedo=false , this.isTrain=false, this.isYourLocation=false, this.isDestination=false, this.isStartingPoint=false]);

  String getStationTypesInString(){
    String type = "";
    if (isMetro){
      type += "-Metro Station\n";
    }
    if (isSpeedo){
      type += "-Speedo Station\n";
      type += "--"+_routesName[route_num]!;
    }
    if (isTrain){
      type += "-Orange Train Station\n";
    }
    if (isYourLocation){
      type += "-Your Location\n";
    }
    if (isDestination){
      type += "-Your Destination\n";
    }
    if (isStartingPoint){
      type += "-Your Starting Point\n";
    }
    type = type.substring(0,type.length-1);  // remove redundant /n from the end
    return type;
  }

  void Print(){
    String temp  = this.name+ " "+ this.latts_longs.latitude.toString() +" "+ this.latts_longs.longitude.toString()+" "+this.isMetro.toString() + " "+ this.isSpeedo.toString()+ " "+ this.isTrain.toString();
    if (this.route_num != -1){
      temp += " "+ this.route_num.toString();
    }
    print(temp);
  }
}
