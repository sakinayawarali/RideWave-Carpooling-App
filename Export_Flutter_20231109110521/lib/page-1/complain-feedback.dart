import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class feedback extends StatelessWidget {
  const feedback({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complain',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Your Image.asset and other widgets go here
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Complain',
                border: OutlineInputBorder(),
              ),
              items: <String>['Vehicle not clean', 'Late arrival', 'Other']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                // handle change
              },
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Write your complain here (minimum 10 characters)',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color(0xff008955),
                minimumSize: Size(double.infinity, 54), // Specific height
              ),
              onPressed: () {
                // Submit action
              },
              child: Text(
                'Submit',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
