import 'package:flutter/material.dart';
import 'package:navigo/HomePage.dart' ;

class ChooseDestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        ),
        body: (
            Column(mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Current Location'),
            ],
          ),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Text('Search Destination'),
              ],
            ),],)

      )
    );
  }
}