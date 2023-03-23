import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage> {

  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold (

        appBar: AppBar(
          elevation: 2,
          title: const Text('Home'),
        ),

        body: GoogleMap(
          onMapCreated: _onMapCreated,
          mapType: MapType.hybrid,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
          myLocationButtonEnabled: false,

        ),

        floatingActionButton: Column (

          mainAxisAlignment: MainAxisAlignment.end,

          children: [

            FloatingActionButton(

              onPressed: () {
                showModalBottomSheet(

                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,

                  builder: (context) => Container (

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
                                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 5),
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
                                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 5),
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
                                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 5),
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
              },
              child: const Icon(Icons.list)
            ),

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
                                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 5),
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
                                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 5),
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
              },
              child: const Icon(Icons.directions),
            ),

          ],
        )
    );
  }
}
