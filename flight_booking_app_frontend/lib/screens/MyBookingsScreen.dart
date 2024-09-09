import 'package:flutter/material.dart';

class MyBookingsScreen extends StatelessWidget {
  final Map<String, Map<String, Object?>> combinedData;

  MyBookingsScreen({required this.combinedData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
      ),
      body: Center(
        child: Text('Booking Data: ${combinedData.toString()}'),
      ),
    );
  }
}
