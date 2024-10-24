import 'package:flight_booking_app_frontend/utils/constants.dart';

import 'SearchFlightScreen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // For making HTTP requests
import 'package:intl/intl.dart'; // For formatting dates

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController originController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController departureDateController = TextEditingController();
  TextEditingController returnDateController = TextEditingController();
  TextEditingController adultsController = TextEditingController(text: '1');
  TextEditingController childrenController = TextEditingController(text: '0');

  String? selectedTravelClass = 'ECONOMY';
  List<String> travelClassOptions = [
    'ECONOMY',
    'PREMIUM_ECONOMY',
    'BUSINESS',
    'FIRST'
  ];

  bool isRoundTrip = false; // To toggle between One Way and Round Trip

  List<Map<String, String>> originSuggestions = [];
  List<Map<String, String>> destinationSuggestions = [];

  bool originSelected = false;
  bool destinationSelected = false;

  void fetchSuggestions(String input, bool isOrigin) async {
    if (input.isEmpty) return;

    // Replace with your backend endpoint
    String url = '${Constants.baseUrl}/api/flights/search?keyword=$input';

    try {
      final response = await Dio().get(url);

      List<Map<String, String>> suggestions =
      (response.data as List).map<Map<String, String>>((location) {
        return {
          'name': location['name'] as String,
          'iataCode': location['iataCode'] as String,
        };
      }).toList();

      setState(() {
        if (isOrigin) {
          originSuggestions = suggestions;
        } else {
          destinationSuggestions = suggestions;
        }
      });
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flight Booking'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Toggle between One Way and Round Trip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Trip Type:'),
                  DropdownButton<bool>(
                    value: isRoundTrip,
                    items: [
                      DropdownMenuItem<bool>(
                        value: false,
                        child: Text('One Way'),
                      ),
                      DropdownMenuItem<bool>(
                        value: true,
                        child: Text('Round Trip'),
                      ),
                    ],
                    onChanged: (bool? newValue) {
                      setState(() {
                        isRoundTrip = newValue!;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: originController,
                decoration: InputDecoration(
                  labelText: 'Origin',
                ),
                onChanged: (value) {
                  fetchSuggestions(value, true);
                  originSelected = false; // Reset selected status on input change
                },
              ),
              if (originSuggestions.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: originSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = originSuggestions[index];
                    return ListTile(
                      title: Text('${suggestion['name']} (${suggestion['iataCode']})'),
                      onTap: () {
                        setState(() {
                          originController.text = suggestion['iataCode']!;
                          originSuggestions = [];
                          originSelected = true; // Mark option as selected
                        });
                      },
                    );
                  },
                ),
              SizedBox(height: 20),
              TextField(
                controller: destinationController,
                decoration: InputDecoration(
                  labelText: 'Destination',
                ),
                onChanged: (value) {
                  fetchSuggestions(value, false);
                  destinationSelected = false; // Reset selected status on input change
                },
              ),
              if (destinationSuggestions.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: destinationSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = destinationSuggestions[index];
                    return ListTile(
                      title: Text('${suggestion['name']} (${suggestion['iataCode']})'),
                      onTap: () {
                        setState(() {
                          destinationController.text = suggestion['iataCode']!;
                          destinationSuggestions = [];
                          destinationSelected = true; // Mark option as selected
                        });
                      },
                    );
                  },
                ),
              SizedBox(height: 20),
              TextField(
                controller: departureDateController,
                decoration: InputDecoration(
                  labelText: 'Departure Date',
                ),
                readOnly: true,
                onTap: () => _selectDate(context, departureDateController),
              ),
              SizedBox(height: 20),
              if (isRoundTrip) // Show return date only if Round Trip is selected
                TextField(
                  controller: returnDateController,
                  decoration: InputDecoration(
                    labelText: 'Return Date',
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, returnDateController),
                ),
              SizedBox(height: 20),
              TextField(
                controller: adultsController,
                decoration: InputDecoration(
                  labelText: 'Number of Adults',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              TextField(
                controller: childrenController,
                decoration: InputDecoration(
                  labelText: 'Number of Children',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedTravelClass,
                items: travelClassOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Travel Class',
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTravelClass = newValue;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (!originSelected || !destinationSelected) {
                    if (!originSelected) {
                      originController.clear(); // Clear if not selected
                    }
                    if (!destinationSelected) {
                      destinationController.clear(); // Clear if not selected
                    }
                    return;
                  }
                  if (departureDateController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select a departure date.'),
                      ),
                    );
                    return;
                  }

                  // Pass null for returnDate if not round trip
                  String? returnDate = isRoundTrip ? returnDateController.text : null;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchFlightScreen(
                        origin: originController.text,
                        destination: destinationController.text,
                        departureDate: departureDateController.text,
                        returnDate: returnDate,
                        adults: int.tryParse(adultsController.text) ?? 1,
                        children: int.tryParse(childrenController.text) ?? 0,
                        travelClass: selectedTravelClass!, // Pass the selected travel class
                      ),
                    ),
                  );
                },
                child: Text('Search'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
