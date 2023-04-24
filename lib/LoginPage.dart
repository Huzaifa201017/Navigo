import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:navigo/FirebaseServices.dart';
import 'package:navigo/HomePage.dart';
import 'package:navigo/SignUpPage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:navigo/Class/Traveller.dart';
import 'Toast.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> navigateToHomePage() async {
   Navigator.pushReplacement(context, PageTransition(child: HomePage(), type: PageTransitionType.bottomToTopPop, childCurrent: this.widget, duration: Duration(seconds: 0,milliseconds: 500)));
  }

  // Future<void> checkLoginStatus() async {
  //   if (FirebaseAuth.instance.currentUser != null) {
  //     // store it the credentials , move to the home page
  //     await navigateToHomePage();
  //   }
  // }

  Future<void> login() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Perform login functionality
      FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text).then((value) {
        Traveller u = Traveller.Instance(value.user!.uid);
        // print("User id: "+u.id+" "+value.user!.uid);
        Message().show("Success!");
        navigateToHomePage();
      }).onError((error, stackTrace) {
        print("Error ${error.toString()}");
        Message().show('Error signing in with Google: ' + error.toString());
      });
    }
  }

  Future<void> loginWithGoogle() async {
    FirebaseServices().signInWithGoogle().then((user) {

      Traveller.Instance(FirebaseAuth.instance.currentUser!.uid);

      Message().show("Success!");
      navigateToHomePage();
    }).catchError((error) {
      print('Error signing in with Google: ' + error.toString());
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
    //checkLoginStatus();
    // if (FirebaseAuth.instance.currentUser != null) {
    //   // store it the credentials , move to the home page
    //   _signOut();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:SingleChildScrollView(
        child:  Padding(
          padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/images/logo.png', width: 200, height: 200),
                // Text(
                //   'Welcome To Navigo!',
                //   style: TextStyle(
                //     fontSize: 32,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.redAccent[700],
                //   ),
                // ),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text('Login'),
                    onPressed: () {
                      this.login();
                    },
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Image.asset('assets/images/google.png', height: 24),
                    label: Text('Login with Google'),
                    onPressed: () {
                      this.loginWithGoogle();

                    },
                    style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?"),
                    SizedBox(width: 4),
                    TextButton(
                      child: Text('Sign Up'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      )

    );
  }
}

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login successful'),
      ),
      body: Center(
        child: Text('You have successfully logged in!'),
      ),
    );
  }
}
