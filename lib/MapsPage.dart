import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:navigo/Widgets/SearchLocationsPage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:navigo/Class/RoutesHandler.dart';
import 'package:navigo/Class/Location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:navigo/Class/DbHandler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:navigo/Class/Traveller.dart';
import 'package:navigo/Widgets/SearchLocationsPage.dart';
import 'package:navigo/Widgets/BottomSheetOnDirectionsButton.dart';
import 'package:navigo/Toast.dart';
import 'package:navigo/HomePage.dart';

class MapsPage extends StatefulWidget {
  StopLocation? savedLocation = null;
  MapsPage({Key? key, this.savedLocation}) : super(key: key);

  @override
  State<MapsPage> createState() => MapsPageState();
}
// class MapsPageState extends State<MapsPage> with AutomaticKeepAliveClientMixin<MapsPage>
class MapsPageState extends State<MapsPage> {
  // @override
  // bool get wantKeepAlive => true;


  late GoogleMapController mapController;
  StreamSubscription<Position>? positionStream;

  RoutesHandler rh = RoutesHandler();
  final LatLng _center = const LatLng(31.51214443738609, 74.37939589382803);
  Icon ic = const Icon(Icons.directions);
  final Traveller user = Traveller.Instance();
  StopLocation? userLoc,start,end ;

  bool _isMapVisible = true, _isPathComputed = false,  is_visible =false,isLoading=true;

  String dropdownValue = "Minimum Walking Distance"; // path finding criteria

  List<Marker> _marker = [];
  List<StopLocation> locationsToDisplay = [];
  List<String> _filteredData = [];
  Map<String, LatLng> _places = {};
  Set<Polyline> _polylines = Set<Polyline>();


  @override
  void dispose() {
    super.dispose();
    positionStream?.cancel();
  }


  void _moveCameraToLocation(LatLng location) {
    mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(target: location, zoom: 15.0)
        )
    );
  }

  void makeTransitionBetween_Map_ListView(){
    setState(() {
      _isMapVisible = !_isMapVisible;
      if (_isMapVisible) {
        ic = Icon(Icons.list);
      }
      else {
        ic = Icon(Icons.map);
      }
    });
  }

  void onListRowSelected(LatLng location) {
    makeTransitionBetween_Map_ListView();
    print(location.latitude.toString() + " " + location.longitude.toString());
    _moveCameraToLocation(location);
  }

  Future<void> onDropdownValueChanged(String newValue) async {
    print("New Criteria = "+newValue);
    dropdownValue = newValue;

    if (start != null && end != null && _isPathComputed){
      locationsToDisplay.clear();
      rh.graph.clear();
      rh.locations.remove(128);
      rh.locations.remove(129);
      rh.isCalculatingNextPath = false;

      List<StopLocation> result = await rh.getComputedPath(start! , end! , dropdownValue);

      if(result.length != 0){

        setState(() {
          locationsToDisplay.addAll(result);
          fillMarkers();
          fillPolyLines();

        });

      }
    }
  }

  Future<void> onPressingDoneButton(List<StopLocation?> selectedLocations ) async{
    start = selectedLocations[0];
    end = selectedLocations[1];
    end!.isDestination = true;
    print("At line 121: Criteria Recieved: " + dropdownValue);

    List<StopLocation> result = await rh.getComputedPath(start! , end! , dropdownValue);

    if(result.length != 0) {

      setState(() {
        ic = const Icon(Icons.list);
        _isPathComputed = true;
        locationsToDisplay.clear();

        locationsToDisplay.addAll(result);
        print(locationsToDisplay[0].name);

        fillMarkers();
        fillPolyLines();
      });

    }else{
      endPathFindingSession();
      Message().show("Sorry! No appropriate route exists !");
    }
  }

  void endPathFindingSession() {
    setState(() {

      rh.isCalculatingNextPath = false;
      _isMapVisible = true;
      _isPathComputed = false;

      ic = const Icon(Icons.directions);

      locationsToDisplay.clear();
      rh.graph.clear();
      _polylines.clear();
      rh.locations.remove(128);
      rh.locations.remove(129);

      locationsToDisplay.addAll(rh.stations);
      fillMarkers();

    });
  }

  void listenToLocationChanges() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 100,
    );

    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position? position) {
        print(position == null ? 'Unknown' : '$position');

        if (position != null && userLoc != null) {

          if (position?.latitude != userLoc?.latts_longs.latitude &&
              position?.longitude != userLoc?.latts_longs.longitude) {
            setState(() {
              userLoc!.latts_longs =
                  LatLng(position!.latitude, position!.longitude);
              locationsToDisplay[0].latts_longs = userLoc!.latts_longs;
              fillMarkers();
            });
          }
        }
      },
    );
  }

  Future<Position> getUserCurrentLocation() async {
    try {
      await Geolocator.requestPermission();
    } catch (e) {
      print("Error occurred while requesting permission");
    }
    return Geolocator.getCurrentPosition();

  }

  void fillMarkers() {
    _marker.clear();
    for (int i = 0; i < locationsToDisplay.length; i++) {

     if (locationsToDisplay[i].isStartingPoint) {
        // Create the corresponding marker
        _marker.add(
          Marker(
            markerId: MarkerId('$i'),
            position: locationsToDisplay[i].latts_longs,
            infoWindow: InfoWindow(
              title: locationsToDisplay[i].name,
              snippet: locationsToDisplay[i].getStationTypesInString(),
              onTap: () => showActionSheet_On_Station_Start_Marker_Press(context, "Your Starting Point",locationsToDisplay[i].latts_longs.latitude, locationsToDisplay[i].latts_longs.longitude ),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            consumeTapEvents: false,
          ),
        );
      }

     else if (locationsToDisplay[i].isDestination) {
        //Create the corresponding marker
        _marker.add(
          Marker(
            markerId: MarkerId('$i'),
            position: locationsToDisplay[i].latts_longs,
            infoWindow: InfoWindow(
              title: locationsToDisplay[i].name,
              snippet: locationsToDisplay[i].getStationTypesInString(),
              onTap: () => showActionSheet_On_Dest_Marker_Press(context, locationsToDisplay[i].name,locationsToDisplay[i].latts_longs.latitude, locationsToDisplay[i].latts_longs.longitude, user!.id ),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            consumeTapEvents: false,
          ),
        );
      }

      else if ( locationsToDisplay[i].isTrain ||
                locationsToDisplay[i].isMetro ||
                locationsToDisplay[i].isSpeedo ) {

        _marker.add(
          Marker(
            markerId: MarkerId('$i'),
            position: locationsToDisplay[i].latts_longs,
            infoWindow: InfoWindow(
              title: locationsToDisplay[i].name,
              snippet: locationsToDisplay[i].getStationTypesInString(),
              onTap: () => showActionSheet_On_Station_Start_Marker_Press(context, "Station",locationsToDisplay[i].latts_longs.latitude, locationsToDisplay[i].latts_longs.longitude ),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            consumeTapEvents: false,
          ),
        );
      }
    }
  }

  void fillPolyLines() {
    _polylines.clear();

    for (int i=0 ; i < locationsToDisplay.length-1 ; i++){
        _polylines.add(
            Polyline(
          polylineId: PolylineId('$i'),
          color: Colors.blue,
          width: 4,
          // patterns: [
          //   PatternItem.dash(8),
          //   PatternItem.gap(30),
          // ],
          points: [locationsToDisplay[i].latts_longs ,locationsToDisplay[i+1].latts_longs ],
          consumeTapEvents: true,
          onTap: () async {
            print(locationsToDisplay[i].name + " " + locationsToDisplay[i+1].name);

            if (start != null && end != null ) {
              List<StopLocation> newResult = await rh.getNextPossiblePath(start!,end!,dropdownValue,locationsToDisplay[i].nodeNum,locationsToDisplay[i+1].nodeNum);

              if (newResult!=null && newResult.length != 0) {

                setState(() {

                  locationsToDisplay.clear();
                  locationsToDisplay.addAll(newResult);

                  fillMarkers();
                  fillPolyLines();
                });

              }
              else {
                endPathFindingSession();
                Message().show("No further appropriate route exists !");
              }
            }
          },
        )
        );
    }

  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void showPageForSearchingTerminalLocations() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BottomSheetOnDirectionsButton(
          userLocation: userLoc!.latts_longs,
          start: start,
          end: end,
          onPressingDoneButton: onPressingDoneButton,
      ),

    );
  }

  Future<void> storeUserLocation() async{
    Position position = await getUserCurrentLocation();
    print("Current location obtained: $position");
    userLoc = StopLocation(LatLng(position.latitude, position.longitude), 'My StopLocation', false, false, false, true);
    start = userLoc;
    start?.isStartingPoint = true;
    start?.name = "Your Location";
  }

  Future<void> loadData() async {

    await storeUserLocation();
    await rh.populateStations();

    locationsToDisplay.addAll(rh.stations);

    setState(() {
      isLoading = false;
      if (end != null) {
        Future.delayed(Duration(milliseconds: 100), () {

          showPageForSearchingTerminalLocations();
        });
      }
      fillMarkers();
    });


  }


  @override
  void initState() {
    super.initState();

    if (widget.savedLocation != null){
      end = widget.savedLocation!;
      // showPageForSearchingTerminalLocations();
      HomePageState? homePageState = context.findAncestorStateOfType<HomePageState>();
      homePageState?.pages[0] = MapsPage(
          key: PageStorageKey('Page1'),
          savedLocation: null
      );

    }
    loadData();
    // listenToLocationChanges();
  }

  void updateSearchQuery(String query) {
    setState(() {
      List<String> data = _places.keys.toList();
      _filteredData.clear();
      _filteredData = data.where((element) =>
          element.toLowerCase().contains(query.toLowerCase()))
          .toList();
      print(_filteredData);
    });
  }

  @override
  Widget build(BuildContext context) {

   return  isLoading? Center(child: CircularProgressIndicator(),): Scaffold(
        appBar: null,
        body: Stack(
          children: [
            // Widget of Google Maps
            AnimatedOpacity(
              opacity: _isMapVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: Visibility(
                visible: _isMapVisible,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: userLoc != null ? userLoc!.latts_longs : _center,
                    zoom: 15.0,
                  ),
                  markers:Set<Marker>.of(_marker),
                  myLocationButtonEnabled: false,
                  tiltGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  polylines: _polylines,
                ),
              ),
            ),

            // Widget of DropDown
            Visibility(
              visible: true,
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey,
                      width: 2,
                    ),
                  ),
                  margin: const EdgeInsets.fromLTRB(10, 30, 10, 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child:  DropdownButtonHideUnderline(
                    child: DropDown(onValueChanged: onDropdownValueChanged),
                  )),
            ),
            // List View

            AnimatedOpacity(
              opacity: !_isMapVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Visibility(
                visible: !_isMapVisible,
                child: Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.fromLTRB(0, 80, 0, 0),
                  child: BusStopListView(
                      busStops: locationsToDisplay,
                      onLocationSelected: onListRowSelected,
                  ),
                ),
              ),
            ),


          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            Visibility(
              visible: _isPathComputed,
                child: FloatingActionButton(
                  heroTag: "btn1",
                  onPressed: () {
                    if (_isPathComputed) {
                      endPathFindingSession();
                    }

                  },
                  foregroundColor: Colors.green,
                  backgroundColor: Colors.white,
                  elevation: 10,

                  child: Icon(Icons.done_outline_outlined),
                ),
            ),

            const SizedBox(height: 40),

            FloatingActionButton(
              heroTag: "btn2",
              onPressed: () {
                if (!_isPathComputed) {
                  this.showPageForSearchingTerminalLocations();
                }
                else {
                  makeTransitionBetween_Map_ListView();
                }
              },
              child: ic,
              elevation: 10,
            ),
          ],
        )
   );
  }
}

class DropDown extends StatefulWidget {
  final ValueChanged<String> onValueChanged;

  DropDown({required this.onValueChanged});

  @override
  State<DropDown> createState() => DropDownState();
}

class DropDownState extends State<DropDown> {

  final List<String> list = <String>[
    'Minimum Walking Distance',
    'Minimum Total Distance',
    'Minimum Stations Switching'
  ];
  String dropdownValue = "Minimum Walking Distance";


  @override
  Widget build(BuildContext context) {
    return DropdownButton2(
      isExpanded: true,
      hint: Text("Select Criteria"),
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      value: dropdownValue.isNotEmpty ? dropdownValue : null,
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value!;
        });
        widget.onValueChanged(dropdownValue);
      },
      dropdownStyleData: DropdownStyleData(
        //width:  MediaQuery.of(context).size.width,
        width: 352,

        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),

        offset: Offset(-10, -10),
      ),
      menuItemStyleData: MenuItemStyleData(
        height: 40,
        padding: EdgeInsets.only(left: 14, right: 14),
      ),
    );
  }
}

class BusStopListView extends StatelessWidget {

  final List<StopLocation> busStops;
  final ValueChanged<LatLng> onLocationSelected;
  BusStopListView({required this.busStops,required this.onLocationSelected}) {}

  Color getTileColor(int index){
    if (busStops[index].isDestination){
      return Color(0x1F82ED9F);

    }else if(busStops[index].isStartingPoint){
      return Color(0x104F1BEF);
    }
    else if(index > 0 && index < busStops.length){
      if( !((this.busStops[index]!.isMetro && this.busStops[index + 1]!.isMetro) ||
          (this.busStops[index]!.route_num == this.busStops[index + 1]!.route_num)) ){
        return Color(0x1FF25757);
      }
    }
    return Colors.white;
  }


  @override
  Widget build(BuildContext context) {
    return ListView.separated(

        itemCount: busStops.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(

            subtitle: Text(busStops[index].getStationTypesInString()),
            title: Text(busStops[index].name),
            trailing: Icon(Icons.directions_bus, color: Colors.redAccent,),

            tileColor: getTileColor(index),

            onTap: () {
              onLocationSelected(LatLng(busStops[index].latts_longs.latitude, busStops[index].latts_longs.longitude));
            },
            splashColor: Colors.grey,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
        separatorBuilder: (context, index) => SizedBox(
              height: 10,
        )
    );
  }

}

void showActionSheet_On_Station_Start_Marker_Press(BuildContext context, String locationType,double latts , double longs) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => CupertinoActionSheet(
      //TODO: make a check that if the location is already saved then there is no need of keeping the save button active

      title: Text(
        locationType,
        style: TextStyle(fontSize: 20, color: Colors.black54),
      ),
      message: const Text(
        'Do you want to open it with Google Maps?',
        style: TextStyle(fontSize: 15, color: Colors.black54),
      ),
      cancelButton: CupertinoActionSheetAction(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text(
          'Cancel',
          style: TextStyle(color: Colors.blue),
        ),
      ),
      actions: <CupertinoActionSheetAction>[

        CupertinoActionSheetAction(
          onPressed: () {
            launchUrl(latts,longs);
            Navigator.pop(context);
          },
          child: const Text(
            'Open on Google Maps',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    ),
  );
}

void showActionSheet_On_Dest_Marker_Press(BuildContext context,String locationName ,double latts , double longs, String id) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => CupertinoActionSheet(
      //TODO: make a check that if the location is already saved then there is no need of keeping the save button active

      title: Text(
        'Your Destination',
        style: TextStyle(fontSize: 20, color: Colors.black54),
      ),
      message: const Text(
        'Do you want to save or open it on Google Maps?',
        style: TextStyle(fontSize: 15, color: Colors.black54),
      ),
      cancelButton: CupertinoActionSheetAction(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text(
          'Cancel',
          style: TextStyle(color: Colors.blue),
        ),
      ),
      actions: <CupertinoActionSheetAction>[

        CupertinoActionSheetAction(
          onPressed: () {
            DbHandler().loadSavedPlaceToDb(locationName,id,LatLng(latts,longs));
            Navigator.pop(context);
          },
          child: const Text(
            'Save',
            style: TextStyle(color: Colors.blue),
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            launchUrl(latts,longs);
            Navigator.pop(context);
          },
          child: const Text(
            'Open on Google Maps',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    ),
  );
}


Future<void> launchUrl(double latitude, double longitude) async {
  String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  if (await canLaunch(googleMapsUrl)) {
    await launch(
      googleMapsUrl,
      forceSafariVC: false,
      universalLinksOnly: true,
      headers: {'referer': 'https://www.google.com/'},
    );
  }
  else {
    throw 'Could not open the map.';
  }
}