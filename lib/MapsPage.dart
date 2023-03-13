import 'package:flutter/material.dart';
import 'package:navigo/ChooseDestPage.dart';

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
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                      height: MediaQuery.of(context).size.height * 0.90,
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(25.0),
                          topRight: const Radius.circular(25.0),
                        ),
                      ),
                      child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextField(
                                decoration: InputDecoration(
                                    hintText: "Your Location",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.clear),
                                    )),
                              ),
                              SizedBox(height: 5),
                              TextField(
                                decoration: InputDecoration(
                                    hintText: "Insert Mid points",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.accessibility),
                                    )),
                              ),
                              SizedBox(height: 5),
                              TextField(
                                decoration: InputDecoration(
                                    hintText: "Search Destination",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.search),
                                    )),
                              ),
                            ],
                          ))),
                );
              },
              child: Text("zain"),
            ),
            SizedBox(height: 40),
            FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                      height: MediaQuery.of(context).size.height * 0.90,
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(25.0),
                          topRight: const Radius.circular(25.0),
                        ),
                      ),
                      child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextField(
                                decoration: InputDecoration(
                                    hintText: "Your Location",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.clear),
                                    )),
                              ),
                              SizedBox(height: 5),
                              TextField(
                                decoration: InputDecoration(
                                    hintText: "Search Destination",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.search),
                                    )),
                              ),
                            ],
                          ))),
                );
              },
              child: Icon(Icons.directions),
            ),
          ],
        ));
  }
}
