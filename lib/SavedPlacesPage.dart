import 'package:flutter/material.dart';

class SavedPlacesPage extends StatelessWidget {
  const SavedPlacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Places'),
      ),

      body: const Center(
        child: Text('Saved Places Page'),
      ),
    );
  }
}
