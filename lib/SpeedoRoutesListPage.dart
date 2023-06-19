import 'package:flutter/material.dart';
import 'package:navigo/StationsListForSpeedoRoutePage.dart';

class SpeedoRoutesListPage extends StatelessWidget {
  final List<String> routes =  const ['R.A Bazar - Chungi Amar Sidhu','Bhatti Chowk - Shadbagh Underpass', 'Babu Sabu - Main Market'
                  , 'R.A Bazar - Bhatti Chowk' , 'Canal - Thokar Niaz Baig', 'R.A Bazar - Nasir Bagh'];

  const SpeedoRoutesListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Speedo Route'),
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 10.0 , right: 10.0, top: 20.0),
          child: ListView.separated(

              itemCount: routes.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(routes[index]),
                  trailing: Icon(Icons.route_outlined,color: Colors.redAccent,),

                  tileColor: Colors.white,

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StationsListForSpeedoRoute(
                            routeNum: index+1,
                          )),
                    );
                  },
                  splashColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black54, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
              separatorBuilder: (context, index) => SizedBox(
                height: 10,
              )
          ) ,
        ) 
        
    );

  }

}


