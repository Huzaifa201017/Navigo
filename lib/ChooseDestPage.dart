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
              Text('PREP:'),
              Text('25 min'),
            ],
          ),
            Row(
              children: [
                Text('COOK:'),
                Text('1 hr'),
              ],
            ),],)

      )
    );
  }
}