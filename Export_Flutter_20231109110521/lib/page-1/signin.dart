import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/page-1/home.dart';
import 'package:myapp/page-1/signup.dart';
import 'package:myapp/page-1/forgotPassword.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void _navigateToHomeScreen() async {
    String enteredEmail =
        emailController.text.trim().toLowerCase(); // Convert to lowercase
    String enteredPassword = passwordController.text.trim();

    try {
      // Use Firebase Authentication to sign in
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: enteredEmail,
        password: enteredPassword,
      );

      // Check if the sign in was successful
      if (userCredential.user != null) {
        // After an async gap, we check if the widget is still mounted
        if (!mounted) return;
        // Prepare userdata map
        Map<String, String> userdata = {'Email': enteredEmail};
        // Navigate to the home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomePage(userdata: userdata),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // After an async gap, we check if the widget is still mounted
      if (!mounted) return;

      // Handle the different Firebase Auth exceptions
      String errorMessage = 'An error occurred. Please try again later.';
      if (e.code == 'user-not-found') {
        errorMessage = 'User not found. Please check your email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect email or password. Please try again.';
      }

      // Display the error message
      _showAuthenticationFailedDialog(errorMessage);
    }
  }

  void _showAuthenticationFailedDialog(String message) {
    // After an async gap, we check if the widget is still mounted
    if (!mounted) return;

    // No async gap before showing the dialog, so it's safe to use context
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Authentication Failed'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToSignUpScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignupPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Image.asset(
              'assets/page-1/images/ridewave-high-resolution-logo-black-transparent.png',
              width: MediaQuery.of(context).size.width * 0.5,
            ),
            SizedBox(height: 30),
            Text(
              'LOG IN',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 50),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.visibility_off),
                    ),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen(),
                        ));
                      },
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        primary: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xff008955),
                      minimumSize: Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed:
                        _navigateToHomeScreen, // Corrected: Call the function without parentheses
                    child: Text(
                      'LOG IN',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Color(0xff008955),
                      side: BorderSide(color: Color(0xff008955)),
                      minimumSize: Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _navigateToSignUpScreen(context),
                    child: Text(
                      'SIGN UP',
                      style: GoogleFonts.poppins(
                        color: Color(0xff008955),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
