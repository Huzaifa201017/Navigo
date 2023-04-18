import 'package:google_maps_flutter_platform_interface/src/types/location.dart';


class Location{
  LatLng latts_longs;
  String name;
  bool isMetro , isSpeedo , isTrain, isYourLocation, isDestination, isStartingPoint;

  Location(this.latts_longs ,this.name,[this.isMetro=false , this.isSpeedo=false , this.isTrain=false, this.isYourLocation=false, this.isDestination=false, this.isStartingPoint=false]);

  String getStationTypesInString(){
    String type = "";
    if (isMetro){
      type += "-Metro Station\n";
    }
    if (isSpeedo){
      type += "-Speedo Station\n";
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
}