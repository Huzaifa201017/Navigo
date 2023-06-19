import 'package:flutter/material.dart';
import 'package:navigo/Class/Traveller.dart';
import 'package:navigo/Class/Location.dart';
import 'package:navigo/Class/DbHandler.dart';
import 'package:navigo/HomePage.dart';
import 'dart:math';

class SavedPlacesPage extends StatefulWidget {

  const SavedPlacesPage({Key? key}) : super(key: key);
  @override
  State<SavedPlacesPage> createState() => _State();
}
// class _State extends State<SavedPlacesPage>  with AutomaticKeepAliveClientMixin
class _State extends State<SavedPlacesPage> {
  // @override
  // bool get wantKeepAlive => true;

  final Traveller user = Traveller.Instance();
  List<StopLocation> savedPlaces = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    print("User id: "+user.id);
    fetchPlaces();
  }
  void fetchPlaces() async {
    setState(() {
      isLoading = true;
    });
    savedPlaces = await DbHandler().fetchSavedPlaceFromDb(user.id);
    print(savedPlaces.length);
    savedPlaces.forEach((place) {
      print(place.name);
    });
    setState(() {
      isLoading = false;
    });


  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return  isLoading? Center(child: CircularProgressIndicator(),): Scaffold(
      appBar: AppBar(
        title: const Text('Saved Places'),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 10.0,left: 10.0,right: 10.0,bottom: 10.0),
        child: GridView.builder (
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1, // modify this property
          ),
          itemCount: savedPlaces.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                HomePageState? homePageState = context.findAncestorStateOfType<HomePageState>();
                homePageState?.moveToMapsPage(savedPlaces[index]);
              },
              child: Container(
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            topRight: Radius.circular(15.0),
                          ),
                          child: Image.network(
                            'https://picsum.photos/id/${Random().nextInt(1000)}/200/200',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3, vertical: 10),
                        child: Text(
                          savedPlaces[index].name,
                          textAlign: TextAlign.center,
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),

    );
  }

}
