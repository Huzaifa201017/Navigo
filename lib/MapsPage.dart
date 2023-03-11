import 'package:flutter/material.dart';

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

      floatingActionButton: const FloatingActionButton(
        onPressed: null,
        child: Icon(Icons.directions),
      ),
    );
  }
}
