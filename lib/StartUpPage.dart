import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:navigo/LoginPage.dart';
import 'package:navigo/SignUpPage.dart';

class StartUpPage extends StatelessWidget {
  const StartUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Started'),
        elevation: 2,
      ),
      body: Center(
        child: Column(
            children:[
              Container(
                height: 50,
                width: 150,
                margin: const EdgeInsets.all(10),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
                    },
                    child:const Text('Login',
                      style: TextStyle(fontWeight: FontWeight.bold,letterSpacing: 2),
                    ),
                ),
              ),
              Container(
                height: 50,
                width: 150,
                margin: const EdgeInsets.all(10),
                child: ElevatedButton(onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUp()));
                } ,
                    child: const Text('Sign Up',
                    style: TextStyle(fontWeight: FontWeight.bold,letterSpacing: 2),
                    )
                ),
              )
            ],
          ),
      )
      );
  }
}
