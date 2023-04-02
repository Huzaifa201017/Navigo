import 'package:google_maps_flutter_platform_interface/src/types/location.dart';


class Location{
  LatLng latts_longs;
  String name;
  bool isMetro , isSpeedo , isTrain, isYourLocation, isDestination, isStartingPoint;

  Location(this.latts_longs ,this.name,[this.isMetro=false , this.isSpeedo=false , this.isTrain=false, this.isYourLocation=false, this.isDestination=false, this.isStartingPoint=false]);

}