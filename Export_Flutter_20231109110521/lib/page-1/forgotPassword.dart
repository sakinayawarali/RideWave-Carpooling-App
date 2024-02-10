import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/page-1/signin.dart'; // Assuming you have a login screen at this path

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _erpController = TextEditingController();

  @override
  void dispose() {
    _erpController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail(String erp) async {
    // Retrieve the user's email from Firestore using the ERP
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('user data')
          .where('ERP', isEqualTo: erp)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        String userEmail = userDoc.docs.first.data()['Email'];
        await FirebaseAuth.instance.sendPasswordResetEmail(email: userEmail);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset email sent! Check your inbox.')),
        );
        // Navigate back to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user found with that ERP.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending reset email: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _erpController,
                decoration: InputDecoration(labelText: 'Enter your ERP'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your ERP';
                  }
                  return null;
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _sendPasswordResetEmail(_erpController.text);
                    }
                  },
                  child: Text('Send Password Reset Email'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: ForgotPasswordScreen()));
}
