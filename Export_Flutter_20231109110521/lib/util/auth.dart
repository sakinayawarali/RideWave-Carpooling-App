import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

FirebaseAuth get auth => _auth; // Public getter to access _auth

String? uid;
String? userEmail;

Future<void> signInWithEmailPassword(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Process the userCredential as needed
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      // User not found
    } else if (e.code == 'wrong-password') {
      // Wrong password
    } else if (e.code == 'invalid-email') {
      // Email is invalid
    } else {
      // Handle other codes
    }
    // Log the error or display an error message
  } catch (e) {
    // Handle any other errors
  }
}

Future<User?> registerWithEmailPassword(String email, String password) async {
  User? user;

  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    user = userCredential.user;

    if (user != null) {
      uid = user.uid;
      userEmail = user.email;
    }
  } catch (e) {
    print(e);
  }

  return user;
}

