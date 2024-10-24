import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../utils/constants.dart';
import 'ReviewFlightScreen.dart';

class SearchFlightScreen extends StatefulWidget {
  final String origin;
  final String destination;
  final String departureDate;
  final String? returnDate;
  final int adults;
  final int children;
  final String travelClass;

  SearchFlightScreen({
    required this.origin,
    required this.destination,
    required this.departureDate,
    required this.returnDate,
    required this.adults,
    required this.children,
    required this.travelClass,
  });

  @override
  _SearchFlightScreenState createState() => _SearchFlightScreenState();
}

class _SearchFlightScreenState extends State<SearchFlightScreen> {
  List<dynamic> flights = [];

  @override
  void initState() {
    super.initState();
    _fetchFlights();
  }

  Future<void> _fetchFlights() async {
    final url = '${Constants.baseUrl}/api/flights/searchAvailableFlights';
    final params = {
      'origin': widget.origin,
      'destination': widget.destination,
      'departureDate': widget.departureDate,
      'returnDate': widget.returnDate,
      'adults': widget.adults.toString(),
      'children': widget.children.toString(),
      'travelClass': widget.travelClass,
      'currency': 'INR'  // Assuming you want INR; adjust if needed
    };

    try {
      final response = await Dio().get(url, queryParameters: params);
      setState(() {
        flights = response.data['data']; // Adjust based on the actual API response structure
        print("SearchFlightScreen: ${flights}");
      });
    } catch (e) {
      print('Error fetching flights: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch flights')),
      );
    }
  }
  // Function to format the time portion of the datetime string
  String formatTime(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat.Hm().format(dateTime);
    } catch (e) {
      print('Error formatting time: $e');
      return '';
    }
  }
  String formatDuration(String duration) {
    final match = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?').firstMatch(duration);
    return '${match?.group(1) ?? '0'}hr ${match?.group(2) ?? '0'}min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flight Search Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: flights.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: flights.length,
          itemBuilder: (context, index) {
            final flight = flights[index];
            final itineraries = flight['itineraries'] as List<dynamic>;
            final segments = itineraries[0]['segments'] as List<dynamic>;
            final outbound = segments[0];
            final arrivalSegment = segments.last;

            // Calculate number of stops
            final numberOfStops = segments.length - 1;

            // Extract flight company and flight number
            final carrierCode = outbound['carrierCode'];
            final flightNumber = outbound['number'];

            // Concatenate carrier code and flight number
            final carrierAndNumber = '$carrierCode $flightNumber';


            // Format departure and arrival times
            final departureTime = formatTime(outbound['departure']['at']);
            final arrivalTime = formatTime(arrivalSegment['arrival']['at']);

            // Format duration
            final duration = itineraries[0]['duration'];
            final durationInHrMin = formatDuration(duration);

            // Determine stop text
            final stopsText = numberOfStops == 0 ? 'Non-stop' : '$numberOfStops stop';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewFlightScreen(
                      flightData: flight,
                    ),
                  ),
                );
              },
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text('$carrierAndNumber'),
                      SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Row with the horizontal line between departure and arrival times
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(departureTime),
                                    Text('${outbound['departure']['iataCode']}'),
                                  ],
                                ),
                              ),
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('$durationInHrMin'),
                                  SizedBox(height: 4),
                                  Divider(),
                                  SizedBox(height: 4),
                                  // Stops text below the line
                                  Text(stopsText),
                                ],
                              )),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(arrivalTime),
                                    Text('${arrivalSegment['arrival']['iataCode']}'),
                                  ],
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Spacer(),  // Pushes the price to the right
                          Text(
                            '${flight['price']['grandTotal']} ${flight['price']['currency']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
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



}
