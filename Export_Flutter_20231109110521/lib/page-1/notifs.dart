import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotifsPage extends StatefulWidget {
  @override
  _NotifsPageState createState() => _NotifsPageState();
}

class _NotifsPageState extends State<NotifsPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  Future<List<QueryDocumentSnapshot>> fetchRidesPostedByCurrentUser() async {
    if (currentUser == null) return [];

    // Fetch all rides posted by the current user
    var snapshot = await FirebaseFirestore.instance
        .collection('Rides Posted')
        .where('User ID', isEqualTo: currentUser!.uid)
        .get();

    // Filter client-side for rides with at least one confirmation
    return snapshot.docs.where((doc) => doc['Accepted'] > 0).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: currentUser == null
          ? Center(child: Text('No user logged in'))
          : ListView(
              children: [
                FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: fetchRidesPostedByCurrentUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.data == null || snapshot.data!.isEmpty) {
                      return Center(child: Text('No confirmed rides.'));
                    }

                    // Build a list of ride confirmations
                    return Column(
                      children: snapshot.data!.map((doc) {
                        return ListTile(
                          title: Text(
                              'Ride to ${doc['End Location']} has been confirmed!'),
                          subtitle:
                              Text('Confirmed: ${doc['Accepted']} time(s)'),
                        );
                      }).toList(),
                    );
                  },
                ),
                FutureBuilder<QuerySnapshot>(
                  // Get confirmations made by the current user
                  future: FirebaseFirestore.instance
                      .collection(
                          'UserConfirmedRides') // Assuming you have such a collection
                      .where('User ID', isEqualTo: currentUser!.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text(''));
                    }

                    // Build a list of rides the user has confirmed
                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        return ListTile(
                          title: Text('You have confirmed a ride.'),
                          // You would replace 'Ride ID' with actual ride details if needed
                          subtitle: Text('Ride ID: ${doc['Ride ID']}'),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
