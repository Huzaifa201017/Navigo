import 'package:flutter/material.dart';
import 'package:navigo/ChooseDestPage.dart' ;

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),

      body: const Center(
        child: Text('Maps Page'),
      ),

      floatingActionButton:Column(mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(onPressed:(){
            Navigator.push(context,
                MaterialPageRoute(builder:(context) =>ChooseDestPage()));
          }
            ,
            child: Text("zain"),
          ),
          SizedBox(height: 40),
          FloatingActionButton(onPressed:(){
            Navigator.push(context,
                MaterialPageRoute(builder:(context) =>ChooseDestPage()));
          }
            ,
            child: Icon(Icons.directions),
          ),
        ],
      )
    );
  }
}
