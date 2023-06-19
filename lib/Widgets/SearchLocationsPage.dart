import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:navigo/Class/RoutesHandler.dart';
import 'package:navigo/Class/Location.dart';

class SearchLocationsPage extends StatefulWidget {

  IconData formFieldIcon = Icons.approval_rounded;
  final ValueChanged<StopLocation> onLocationSelected;
  LatLng userLocation = LatLng(0.0, 0.0);
  String hintText = "";

  SearchLocationsPage({required this.formFieldIcon , required this.onLocationSelected, required this.userLocation, required this.hintText});

  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<SearchLocationsPage> {
  List<String> _filteredData = [];
  Map<String, LatLng> _places = {};
  RoutesHandler rh = RoutesHandler();

  @override
  void initState() {
    super.initState();
    _places = rh.getLocationsList(widget.userLocation);
    _filteredData = _places.keys.toList();
  }
  void updateSearchQuery(String query) {
    setState(() {
      List<String> data = _places.keys.toList();
      _filteredData = data.where((element) =>
          element.toLowerCase().contains(query.toLowerCase()))
          .toList();
      // print(_filteredData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.90,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only (
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 25, 15, 15),
            child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                        prefixIcon: Icon(widget.formFieldIcon, size: 25),
                        hintText: widget.hintText,
                    ),
                    onChanged: (query) => updateSearchQuery(query),
                  ),
                  Expanded(
                      child: ListView.builder(
                        itemCount: _filteredData.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {
                              LatLng t = _places[_filteredData[index]]!;
                              StopLocation loc = StopLocation(t, _filteredData[index]);
                              widget.onLocationSelected(loc);
                              Navigator.pop(context);
                            },
                            title: Text(_filteredData[index]),
                          );
                        },
                      )
                  ),
                ]
            )
        )
    );
  }
}
