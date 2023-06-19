import 'package:flutter/material.dart';
import 'package:navigo/MapsPage.dart';
import 'package:navigo/RoutesDetailsPage.dart';
import 'package:navigo/SavedPlacesPage.dart';
import 'package:navigo/Class/Location.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int pageIndex = 0;
  // final PageStorageBucket bucket = PageStorageBucket();
  final pages = [
     MapsPage(
      key: PageStorageKey('Page1'),
         savedLocation: null
    ),
     SavedPlacesPage(
      key: PageStorageKey('Page2'),
    ),
     RoutesDetailsPage(
      key: PageStorageKey('Page3'),
    )
  ];
  void _onItemTapped(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  void moveToMapsPage(StopLocation loc) {
    setState(() {
      pageIndex = 0; // move to the second tab

      pages[0] = MapsPage(
          key: PageStorageKey('Page1'),
          savedLocation: loc
      );
    });
  }

  @override
  Widget build(BuildContext context) {

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
      // body: PageStorage(
      //   child: pages[pageIndex],
      //   bucket: this.bucket,
      // )

    );
  }
}
