import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'SelectTravellersScreen.dart';

class ReviewFlightScreen extends StatefulWidget {
  final Map<String, dynamic> flightData;

  ReviewFlightScreen({required this.flightData});

  @override
  _ReviewFlightScreenState createState() => _ReviewFlightScreenState();
}

class _ReviewFlightScreenState extends State<ReviewFlightScreen> {
  Map<String, dynamic>? pricingData;

  @override
  void initState() {
    super.initState();
    _fetchPricing();
  }

  Future<void> _fetchPricing() async {
    final url = '${Constants.baseUrl}/api/flights/price';

    try {
      final response = await Dio().post(url, data: widget.flightData);
      setState(() {
        pricingData = response.data['data']['flightOffers'][0];
      });
      print("PricingData : $pricingData");
    } catch (e) {
      print('Error fetching pricing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Flight'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: pricingData == null
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Flight ${pricingData?['id']}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Carrier: ${pricingData?['itineraries'][0]['segments'][0]['carrierCode']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Flight No: ${pricingData?['itineraries'][0]['segments'][0]['number']}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Departure: ${pricingData?['itineraries'][0]['segments'][0]['departure']['at']}',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Arrival: ${pricingData?['itineraries'][0]['segments'].last['arrival']['at']}',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Duration: ${pricingData?['itineraries'][0]['duration']}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              Text(
                'Number of Stops: ${(pricingData?['itineraries'][0]['segments'].length ?? 1) - 1}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              Text(
                'Price Details:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Total Price: ${pricingData?['price']['total']} ${pricingData?['price']['currency']}',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Base Price: ${pricingData?['price']['base']} ${pricingData?['price']['currency']}',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Fees: ${pricingData?['price']['fees'].map((fee) => "${fee['type']}: ${fee['amount']} ${pricingData?['price']['currency']}").join(", ")}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              Text(
                'Origin IATA: ${pricingData?['itineraries'][0]['segments'][0]['departure']['iataCode']}',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Destination IATA: ${pricingData?['itineraries'][0]['segments'].last['arrival']['iataCode']}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectTravellersScreen(
                        pricingData: pricingData, // Pass flight data to the next screen
                      ),
                    ),
                  );
                },
                child: Text('Continue'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
