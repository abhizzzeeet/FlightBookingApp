import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChooseSeatScreen extends StatefulWidget {
  final Map<String, Map<String, Object?>> combinedData;

  ChooseSeatScreen({required this.combinedData});

  @override
  _ChooseSeatScreenState createState() => _ChooseSeatScreenState();
}

class _ChooseSeatScreenState extends State<ChooseSeatScreen> {
  Map<String, dynamic>? seatMapData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSeatMap();
  }

  Future<void> _fetchSeatMap() async {
    Dio dio = Dio();
    final url = 'http://192.168.229.79:3000/api/flights/flightSeatMap';

    try {
      final response = await dio.post(
        url,
        data: {'pricingData': widget.combinedData['pricingData']},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          seatMapData = response.data; // No need to decode, Dio handles it
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load seat map');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error during the request: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Seat'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seat Map:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            seatMapData != null
                ? Text(
              json.encode(seatMapData),
              style: TextStyle(fontSize: 16),
            )
                : Text(
              'No seat map available',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            // Add more widgets to visualize the seat map here
          ],
        ),
      ),
    );
  }
}
