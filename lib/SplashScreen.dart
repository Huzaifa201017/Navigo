import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:navigo/FirebaseServices.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:navigo/HomePage.dart';
import 'package:navigo/MapsPage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:navigo/LoginPage.dart';
import 'package:navigo/Class/DbHandler.dart';
import 'package:navigo/Class/Traveller.dart';

class SplashScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return  AnimatedSplashScreen.withScreenFunction(

      splash: Center(
           child:  Image.asset('assets/images/logo.png'),
        ),
        screenFunction: () async {

          DbHandler().copyDatabase();
          return LoginPage();
          // if (FirebaseAuth.instance.currentUser != null) {
          //   Traveller.Instance(FirebaseAuth.instance.currentUser!.uid);
          //   return  HomePage();
          // }else{
          //   return LoginPage();
          // }
        },
      duration: 1700,
      splashIconSize: 10000.0,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.rightToLeftWithFade,
      animationDuration: Duration(seconds: 1),

    );
  }
}
