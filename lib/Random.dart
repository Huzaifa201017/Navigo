Container(
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
start!.name,
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
userLocation: userLoc!.latts_longs,
hintText: "Search..."
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
"Mid Point (Optional)",
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
formFieldIcon: Icons.add_location_rounded,
onLocationSelected: onChoosingMidwayLocation,
userLocation: userLoc!.latts_longs,
hintText: "Search..."
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
end == null ? "Your Destination" : end!.name,
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
userLocation: userLoc!.latts_longs,
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
onTap: () async {

Navigator.pop(context);

if (start != null && end != null &&  start!.latts_longs != end!.latts_longs){
List<StopLocation> result = await rh.getComputedPath(start! , end! , dropdownValue);

if(result.length != 0) {

setState(() {
ic = const Icon(Icons.list);
_isPathComputed = true;
locationsToDisplay.clear();
locationsToDisplay.addAll(result);

fillMarkers();
fillPolyLines();
});

}
}

},
)
]
),
),
),