import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(31.51214443738609, 74.37939589382803);

  List<Marker> _marker = [];

  void _showActionSheet(BuildContext context, String busStopName) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          busStopName,
          style: TextStyle(fontSize: 20),
        ),
        message: const Text(
          'Bus Stop',
          style: TextStyle(fontSize: 15),
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


  late List<Marker> _list =  [
    Marker(
        markerId: MarkerId('1'),

        position: LatLng(31.51214443738609, 74.37939589382803),
        infoWindow: InfoWindow(
          title: 'My current Location',
        ),

      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      consumeTapEvents: false,



    ),
    Marker(
        onTap: () => _showActionSheet(context,'Nadeem Chowk'),
        markerId: MarkerId('2'),
        position: LatLng(31.506621004611624, 74.37830243389809),
        infoWindow: InfoWindow(
          title: 'Nadeem Chowk',
        ),

        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      consumeTapEvents: false,


    ),
    Marker(
        onTap: () => _showActionSheet(context,'Sky Grill'),
        markerId: MarkerId('2'),
        position: LatLng(31.513227917965875, 74.38006954675411),
        infoWindow: InfoWindow(
          title: 'Sky Grill',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      consumeTapEvents: false,
    )
  ];


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {

    // TODO: implement initState
    super.initState();

    _marker.addAll(_list);


  }


  @override
  Widget build(BuildContext context) {

    return Scaffold (
        appBar: null,
        body: Stack(
          children: [


            GoogleMap(
              onMapCreated: _onMapCreated,
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition (
                target: _center,
                zoom: 15.0,
              ),
              markers: Set<Marker>.of(_marker),
              myLocationButtonEnabled: false,
            ),


            Container (
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


                child: const DropdownButtonHideUnderline(
                  child: const DropDown(),
                )
            ),

          ],
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
                                            const EdgeInsets.fromLTRB(
                                                10, 10, 10, 5),
                                        hintText: "Your Location",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
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
                                            const EdgeInsets.fromLTRB(
                                                10, 10, 10, 5),
                                        hintText: "Insert Mid points",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
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
                                            const EdgeInsets.fromLTRB(
                                                10, 10, 10, 5),
                                        hintText: "Search Destination",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
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
                },
                child: const Icon(Icons.list)),
            const SizedBox(height: 40),
            FloatingActionButton(
              onPressed: () {
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
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          10, 10, 10, 5),
                                      hintText: "Your Location",
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
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
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          10, 10, 10, 5),
                                      hintText: "Search Destination",
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
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
              },
              child: const Icon(Icons.directions),
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

    return  DropdownButton2(

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
        width:  352,

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



