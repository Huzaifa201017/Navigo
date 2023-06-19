import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:navigo/Class/RoutesHandler.dart';
import 'package:navigo/Class/Location.dart';
import 'package:navigo/Widgets/SearchLocationsPage.dart';
import 'package:navigo/Toast.dart';

class BottomSheetOnDirectionsButton extends StatefulWidget {
  LatLng userLocation = LatLng(0.0, 0.0);
  StopLocation? start,end ;
  final ValueChanged<List<StopLocation?>> onPressingDoneButton;

  BottomSheetOnDirectionsButton({
    required this.userLocation,
    required this.start,
    required this.end,
    required this.onPressingDoneButton
  });

  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();

}

class _MyBottomSheetState extends State<BottomSheetOnDirectionsButton> {
  @override
  void initState() {
    super.initState();
  }

  void onChoosingStartingLocation(StopLocation selectedLocation){
    print(selectedLocation.name);
    print(selectedLocation.latts_longs);
    widget.start = selectedLocation;
    widget.start?.isStartingPoint = true;
    setState(() {

    });
  }

  void onChoosingDestinationLocation(StopLocation selectedLocation){
    print(selectedLocation.name);
    print(selectedLocation.latts_longs);
    widget.end = selectedLocation;
    widget.end?.isDestination = true;

    setState(() {

    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
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
                      widget.start!.name,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => SearchLocationsPage(
                              formFieldIcon: Icons.home_rounded,
                              onLocationSelected: onChoosingStartingLocation,
                              userLocation: widget.userLocation,
                              hintText: "Search...",
                          )
                      );
                    },
                  )
              ),

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
                    widget.end == null ? "Your Destination" : widget.end!.name,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => SearchLocationsPage(
                            formFieldIcon: Icons.approval_rounded,
                            onLocationSelected: onChoosingDestinationLocation,
                            userLocation: widget.userLocation,
                            hintText: "Search..."
                        )
                    );
                  },
                ),
              ),

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
                    child: Row(
                      children: [
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
                      ],
                    )
                ),
                onTap: () {

                  if (widget.end == null ){
                    Message().show("You have to select your destination!");
                  }else if (widget.start!.latts_longs == widget.end!.latts_longs){
                    Message().show("Starting and ending locations can't be same!");
                  }else{
                    List<StopLocation?> selectedLocations = [];
                    selectedLocations.add(widget.start);
                    selectedLocations.add(widget.end);
                    Navigator.pop(context);
                    widget.onPressingDoneButton(selectedLocations);
                  }
                },
              )
            ]
        ),
      ),
    );
  }
}
