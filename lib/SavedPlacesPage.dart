import 'package:flutter/material.dart';
import 'package:navigo/Class/Traveller.dart';

class SavedPlacesPage extends StatefulWidget {
  const SavedPlacesPage({Key? key}) : super(key: key);

  @override
  State<SavedPlacesPage> createState() => _State();
}

class _State extends State<SavedPlacesPage> {
  final Traveller user = Traveller.Instance();
  @override
  void initState() {
    super.initState();
    print("User id: "+user.id);
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Saved Places'),
      ),

      body: const Center(
        child: Text('Saved Places Page'),
      ),
    );
  }

}
