import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/page-1/ViewProfile.dart';
import 'package:myapp/page-1/notifs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/page-1/editprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/page-1/signin.dart';
import 'package:myapp/page-1/car-details.dart';
import 'package:myapp/page-1/add_ride.dart';
import 'package:myapp/page-1/browse-ride.dart';
import 'package:myapp/page-1/myRides.dart';
import 'package:myapp/page-1/complain-feedback.dart';
import 'package:myapp/page-1/notifs.dart';

class HomePage extends StatefulWidget {
  final Map userdata;

  const HomePage({Key? key, required this.userdata}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String email = '';
  String username = '';
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs?.getString('useremail') ?? '';
  }

  Future<void> init() async {
    await initPrefs();
    await fetchUserData();
  }

   Future<void> fetchUserData() async {
    prefs = await SharedPreferences.getInstance();
    final uid = prefs?.getString('uid'); // Assuming 'uid' is stored in shared preferences

    if (uid != null && uid.isNotEmpty) {
      try {
        DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore.instance
            .collection('user data') // Collection name from your Firestore
            .doc(uid) // UID from SharedPreferences
            .get();

        final data = documentSnapshot.data();
        if (data != null) {
          setState(() {
            // Use the correct field name 'Username' here.
            username = data['Username'] as String? ?? 'User';
          });
        } else {
          print('User data not found in the database');
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    } else {
      print('UID is null or empty');
    }
  }

  ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    primary: Color(0xff008955),
    onPrimary: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RideWave', style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                'Welcome!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48),
              ElevatedButton(
                style: buttonStyle,
                child: Text('View Profile'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewProfile()),
                  );
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: buttonStyle,
                child: Text('Add Car Details'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CarDetails(userdata: widget.userdata)),
                  );
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: buttonStyle,
                child: Text('Post a Ride'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddRide()),
                  );
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: buttonStyle,
                child: Text('Browse Rides'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BrowseRide(userdata: widget.userdata,)),
                  );
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: buttonStyle,
                child: Text('My Rides'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyRides()),
                  );
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: buttonStyle,
                child: Text('Notifications'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            NotifsPage()),
                  );
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: buttonStyle,
                child: Text('Feedback'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => feedback()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Color(0xff008955),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_rental),
            label: 'My Rides',
            backgroundColor: Color(0xff008955),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedback',
            backgroundColor: Color(0xff008955),
          ),
          // Add more items as needed
        ],
        onTap: (index) {
          // Add your navigation logic here
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: signOut,
        tooltip: 'Sign Out',
        child: const Icon(Icons.exit_to_app),
        backgroundColor: Color(0xff008955),
      ),
    );
  }

  Future<void> signOut() async {
    await prefs?.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }
}
