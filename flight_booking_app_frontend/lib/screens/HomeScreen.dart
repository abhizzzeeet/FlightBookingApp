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

  List<String> originSuggestions = [];
  List<String> destinationSuggestions = [];

  void fetchSuggestions(String input, bool isOrigin) async {
    if (input.isEmpty) return;

    // Replace with your backend endpoint
    String url = 'http://192.168.89.129:3000/api/flights/search?keyword=$input';

    try {
      final response = await Dio().get(url);

      List<String> suggestions = (response.data as List).map<String>((location) {
        return location['name'] as String; // Adjust based on your backend response structure
      }).toList();

      setState(() {
        if (isOrigin) {
          originSuggestions = suggestions;
          print("HomeScreen: ${originSuggestions}");
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
              TextField(
                controller: originController,
                decoration: InputDecoration(
                  labelText: 'Origin',
                ),
                onChanged: (value) => fetchSuggestions(value, true),
              ),
              if (originSuggestions.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: originSuggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(originSuggestions[index]),
                      onTap: () {
                        setState(() {
                          originController.text = originSuggestions[index];
                          originSuggestions = [];
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
                onChanged: (value) => fetchSuggestions(value, false),
              ),
              if (destinationSuggestions.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: destinationSuggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(destinationSuggestions[index]),
                      onTap: () {
                        setState(() {
                          destinationController.text = destinationSuggestions[index];
                          destinationSuggestions = [];
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
              TextField(
                controller: returnDateController,
                decoration: InputDecoration(
                  labelText: 'Return Date',
                ),
                readOnly: true,
                onTap: () => _selectDate(context, returnDateController),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Add your search logic here
                  print('Searching for flights...');
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
