import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/util/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
Future<void> storeValues() async {
  String uid = '', email = '';
  SharedPreferences.getInstance().then((prefs) => {
        firestore.collection('User Profile').add({
          'UID': '${prefs.getString('uid')}',
          'Email': '${prefs.getString('user-email')}'
        }).then((value) => {print('')})
      });
}

Future<String> registerUser(String Username, String Email, String Phone,
    String Gender, String ERP, String Password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: Email, password: Password);
    User? user = userCredential.user;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await firestore.collection('user data').doc(user?.uid).set({
      'Email': Email,
      'Username': Username,
      'Phone': Phone,
      'Gender': Gender,
      'ERP': ERP,
      // Don't store the password in Firestore
    });
    await prefs.setString('uid', user?.uid ?? '');
    await prefs.setString('user-email', Email);
    print('User Registered in DB');
    return 'Success';
  } on FirebaseAuthException catch (e) {
    print('Error registering user: ${e.code}');
    return 'Error: ${e.code}'; // Provide a more specific error message
  } catch (e) {
    print('Error registering user: $e');
    return e.toString(); // Return the error message for debugging
  }
}

Future<String> addRide(
    String start, String end, String time, String email) async {
  try {
    await firestore
        .collection('ride-table')
        .add({'start': start, 'end': end, 'time': time, 'email': email});
    print('Added Ride in DB');
    return 'Success';
  } catch (e) {
    print('Error adding ride: $e');
    return 'Failure';
  }
}

Future<Map<String, dynamic>?> getUserData() async {
  User? currentUser = auth.currentUser; // Use the public getter here
  if (currentUser != null) {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user data')
          .doc(currentUser.uid) // Use uid to fetch user data
          .get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print('No user profile found for the current user.');
        return null;
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  } else {
    print('No user is currently signed in.');
    return null;
  }
}

Future<List<Map<String, dynamic>>> getRideData() async {
  List<Map<String, dynamic>> rideList = [];
  try {
    var snapshot = await firestore.collection('ride-table').get();
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>; // Cast the data
      data['id'] = doc.id; // Add the document ID
      rideList.add(data);
    }
    return rideList;
  } catch (e) {
    print('Error fetching rides: $e');
    return [];
  }
}

Future<Map?> getRideById(docID) async {
  Map<String, dynamic> rideList1 = {};
  try {
    var document =
        FirebaseFirestore.instance.collection('ride-table').doc(docID);
    var snapshot = await document.get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data();
      rideList1 = data ?? {}; // Use null-aware operator to handle null case
    }

    return rideList1;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<List?> getCartData(email) async {
  Future<Map> data;
  List rideList = [];
  Map rideList1 = {};
  List templist = [];
  try {
    var snapshot =
        await FirebaseFirestore.instance.collection('ride-table').get();
    for (var doc in snapshot.docs) {
      rideList1 = doc.data();
      rideList1.putIfAbsent('id', () => doc.id);
      //rideList1.putIfAbsent('id', () => doc.id);
      if (rideList1["riderList"] != null) {
        if (rideList1["riderList"].contains(email)) {
          rideList.add(rideList1);
        }
      }
    }
    return rideList;
  } catch (e) {}
  return null;
}

Future<dynamic> addRider(String riderEmail, String docID) async {
  try {
    var document =
        FirebaseFirestore.instance.collection('ride-table').doc(docID);

    var snapshot = await document.get();
    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data();
      var value = data?['riderList'];

      if (!value.contains(riderEmail) && value.length <= 5) {
        value.add(riderEmail);
        document.update({'riderList': value});
      }
    }
  } catch (e) {}
}

Future<Map<String, dynamic>?> getUserDataByUID(String uid) async {
  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('user data')
        .doc(uid) // Use the UID to fetch user data
        .get();
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    } else {
      print('No user profile found for UID: $uid');
      return null;
    }
  } catch (e) {
    print('Error fetching user profile by UID: $e');
    return null;
  }
}

Future<String> addCarDetails(String carModel, String licensePlate, int seatCapacity, bool isAirConditioned) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // Add a new document to 'CarDetails' with the car details
    DocumentReference carDetailsRef = await firestore.collection('CarDetails').add({
      'UserID': user.uid,
      'carModel': carModel,
      'licensePlate': licensePlate,
      'seatCapacity': seatCapacity,
      'isAirConditioned': isAirConditioned,
    });

    // This will give you the ID of the newly added car details document
    String carDetailsId = carDetailsRef.id;
    print('Car details added with ID: $carDetailsId');

    // Optionally, return the CarDetailsID if you need it elsewhere
    return carDetailsId;
  } else {
    print('No user is signed in.');
    return ''; // Return an empty string or handle the error as you see fit
  }
}

Future<void> addRideDetails(
  String startLocation,
  String endLocation,
  String time,
  String genderPreference,
  double price,
) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    var carDetailsQuery = await FirebaseFirestore.instance
        .collection('CarDetails')
        .where('UserID', isEqualTo: user.uid)
        .get();

    var carDetailsId =
        carDetailsQuery.docs.isNotEmpty ? carDetailsQuery.docs.first.id : null;

    if (carDetailsId == null) {
      throw Exception(
          'No car details found for user.'); // Throw an exception if no car details are found
    }

    // Use 'await' to wait for the add operation to complete
    await FirebaseFirestore.instance.collection('Rides Posted').add({
      'UserID': user.uid, // Link to the user
      'CarDetailsID': carDetailsId, // Link to the car details
      'Start Location': startLocation,
      'End Location': endLocation,
      'Time': time,
      'Gender Preference': genderPreference,
      'Price': price,
      'Accepted': 0,
      // Add other fields as needed
    }).then((docRef) {
      print('Ride added with ID: ${docRef.id}');
    }).catchError((error) {
      print('Error adding ride: $error');
      throw Exception(
          'Error adding ride: $error'); // Throw an exception if there's an error
    });
  } else {
    throw Exception(
        'No user is signed in.'); // Throw an exception if no user is signed in
  }
}
