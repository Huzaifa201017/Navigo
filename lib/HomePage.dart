import 'package:flutter/material.dart';
import 'package:navigo/MapsPage.dart';
import 'package:navigo/RoutesDetailsPage.dart';
import 'package:navigo/SavedPlacesPage.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int pageIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [MapsPage(), SavedPlacesPage(), RoutesDetailsPage()];
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Go",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.saved_search), label: "Saved Places"),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: "Browse Routes"),
        ],
      ),
      body: pages[pageIndex],
    );
  }
}
