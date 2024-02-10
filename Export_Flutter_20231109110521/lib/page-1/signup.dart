import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/page-1/signin.dart';
import '../util/database.dart'; // Import the auth.dart file

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController erpController = TextEditingController();

  String? selectedGender;
  List<String> genderOptions = ['Male', 'Female'];

  bool isEmailValid(String email) {
    return email.endsWith('@khi.iba.edu.pk');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: const Text(
                'Sign Up',
                style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                    fontSize: 30),
              ),
            ),
            const Divider(height: 10),
            // Email TextField
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                key: const ValueKey("emailID"),
                controller: emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email ID',
                ),
              ),
            ),
            // Username TextField
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                key: const ValueKey("userName"),
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'User Name',
                ),
              ),
            ),
            // Password TextField
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                key: const ValueKey("password"),
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            // Confirm Password TextField
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                key: const ValueKey("confirmPassword"),
                obscureText: true,
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Confirm Password',
                ),
              ),
            ),
            // Phone Number TextField
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                key: const ValueKey("number"),
                controller: phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(13),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Phone Number (Pakistani)',
                ),
              ),
            ),
            // Gender Dropdown
            Container(
              padding: const EdgeInsets.all(10),
              child: DropdownButtonFormField<String>(
                key: const ValueKey("gender"),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Gender',
                ),
                value: selectedGender,
                items: genderOptions.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
              ),
            ),
            // ERP System TextField
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                key: const ValueKey("erp"),
                controller: erpController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'ERP System (Max 5 digits)',
                ),
              ),
            ),
            // Submit Button
            Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ElevatedButton(
                key: const ValueKey("submit"),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                ),
                child: const Text('Create Account'),
                onPressed: () async {
                  // Validation logic here
                  if (emailController.text.isEmpty ||
                      nameController.text.isEmpty ||
                      passwordController.text.isEmpty ||
                      confirmPasswordController.text.isEmpty ||
                      phoneController.text.isEmpty ||
                      selectedGender == null ||
                      erpController.text.isEmpty ||
                      passwordController.text !=
                          confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Please fill in all the fields correctly')),
                    );
                    return;
                  }
                  // Check if the email has the valid domain
                  if (!isEmailValid(emailController.text)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Use your @khi.iba.edu.pk email')),
                    );
                    return;
                  }

                  // Call the registerUser function
                  String result = await registerUser(
                    nameController.text,
                    emailController.text,
                    phoneController.text,
                    selectedGender!,
                    erpController.text,
                    passwordController.text, // Pass the password here
                  );
                  // Check the result and handle accordingly
                  if (result == 'Success') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              result)), // Display the error message from the result
                    );
                  }
                },
              ),
            ),

            // Sign In navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Already have an account? "),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                  child: const Text(
                    'Sign in',
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EmailFieldValidator {
  static String? validate(String value) {
    return value.isEmpty ? 'Email cannot be empty' : null;
  }
}

bool isPakistaniNumber(String phoneNumber) {
  // Implement your logic to validate Pakistani numbers
  // For example, check if the number starts with the Pakistani country code '+92'
  return phoneNumber.startsWith('+92');
}

class PhoneNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Return the input text as is, without adding '+92'
    return newValue;
  }
}
