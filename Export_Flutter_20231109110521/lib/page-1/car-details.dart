import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/page-1/home.dart';
import 'package:myapp/util/database.dart';

class CarDetails extends StatefulWidget {
  final Map userdata;

  const CarDetails({Key? key, required this.userdata}) : super(key: key);

  @override
  _CarDetailsState createState() => _CarDetailsState();
}

class _CarDetailsState extends State<CarDetails> {
  bool isAirConditioned = true; // Initial value for air conditioning
  TextEditingController seatCapacityController = TextEditingController();
  TextEditingController licensePlateController = TextEditingController();
  TextEditingController carModelController = TextEditingController();

  @override
  void dispose() {
    seatCapacityController.dispose();
    licensePlateController.dispose();
    carModelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Car Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: seatCapacityController,
              decoration: const InputDecoration(
                labelText: 'Seat Capacity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: licensePlateController,
              decoration: const InputDecoration(
                labelText: 'License Plate (Without dashes)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: carModelController,
              decoration: const InputDecoration(
                labelText: 'Car Model',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Air Conditioning',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Yes'),
                    leading: Radio<bool>(
                      value: true,
                      groupValue: isAirConditioned,
                      onChanged: (bool? value) {
                        setState(() {
                          isAirConditioned = value!;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('No'),
                    leading: Radio<bool>(
                      value: false,
                      groupValue: isAirConditioned,
                      onChanged: (bool? value) {
                        setState(() {
                          isAirConditioned = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                int seatCapacity = int.tryParse(seatCapacityController.text) ??
                    0; // Add error handling as necessary
                String carModel = carModelController.text;
                String licensePlate = licensePlateController.text;
                bool airConditioned = isAirConditioned;

                // Call the method to add car details to the database
                await addCarDetails(
                    carModel, licensePlate, seatCapacity, airConditioned);

                // After updating, navigate back to the HomePage
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HomePage(userdata: widget.userdata)),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Update'),
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
