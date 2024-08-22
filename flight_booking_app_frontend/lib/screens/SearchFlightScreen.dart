import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

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
    final url = 'http://192.168.219.182:3000/api/flights/searchAvailableFlights';
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
                      Text(
                        'Flight ${flight['id']}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Carrier: $carrierCode'),
                      Text('Flight Number: $flightNumber'),
                      SizedBox(height: 8),
                      Text('Departure: ${outbound['departure']['at']}'),
                      Text('Arrival: ${arrivalSegment['arrival']['at']}'),
                      Text('Duration: ${itineraries[0]['duration']}'),
                      SizedBox(height: 8),
                      Text('Number of Stops: $numberOfStops'),
                      SizedBox(height: 8),
                      Text('Price: ${flight['price']['grandTotal']} ${flight['price']['currency']}'),
                      SizedBox(height: 8),
                      Text('Origin IATA: ${outbound['departure']['iataCode']}'),
                      Text('Destination IATA: ${arrivalSegment['arrival']['iataCode']}'),
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
