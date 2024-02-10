import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/util/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController erpController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  Map<String, String> initialValues = {};

  bool isLoading = true;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _fetchEmailAndProfile();
  }

  Future<void> _fetchEmailAndProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('useremail');

    if (userEmail == null || userEmail!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('')),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('user data')
          .where('Email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userQuery.docs.first;
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        initialValues = {
          'Email': data['Email'] ?? '',
          'ERP': data['ERP'] ?? '',
          'Gender': data['Gender'] ?? '',
          'Phone': data['Phone'] ?? '',
          'Username': data['Username'] ?? '',
        };
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No user profile found with this email')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profile: $e')),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> _saveUserProfile() async {
    User? user = auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user currently logged in')),
      );
      return;
    }

    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('user data').doc(user.uid);

    Map<String, String> updatedValues = {};

    // Function to check and add field if it's changed and not empty
  void updateField(String field, String currentValue, String initialValue) {
    if (currentValue.trim().isNotEmpty && currentValue.trim() != initialValue) {
      updatedValues[field] = currentValue.trim();
    }
  }

    // Check each field
    updateField('Email', emailController.text, initialValues['Email'] ?? '');
    updateField('ERP', erpController.text, initialValues['ERP'] ?? '');
    updateField('Gender', genderController.text, initialValues['Gender'] ?? '');
    updateField('Phone', phoneController.text, initialValues['Phone'] ?? '');
    updateField('Username', usernameController.text, initialValues['Username'] ?? '');

    if (updatedValues.isNotEmpty) {
      try {
        await userDocRef.update(updatedValues);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes to save')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: erpController,
                    decoration: const InputDecoration(
                      labelText: 'ERP',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: genderController,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveUserProfile,
                    child: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      onPrimary: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
