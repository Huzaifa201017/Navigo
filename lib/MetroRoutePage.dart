import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:navigo/Class/Location.dart';
import 'package:navigo/Class/RoutesHandler.dart';
import 'package:navigo/Class/DbHandler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';

class MetroRoutePage extends StatefulWidget {
  @override
  _MetroRoutePageState createState() => _MetroRoutePageState();
}

class _MetroRoutePageState extends State<MetroRoutePage> {
  DbHandler db = DbHandler();
  RoutesHandler r = RoutesHandler();
  List<StopLocation> busStops = [];
  bool isLoading = false;
  @override
  initState() {
    super.initState();
    // print("initState");
    _getRecords();
  }

  Future<void> _getRecords() async {
    setState(() {
      isLoading = true;
    });
    var res = await r.MetroRoute();
    setState(() {
      busStops = res;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Center(
      child: CircularProgressIndicator(),
    ) : Scaffold(
        appBar: AppBar(
          title: Text('Metro Route'),
        ),
        body: Padding(
            padding: const EdgeInsets.only(left: 10.0 , right: 10.0, top: 20.0),
            child: ListView.separated(
                itemCount: busStops.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    // subtitle: Text("huzaifa tharki"),
                    title: Text(busStops[index].name),
                    trailing: Icon(Icons.directions_bus, color: Colors.redAccent,),
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
            )
        )
    );
  }
}