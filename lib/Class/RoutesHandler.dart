import 'package:navigo/Class/Location.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';

class RoutesHandler {

  List<Location> stations = [];

  RoutesHandler(){
    _populateStations();
  }
  void _populateStations() {

    stations.add(Location(LatLng(31.506621004611624, 74.37830243389809),'Nadeem Chowk',false,true));
    stations.add(Location(LatLng(31.506238484612883, 74.38494682631604),'RA-Bazar',false,true));
  }

  List<LatLng> getStationCoordinates(List<Location> stations){

    List<LatLng> lats_langs = [];
    for (int i=0 ; i< stations.length ; i++) {
      lats_langs.add(stations[i].latts_longs);
    }
    return lats_langs;
  }

  List<Location> getComputedPath(){
    //TODO: There would be some paramters
    List<Location> result = [Location(LatLng(31.51214443738609, 74.37939589382803),'Starting Point',false,false,false,false,false,true)];
    result.addAll(stations);
    result.add(Location(LatLng(31.50018037093097, 74.39487289494411),'Destination Point',false,false,false,false,true));

    return result;
  }


}