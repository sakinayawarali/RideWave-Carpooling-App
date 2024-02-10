import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/page-1/signin.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Call the _navigateToLoginScreen function after 3 seconds
    Timer(Duration(seconds: 2), _navigateToLoginScreen);
  }

  void _navigateToLoginScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xff008955), // Updated color
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/page-1/images/ridewave-high-resolution-logo-black-transparent.png',
                width: 300.0,
                height: 200.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
