import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:navigo/Class/RoutesHandler.dart';
import 'package:navigo/Class/Location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:navigo/Class/DbHandler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';


class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage> {
  // ----- Zain's --------
  TextEditingController _Tcontroller = TextEditingController();
  var uuid = Uuid();
  String _sessionToken = '122344';
  List<dynamic> _placesList = [];
  // ----------------------

  late GoogleMapController mapController;
  // icon for user location
  BitmapDescriptor? myIcon;
  StreamSubscription<Position>? positionStream;


  RoutesHandler rh = RoutesHandler();
  final LatLng _center = const LatLng(31.51214443738609, 74.37939589382803);
  bool _isMapVisible = true, _isPathComputed = false,  is_visible =false;
  Icon ic = const Icon(Icons.directions);
  StopLocation? userLoc,start,end , midway;

  Set<Polyline> _polylines = Set<Polyline>();
  List<Marker> _marker = [];
  // List<LatLng> _busStops = [];
  List<StopLocation> locationsToDisplay = [];


  String criteria = "";
  final DropDown d =  DropDown();

  @override
  void dispose() {
    super.dispose();
    /// don't forget to cancel stream once no longer needed
    positionStream?.cancel();
  }

  void listenToLocationChanges() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 100,
    );

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) {
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
    return await Geolocator.getCurrentPosition();
  }

  void fillMarkers() {
    _marker.clear();
    for (int i = 0; i < locationsToDisplay.length; i++) {
      if (locationsToDisplay[i].isYourLocation) {
        _marker.add(
          Marker(
            markerId: MarkerId('$i'),
            position: locationsToDisplay[i].latts_longs,
            // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            icon: myIcon == null
                ? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue)
                : myIcon!,
            consumeTapEvents: false,
          ),
        );
      } else if (locationsToDisplay[i].isStartingPoint) {
        //Create the corresponding marker

        _marker.add(
          Marker(
            markerId: MarkerId('$i'),
            position: locationsToDisplay[i].latts_longs,
            infoWindow: InfoWindow(
              title: locationsToDisplay[i].name,
              snippet: locationsToDisplay[i].getStationTypesInString(),
              onTap: () => showActionSheet(context, ""),
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            consumeTapEvents: false,
          ),
        );
      } else if (locationsToDisplay[i].isDestination) {
        //Create the corresponding marker
        _marker.add(
          Marker(
            markerId: MarkerId('$i'),
            position: locationsToDisplay[i].latts_longs,
            infoWindow: InfoWindow(
              title: locationsToDisplay[i].name,
              snippet: locationsToDisplay[i].getStationTypesInString(),
              onTap: () => showActionSheet(context, ""),
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            consumeTapEvents: false,
          ),
        );
      } else if (locationsToDisplay[i].isTrain ||
          locationsToDisplay[i].isMetro ||
          locationsToDisplay[i].isSpeedo) {

        _marker.add(
          Marker(
            markerId: MarkerId('$i'),
            position: locationsToDisplay[i].latts_longs,
            infoWindow: InfoWindow(
              title: locationsToDisplay[i].name,
              snippet: locationsToDisplay[i].getStationTypesInString(),
              onTap: () => showActionSheet(context, ""),
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            consumeTapEvents: false,
          ),
        );
      }
    }
  }

  void fillPolyLines() {
    _polylines.clear();

    for (int i=0 ; i < locationsToDisplay.length-1 ; i++){
        _polylines.add(Polyline(
          polylineId: PolylineId('$i'),
          color: Colors.blue,
          width: 4,
          points: [locationsToDisplay[i].latts_longs ,locationsToDisplay[i+1].latts_longs ],
          consumeTapEvents: true,
          onTap: () async {
            print(locationsToDisplay[i].name + " " + locationsToDisplay[i+1].name);
            if (start != null && end != null ){
              List<StopLocation> newResult = await rh.getNextPossiblePath(start!,end!,"Minimum Total Distance",locationsToDisplay[i].nodeNum,locationsToDisplay[i+1].nodeNum);

              if (newResult.length != 0){

                setState(() {

                  locationsToDisplay.clear();
                  locationsToDisplay.add(userLoc!);
                  locationsToDisplay.addAll(newResult);

                  fillMarkers();
                  fillPolyLines();
                });
              }
            }

            // rh.getDistance(locationsToDisplay[i].latts_longs, locationsToDisplay[i+1].latts_longs);
          },
        )
      );
    }

  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }


  void showPageForSearchingTerminalLocations() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.50,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
          ),
          child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 30, 15, 15),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.all(12.5),
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: GestureDetector(
                          child: Text(
                            "Your Location",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => Container(
                                    height: MediaQuery.of(context).size.height * 0.90,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.only(
                                        topLeft:
                                        Radius.circular(25.0),
                                        topRight:
                                        Radius.circular(25.0),
                                      ),
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(15, 25, 15, 15),
                                        child: Column(children: [
                                          TextFormField(
                                              controller:
                                              _Tcontroller,
                                              decoration: InputDecoration(
                                                  prefixIcon: Icon(Icons.home_rounded),
                                                  hintText: 'Your starting location'
                                              )
                                          ),
                                          Expanded(
                                              child:
                                              ListView.builder(
                                                  itemCount: _placesList.length,
                                                  itemBuilder: (context, index) {
                                                    return ListTile(
                                                      onTap: () async {
                                                        List<Location>locations = await locationFromAddress(_placesList[index]['description']);
                                                        print(locations.last.longitude);
                                                        LatLng t = LatLng(locations.last.latitude, locations.last.longitude);
                                                        start = StopLocation(t, "StartingPoint");
                                                        start?.isStartingPoint = true;

                                                        Navigator.pop(context);
                                                      },
                                                      title: Text(_placesList[index]['description']),
                                                    );
                                                  })),
                                        ]))));
                          },
                        )),
                    const SizedBox(height: 15),
                    Container(
                        padding: EdgeInsets.all(12.5),
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: GestureDetector(
                          child: Text(
                            "Mid Point (Optional)",
                            style: TextStyle(
                              // color: Colors.grey,
                              fontSize: 18,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => Container(
                                    height: MediaQuery.of(context)
                                        .size
                                        .height *
                                        0.90,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.only(
                                        topLeft:
                                        Radius.circular(25.0),
                                        topRight:
                                        Radius.circular(25.0),
                                      ),
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets
                                            .fromLTRB(
                                            15, 25, 15, 15),
                                        child: Column(children: [
                                          TextFormField(
                                              controller: _Tcontroller,
                                              decoration: InputDecoration(
                                                  prefixIcon: Icon(Icons.add_location_rounded, size: 25),
                                                  hintText: 'Mid point to your journey')),
                                          Expanded(
                                              child: ListView.builder(
                                                  itemCount: _placesList.length,
                                                  itemBuilder: (context, index) {
                                                    return ListTile(
                                                      onTap: () async {
                                                        List<Location>locations = await locationFromAddress(_placesList[index]['description']);
                                                        print(locations.last.longitude);
                                                        print(locations.last.latitude);

                                                        Navigator.pop(context);
                                                      },
                                                      title: Text(_placesList[index]['description']),
                                                    );
                                                  })),
                                        ]))));
                          },
                        )),
                    const SizedBox(height: 15),
                    Container(
                        padding: EdgeInsets.all(12.5),
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: GestureDetector(
                          child: Text(
                            "Your Destination",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => Container(
                                    height: MediaQuery.of(context)
                                        .size
                                        .height *
                                        0.90,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.only(
                                        topLeft:
                                        Radius.circular(25.0),
                                        topRight:
                                        Radius.circular(25.0),
                                      ),
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(15, 25, 15, 15),
                                        child: Column(
                                            children: [
                                            TextFormField(
                                                controller:
                                                _Tcontroller,
                                                decoration: InputDecoration(
                                                    prefixIcon: Icon(Icons.approval_rounded, size: 25),
                                                    hintText: 'Your endpoint location'
                                                )
                                            ),
                                            Expanded(
                                                child: ListView.builder(
                                                    itemCount:
                                                    _placesList.length,
                                                    itemBuilder: (context, index) {
                                                      return ListTile(
                                                        onTap: () async {
                                                          List<Location>locations = await locationFromAddress(_placesList[index]['description']);
                                                          print(locations.last.longitude);

                                                          // LatLng t = LatLng(locations.last.latitude, locations.last.longitude);
                                                          // end = StopLocation(t, "Destination Point");
                                                          // end?.isDestination = true;

                                                          LatLng t = LatLng(31.48170416692978, 74.30305701092631);
                                                          end = StopLocation(t, "FAST NUCES Lahore");
                                                          end?.isDestination = true;

                                                          Navigator.pop(context);
                                                        },
                                                        title: Text(_placesList[index]['description']),
                                                      );
                                                    })),
                                          ]
                                        )
                                    )
                                )
                            );
                          },
                        )),
                    const SizedBox(height: 40),
                    GestureDetector(
                        child: Container(
                            padding: EdgeInsets.fromLTRB(140, 0, 0, 0),
                            height: MediaQuery.of(context).size.height*0.080,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius:
                              BorderRadius.circular(10.0),
                              border: Border.all(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            child: Row(children: [
                              Icon(
                                Icons.check_box_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Done",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ])),
                        onTap: () async{
                          Navigator.pop(context);

                          if (start != null && end != null){
                            List<StopLocation> result = await rh.getComputedPath(start! , end! , "Minimum Total Distance");

                            if(result.length != 0){

                              setState(() {
                                ic = const Icon(Icons.list);
                                _isPathComputed = true;

                                //apply the algo correspondingly , update the bus stops/stations

                                locationsToDisplay.clear();
                                locationsToDisplay.add(userLoc!);
                                locationsToDisplay.addAll(result);

                                fillMarkers();
                                fillPolyLines();
                              });

                            }
                          }

                        })
                  ]))),
    );
  }

  Future<void> loadData() async {
    await rh.populateStations();
    locationsToDisplay.addAll(rh.stations);

    getUserCurrentLocation().then((value) async {

      print("Current location obtained: $value");
      userLoc = StopLocation(LatLng(value.latitude, value.longitude), 'My StopLocation',
          false, false, false, true);
      start = userLoc;
      start?.isStartingPoint = true;
      locationsToDisplay.insert(0, userLoc!);

      setState(() {
        fillMarkers();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();

    _Tcontroller.addListener(() {
      onChange();
    });

    // listenToLocationChanges();
  }

  void onChange() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestions(_Tcontroller.text);
  }

  void getSuggestions(String input) async {
    String kPlaces_API_key = "AIzaSyC5Y_qUAVEn3_mlCeDDTQdH0gqzLHCS-tg";
    String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$baseURL?input=$input&types=(cities)&key=$kPlaces_API_key&sessiontoken=$_sessionToken';

    var response = await http.get(Uri.parse(request));
    var data = response.body.toString();

    if (response.statusCode == 200) {
      setState(() {

        _placesList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      throw Exception('Failed to Load Data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  initialCameraPosition: CameraPosition(
                    target: userLoc != null ? userLoc!.latts_longs : _center,
                    zoom: 15.0,
                  ),
                  markers: Set<Marker>.of(_marker),
                  myLocationButtonEnabled: false,
                  tiltGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: false,
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
                    child: d,
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
                      busStops: locationsToDisplay.getRange(1, locationsToDisplay.length).toList()),
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
                      setState(() {
                        rh.graph.clear();
                        _isMapVisible = true;
                        ic = const Icon(Icons.directions);
                        _isPathComputed = false;

                        locationsToDisplay.clear();
                        if (userLoc != null) {
                          locationsToDisplay.add(userLoc!);
                        }
                        locationsToDisplay.addAll(rh.stations);

                        fillMarkers();
                        _polylines.clear();

                      });
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
                  setState(() {
                    rh.graph.clear();
                    _isMapVisible = !_isMapVisible;
                    if (_isMapVisible) {
                      ic = Icon(Icons.list);
                    } else {
                      ic = Icon(Icons.map);
                    }
                  });
                }
              },
              child: ic,
            ),
          ],
        ));
  }
}

class DropDown extends StatefulWidget {
  const DropDown({super.key});

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

  DropDown() {
    dropdownValue = list.first;
  }

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

  BusStopListView({required this.busStops}) {}

  @override
  Widget build(BuildContext context) {
    return ListView.separated(

        itemCount: busStops.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            //TODO: subtitle would be decided on the basis of boolean values in the Location Class
            subtitle: Text(busStops[index].getStationTypesInString()),
            title: Text(busStops[index].name),
            trailing: Icon(Icons.directions_bus),

            tileColor: Colors.white,

            onTap: () {
              _launchUrl(busStops[index].latts_longs.latitude,
                  busStops[index].latts_longs.longitude);
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
            ));
  }

  Future<void> _launchUrl(double latitude, double longitude) async {
    String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleMapsUrl)) {
      await launch(
        googleMapsUrl,
        forceSafariVC: false,
        universalLinksOnly: true,
        headers: {'referer': 'https://www.google.com/'},
      );
    } else {
      throw 'Could not open the map.';
    }
  }
}

void showActionSheet(BuildContext context, String busStopName) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => CupertinoActionSheet(
      //TODO: make a check that if the location is already saved then there is no need of keeping the save button active

      title: Text(
        'Station',
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
            Navigator.pop(context);
          },
          child: const Text(
            'Save',
            style: TextStyle(color: Colors.blue),
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
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
