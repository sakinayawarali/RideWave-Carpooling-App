import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({Key? key}) : super(key: key);

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('No user logged in', style: GoogleFonts.poppins()),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('View Profile', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xff008955),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('user data') 
            .doc(user.uid) 
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.exists) {
            Map<String, dynamic> userProfile = snapshot.data!.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: <Widget>[
                  Text(
                    'Name: ${userProfile['Username'] ?? 'Not specified'}', // Changed 'Name' to 'Username'
                    style: GoogleFonts.poppins(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Email: ${userProfile['Email'] ?? 'Not specified'}',
                    style: GoogleFonts.poppins(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Phone: ${userProfile['Phone'] ?? 'Not specified'}',
                    style: GoogleFonts.poppins(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Gender: ${userProfile['Gender'] ?? 'Not specified'}',
                    style: GoogleFonts.poppins(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ERP: ${userProfile['ERP'] ?? 'Not specified'}',
                    style: GoogleFonts.poppins(fontSize: 20),
                  ),
                  // Add more fields as necessary
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('No user data found.'),
            );
          }
        },
      ),
    );
  }
}
