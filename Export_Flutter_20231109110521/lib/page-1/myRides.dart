import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Ride {
  final String startLocation;
  final String endLocation;
  final String time;

  Ride({
    required this.startLocation,
    required this.endLocation,
    required this.time,
  });
}

class RideHistory {
  final String userId;

  RideHistory({required this.userId});

  Future<List<Ride>> getRideHistory() async {
    List<Ride> rides = [];

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('Rides Posted')
              .where('UserID', isEqualTo: userId)
              .get();

      for (var documentSnapshot in querySnapshot.docs) {
        var data = documentSnapshot.data();

        // Ensure field names here match the Firestore document
        Ride ride = Ride(
          startLocation: data['Start Location'] as String,
          endLocation: data['End Location'] as String,
          time: data['Time'] as String,
        );
        rides.add(ride);
      }
    } catch (error) {
      // Use Flutter's error reporting mechanism or log to your error tracking service
      debugPrint('Error fetching ride history: $error');
    }

    return rides;
  }
}

class MyRides extends StatefulWidget {
  const MyRides({Key? key}) : super(key: key);

  @override
  _MyRidesState createState() => _MyRidesState();
}

class _MyRidesState extends State<MyRides> {
  late RideHistory rideHistory;
  List<Ride> myRides = [];

  @override
  void initState() {
    super.initState();
    fetchRideHistory();
  }

  void fetchRideHistory() async {
    // Move the user ID retrieval into the asynchronous method
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      rideHistory = RideHistory(userId: currentUserId);
      List<Ride> rides = await rideHistory.getRideHistory();
      if (mounted) {
        setState(() {
          myRides = rides;
        });
      }
    } else {
      debugPrint('No user logged in');
      // Consider showing an alert dialog or redirecting the user to the login screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rides'),
      ),
      body: myRides.isEmpty
          ? const Center(
              child: Text('No rides found.'),
            )
          : ListView.builder(
              itemCount: myRides.length,
              itemBuilder: (context, index) {
                Ride ride = myRides[index];
                return ListTile(
                  title: Text(
                      'From: ${ride.startLocation} - To: ${ride.endLocation}'),
                  subtitle: Text('Time: ${ride.time}'),
                );
              },
            ),
    );
  }
}
