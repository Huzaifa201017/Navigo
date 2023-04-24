import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:navigo/Class/RoutesHandler.dart';
import 'package:navigo/Class/Location.dart';
import 'package:geolocator/geolocator.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage> {
  late GoogleMapController mapController;
  // icon for user location
  BitmapDescriptor? myIcon;
  StreamSubscription<Position>? positionStream;


  RoutesHandler rh = RoutesHandler();
  final LatLng _center = const LatLng(31.51214443738609, 74.37939589382803);
  bool _isMapVisible = true, _isPathComputed = false;
  Icon ic = const Icon(Icons.directions);
  Location? userLoc;

  Set<Polyline> _polylines = Set<Polyline>();
  List<Marker> _marker = [];
  // List<LatLng> _busStops = [];
  List<Location> locationsToDisplay = [];

  // TODO: when zain will do his work
  // LatLng start , end , midway;
  // String criteria;

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
          onTap: () {
            print(locationsToDisplay[i].name + " " + locationsToDisplay[i+1].name);
            rh.getDistance(locationsToDisplay[i].latts_longs, locationsToDisplay[i+1].latts_longs);
          },
        )
      );
    }
    // _polylines.add(Polyline(
    //   polylineId: PolylineId('route'),
    //   color: Colors.blue,
    //   width: 4,
    //   points: _busStops,
    // ));
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void showPageForSearchingMidWay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
          ),
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.fromLTRB(10, 10, 10, 5),
                          hintText: "Your Location",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.clear),
                          )),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.fromLTRB(10, 10, 10, 5),
                          hintText: "Insert Mid points",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.accessibility),
                          )),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.fromLTRB(10, 10, 10, 5),
                          hintText: "Search Destination",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.search),
                          )),
                    ),
                  ),
                ],
              ))),
    );
  }

  void showPageForSearchingTerminalLocations() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
          ),
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.fromLTRB(10, 10, 10, 5),
                          hintText: "Your Location",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.clear),
                          )),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.fromLTRB(10, 10, 10, 5),
                          hintText: "Search Destination",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.search),
                          )),
                    ),
                  ),
                ],
              ))),
    );
  }

  @override
  void initState() {
    super.initState();

    locationsToDisplay.addAll(rh.stations);

    // BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(50, 50)), 'assets/images/location.png').then((onValue) {
    //   myIcon = onValue;
    // });

    getUserCurrentLocation().then((value) async {
      print("Current location obtained: $value");
      userLoc = Location(LatLng(value.latitude, value.longitude), 'My Location',
          false, false, false, true);
      locationsToDisplay.insert(0, userLoc!);

      setState(() {
        fillMarkers();
      });
    });
    // listenToLocationChanges();
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: const DropdownButtonHideUnderline(
                    child: DropDown(),
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
                      busStops: locationsToDisplay
                          .getRange(1, locationsToDisplay.length)
                          .toList()),
                ),
              ),
            ),

            // Button(when pressed , the path will be computed and updates will happen in the locations),(Temporary)
            Container(
              margin: const EdgeInsets.fromLTRB(0, 300, 0, 0),
              child: CupertinoButton(
                color: Colors.blue,
                child: const Text("Temp"),
                onPressed: () {
                  setState(()  {
                    ic = const Icon(Icons.list);
                    _isPathComputed = true;

                    //TODO: Checks whether user have selected all the options for path computation
                    //TODO: apply the algo correspondingly , update the bus stops/stations
                    //-------temporary-----

                    locationsToDisplay.clear();
                    if (userLoc != null) {
                      // temporary
                      locationsToDisplay.add(userLoc!); // temporary
                      locationsToDisplay.addAll(rh.getComputedPath());
                    }

                    fillMarkers();
                    fillPolyLines();

                    rh.readAdjacencyList();
                    //rh.Print();
                  });
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "btn1",
              onPressed: () {
                if (!_isPathComputed) {
                  showPageForSearchingMidWay();
                }
                else {
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

                    // random code just to test , whether changing something in list , reflect change on the UI or not

                    // this.locationsToDisplay.removeAt(0);
                    // this._busStops.removeAt(0);
                    // fillMarkers();
                    // fillPolyLines();
                  });
                }
              },
              foregroundColor: !_isPathComputed ? Colors.white : Colors.green,
              backgroundColor: !_isPathComputed ? Colors.red : Colors.white,
              elevation: 10,
              child: Icon(
                  !_isPathComputed ? Icons.list : Icons.done_outline_outlined),
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
    'Minimum Stations',
    'Minimum Walking Distance',
    'Minimum Total Distance'
  ];
  String dropdownValue = "";

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
  final List<Location> busStops;

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
