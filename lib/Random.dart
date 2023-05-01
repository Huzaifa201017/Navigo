import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:flutter/cupertino.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(31.4815, 74.3030);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  TextEditingController _Tcontroller = TextEditingController();
  var uuid = Uuid();
  String _sessionToken = '122344';
  List<dynamic> _placesList = [];

  @override
  void initState() {
    super.initState();
    _Tcontroller.addListener(() {
      onChange();
    });
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
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&types=(cities)&key=$kPlaces_API_key&sessiontoken=$_sessionToken';

    var response = await http.get(Uri.parse(request));
    var data = response.body.toString();

    // print('data');
    // print(data);
    if (response.statusCode == 200) {
      setState(() {
        _placesList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      throw Exception('Failed to Load Data');
    }
  }

  bool is_visible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 2,
          title: const Text('Home'),
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          mapType: MapType.normal,
          zoomControlsEnabled: false,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 15.0,
          ),
          myLocationButtonEnabled: false,
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                      height: MediaQuery.of(context).size.height * 0.40,
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
                                                          controller:
                                                              _Tcontroller,
                                                          decoration: InputDecoration(
                                                              prefixIcon: Icon(Icons
                                                                  .home_rounded),
                                                              hintText:
                                                                  'Your starting location')),
                                                      // Container(
                                                      //     padding:
                                                      //         EdgeInsets.fromLTRB(
                                                      //             13, 12, 0, 0),
                                                      //     height: 40,
                                                      //     width: MediaQuery.of(
                                                      //             context)
                                                      //         .size
                                                      //         .width,
                                                      //     child: Row(children: [
                                                      //       Icon(Icons
                                                      //           .person_pin_circle_rounded),
                                                      //       const SizedBox(
                                                      //           width: 12),
                                                      //       GestureDetector(
                                                      //           child: Text(
                                                      //             "Choose on Map",
                                                      //             style:
                                                      //                 TextStyle(
                                                      //               color: Colors
                                                      //                   .black,
                                                      //               fontSize: 16,
                                                      //             ),
                                                      //           ),
                                                      //           onTap: () {})
                                                      //     ])),
                                                      Expanded(
                                                          child:
                                                              ListView.builder(
                                                                  itemCount:
                                                                      _placesList
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return ListTile(
                                                                      onTap:
                                                                          () async {
                                                                        List<Location>
                                                                            locations =
                                                                            await locationFromAddress(_placesList[index]['description']);
                                                                        print(locations
                                                                            .last
                                                                            .longitude);
                                                                        print(locations
                                                                            .last
                                                                            .latitude);
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      title: Text(
                                                                          _placesList[index]
                                                                              [
                                                                              'description']),
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
                                                          controller:
                                                              _Tcontroller,
                                                          decoration: InputDecoration(
                                                              prefixIcon: Icon(
                                                                  Icons
                                                                      .add_location_rounded,
                                                                  size: 25),
                                                              hintText:
                                                                  'Mid point to your journey')),
                                                      Expanded(
                                                          child:
                                                              ListView.builder(
                                                                  itemCount:
                                                                      _placesList
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return ListTile(
                                                                      onTap:
                                                                          () async {
                                                                        List<Location>
                                                                            locations =
                                                                            await locationFromAddress(_placesList[index]['description']);
                                                                        print(locations
                                                                            .last
                                                                            .longitude);
                                                                        print(locations
                                                                            .last
                                                                            .latitude);
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      title: Text(
                                                                          _placesList[index]
                                                                              [
                                                                              'description']),
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
                                      // color: Color(0xfffff3ff),
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
                                          //color: Colors.black,
                                          fontSize: 18,
                                          //fontWeight: FontWeight.bold,
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
                                                          controller:
                                                              _Tcontroller,
                                                          decoration: InputDecoration(
                                                              prefixIcon: Icon(
                                                                  Icons
                                                                      .approval_rounded,
                                                                  size: 25),
                                                              hintText:
                                                                  'Your endpoint location')),
                                                      Expanded(
                                                          child:
                                                              ListView.builder(
                                                                  itemCount:
                                                                      _placesList
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return ListTile(
                                                                      onTap:
                                                                          () async {
                                                                        List<Location>
                                                                            locations =
                                                                            await locationFromAddress(_placesList[index]['description']);
                                                                        print(locations
                                                                            .last
                                                                            .longitude);
                                                                        print(locations
                                                                            .last
                                                                            .latitude);
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      title: Text(
                                                                          _placesList[index]
                                                                              [
                                                                              'description']),
                                                                    );
                                                                  })),
                                                    ]))));
                                      },
                                    )),
                                const SizedBox(height: 55),
                                GestureDetector(
                                    child: Container(
                                        padding:
                                            EdgeInsets.fromLTRB(140, 0, 0, 0),
                                        height: 50,
                                        width:
                                            MediaQuery.of(context).size.width,
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
                                    onTap: () {
                                      setState(() {
                                        is_visible = !is_visible;
                                        Navigator.pop(context);
                                      });
                                    })
                              ]))),
                );
              },
              child: const Icon(Icons.directions),
            ),
          ],
        ));
  }
}
