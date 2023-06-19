import 'package:flutter/material.dart';
import 'package:navigo/Class/DbHandler.dart';

class StationsListForSpeedoRoute extends StatefulWidget {
  int routeNum = 0;
  StationsListForSpeedoRoute({Key? key, required this.routeNum}) : super(key: key);

  @override
  State<StationsListForSpeedoRoute> createState() => _StationsListForSpeedoRouteState();
}

class _StationsListForSpeedoRouteState extends State<StationsListForSpeedoRoute> {
  bool isLoading = true;
  DbHandler db = DbHandler();
  List<String> stations = [];

  Future<void> getStations() async{
    stations = await db.getStationsForSpeedoRoute(widget.routeNum);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getStations();
  }
  @override
  Widget build(BuildContext context) {
    return  isLoading? Center(child: CircularProgressIndicator(),): Scaffold(
        appBar: AppBar(
          title: Text('Intermediate Stations'),
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 10.0 , right: 10.0, top: 20.0),
          child: ListView.separated(

              itemCount: stations.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(stations[index]),
                  trailing: Icon(Icons.directions_bus,color: Colors.redAccent,),

                  tileColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black54, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
              separatorBuilder: (context, index) => SizedBox(
                height: 10,
              )
          ) ,
        )

    );
  }
}
