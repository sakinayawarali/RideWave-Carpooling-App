import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/util/database.dart';

class RideDetail extends StatefulWidget {
  // Update the constructor to include the named parameter 'ride'
  const RideDetail({Key? key, required Map<dynamic, dynamic>? ride})
      : ride = ride,
        super(key: key);

  final Map<dynamic, dynamic>? ride;

  @override
  _RideDetailState createState() => _RideDetailState();
}

class _RideDetailState extends State<RideDetail> {
  late Razorpay _razorpay;
  late SharedPreferences prefs;
  late String email;
  late List<Map<String, dynamic>> rides; // List to store ride details

  @override
  void initState() {
    _razorpay = Razorpay();

    initPrefs();
    fetchRides(); // Fetch rides when the widget initializes
    super.initState();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('useremail') ?? '';
    });
  }

 // Function to fetch rides from the database
Future<void> fetchRides() async {
  try {
    var data = await getRideData();
    rides = data?.cast<Map<String, dynamic>>() ?? [];
    setState(() {}); // Update the UI with the fetched rides
  } catch (e) {
    print('Error fetching rides: $e');
    // Handle errors if necessary
  }
}


Future<void> acceptRide(String docID) async {
  try {
    await addRider(email, docID); // Pass the user's email to addRider

    // Optionally, you can add logic to update other parts of your app or database
    // For example, navigate back to the homepage:
    Navigator.pop(context);
  } catch (e) {
    print('Error accepting ride: $e');
    // Handle errors if necessary
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: const Text('RideWave'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
          itemCount: rides.length,
          itemBuilder: (context, index) {
            final ride = rides[index];
            return Card(
              elevation: 8.0,
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.green[50]),
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.account_circle,
                        size: 100,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Text(
                          'Owner: ${ride['email'] ?? 'Unknown'}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Text(
                          'Start: ${ride['start'] ?? 'Unknown'}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Text(
                          'End: ${ride['end'] ?? 'Unknown'}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Text(
                          'Time: ${ride['time'] ?? 'Unknown'}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            for (var item in ride['riderList'] ?? [])
                              Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w100,
                                ),
                              )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: ElevatedButton(
                          onPressed: () {
                            acceptRide(ride['id']);
                          },
                          child: const Text('Accept Ride'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void openCheckout() async {
    int amount = int.parse('100') * 100;

    var options = {
      'key': 'rzp_test_2TLtsLWJAwiCKC',
      'currency': 'USD',
      'amount': 20000,
      'name': 'GrouPool',
      'description': 'Fine T-Shirt',
      'prefill': {'contact': '8887788888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
        // 'wallets': ['gpay']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      // debugPrint('Error: e');
    }
  }
}
