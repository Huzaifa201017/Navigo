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

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title:  Text(busStopName,
          style: TextStyle(fontSize: 20),
        ),
        message:  const Text('Bus Stop', style: TextStyle(fontSize: 15),),
        cancelButton:CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.blue),),
        ),
        actions: <CupertinoActionSheetAction>[

          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },

            child: const Text('Save', style: TextStyle(color: Colors.blue),),
          ),
          CupertinoActionSheetAction(

            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Open on Google Maps', style: TextStyle(color: Colors.blue),),
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
      consumeTapEvents: true,


    ),
    Marker(
      onTap: () => _showActionSheet(context,'Nadeem Chowk'),
      markerId: MarkerId('2'),
      position: LatLng(31.506621004611624, 74.37830243389809),
      infoWindow: InfoWindow(
        title: 'Nadeem Chowk',
      ),

      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      consumeTapEvents: true,


    ),
    Marker(
      onTap: () => _showActionSheet(context,'Sky Grill'),
      markerId: MarkerId('3'),
      position: LatLng(31.513227917965875, 74.38006954675411),
      infoWindow: InfoWindow(
        title: 'Sky Grill',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      consumeTapEvents: true,
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
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 15.0,
              ),
              markers: Set<Marker>.of(_marker),
              myLocationButtonEnabled: false,
            ),

          ],
        ),

    );
  }
}