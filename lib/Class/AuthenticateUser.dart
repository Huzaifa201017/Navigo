import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:navigo/FirebaseServices.dart';
import 'package:navigo/HomePage.dart';
import 'package:navigo/SignUpPage.dart';
import 'package:navigo/Class/Traveller.dart';

class AuthenticateUser{

  Future<bool> login(GlobalKey<FormState> _formKey, TextEditingController emailController, TextEditingController passwordController) async {

    if (_formKey.currentState?.validate() ?? false) {

      FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text).then((value) {

        Traveller u = Traveller.Instance(value.user!.uid);
        return true;

      }).onError((error, stackTrace) {

        print("Error ${error.toString()}");
        //Message().show('Error signing in with Google: ' + error.toString());
        return false;
      });
    }
    return false;
  }

  Future<bool> loginWithGoogle() async {
    bool r = false;
    FirebaseServices().signInWithGoogle().then((user) async{

      Traveller.Instance(FirebaseAuth.instance.currentUser!.uid);
      r = true;

    }).catchError((error) async{
      print('Error signing in with Google: ' + error.toString());
    });
    return r;
  }
}