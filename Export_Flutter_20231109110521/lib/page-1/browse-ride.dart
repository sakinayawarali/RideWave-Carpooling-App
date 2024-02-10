import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/page-1/home.dart';

const kPrimaryColor =
    Color(0xff008955); // Replace with your actual primary color

class BrowseRide extends StatefulWidget {
  final Map userdata;
  const BrowseRide({Key? key, required this.userdata}) : super(key: key);

  @override
  _BrowseRideState createState() => _BrowseRideState();
}

class _BrowseRideState extends State<BrowseRide> {
  late Future<List<Map<String, dynamic>>> futureRides;
   Set<String> confirmedRideIds = Set();

  @override
  void initState() {
    super.initState();
    futureRides = fetchRides();
  }

  Future<List<Map<String, dynamic>>> fetchRides() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("No user currently logged in");
      return [];
    }

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Rides Posted')
          .where('User ID',
              isNotEqualTo: currentUser.uid) // Exclude current user's rides
          .get();

      List<Map<String, dynamic>> ridesList = snapshot.docs.map((doc) {
        // Add the document ID to the data so we can reference it later if needed
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      print("Fetched rides: $ridesList"); // Logging the fetched data

      return ridesList;
      
    } catch (e) {
      print("Error fetching rides: $e");
      return [];
    }
  }

  Future<void> confirmRide(String rideId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("No user currently logged in");
      return;
    }

    final rideRef =
        FirebaseFirestore.instance.collection('Rides Posted').doc(rideId);

    try {
      // Run a transaction to ensure that the increment operation is atomic
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(rideRef);

        if (!snapshot.exists) {
          throw Exception("Ride not found!");
        }

        int currentAccepted =
            snapshot.get('Accepted') ?? 0; // Get the current 'Accepted' count
        transaction.update(rideRef, {
          'Accepted': currentAccepted + 1
        }); // Increment the 'Accepted' count by 1
      });// After confirming, add the ride ID to the local set
  setState(() {
    confirmedRideIds.add(rideId);
  });

  print("Ride confirmed successfully");
} catch (e) {
      print("Error confirming ride: $e");
    }
  }

  void selectRide(String rideId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Ride"),
          content: Text("Are you sure you want to select this ride?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Confirm"),
              onPressed: () {
                // Call confirmRide when the user confirms their selection
                confirmRide(rideId).then((_) {
                  Navigator.of(context)
                      .pop(); // Close the dialog after confirming the ride
                }).catchError((error) {
                  // Handle any errors here
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RideWave'),
        backgroundColor: kPrimaryColor,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureRides,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No rides available.'));
          }

          List<Map<String, dynamic>> rides = snapshot.data!;

          return ListView.builder(
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index];
              return Card(
                color: Color(0xffe2f5ed),
                child: ListTile(
                  leading: Icon(Icons.directions_car, color: kPrimaryColor),
                  title: Text(
                      '${ride['Start Location']} to ${ride['End Location']}'),
                  subtitle: Text(
                      'Time: ${ride['Time']} \nGender Preference: ${ride['Gender Preference']}'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: kPrimaryColor),
                    onPressed: () {
                      selectRide(ride['id']);
                    },
                    child: Text('Select Ride'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
