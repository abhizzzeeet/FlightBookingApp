import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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
    final url = 'http://192.168.219.182:3000/api/flights/flightSeatMap';

    var flightOffers = widget.combinedData['data']?['flightOffers'];

    if (flightOffers != null) {
      try {
        final response = await dio.post(
          url,
          data: {'data': flightOffers},
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ),
        );

        if (response.statusCode == 200) {
          setState(() {
            seatMapData = response.data;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print('Failed to load seat map. Status code: ${response.statusCode}');
        }
      } catch (error) {
        setState(() {
          isLoading = false;
        });
        print('Error during the request: $error');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print('Error: flightOffers is null');
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
                ? _buildSeatMaps()
                : Text(
              'No seat map available',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatMaps() {
    List<Widget> deckWidgets = [];
    final seatMaps = seatMapData?['data'];

    if (seatMaps is List) {
      for (var seatMap in seatMaps) {
        final seatClass = seatMap['seatClass'] ?? 'Unknown'; // Get the seat class
        final decks = seatMap['decks'];

        if (decks is List) {
          for (var deck in decks) {
            final seats = deck['seats'];
            final width = deck['deckConfiguration']['width'];
            final length = deck['deckConfiguration']['length'];

            List<List<Map<String, dynamic>>> seatMatrix = List.generate(
              length,
                  (index) => List.generate(width, (index) => {}),
            );

            for (var seat in seats) {
              int x = seat['coordinates']['x'];
              int y = seat['coordinates']['y'];

              if (x >= 0 && x < width && y >= 0 && y < length) {
                seatMatrix[y][x] = seat;
              } else {
                print('Warning: Seat with coordinates ($x, $y) is out of bounds.');
              }
            }

            deckWidgets.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Class: $seatClass', // Display seat class
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Deck: ${deck['deckType'] ?? 'Unknown'}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Column(
                      children: List.generate(
                        length,
                            (rowIndex) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            width,
                                (colIndex) {
                              final seat = seatMatrix[rowIndex][colIndex];
                              if (seat.isEmpty) {
                                return SizedBox(width: 40, height: 40); // Empty space
                              }
                              return SeatWidget(
                                seatNumber: seat['number'],
                                status: seat['travelerPricing'][0]['seatAvailabilityStatus'],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        } else {
          print('Error: Decks data is not in the expected format.');
        }
      }
    } else {
      print('Error: SeatMaps data is not in the expected format.');
    }

    return Column(children: deckWidgets);
  }
}

class SeatWidget extends StatelessWidget {
  final String seatNumber;
  final String status;

  SeatWidget({required this.seatNumber, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'AVAILABLE':
        color = Colors.green;
        break;
      case 'BLOCKED':
        color = Colors.grey;
        break;
      default:
        color = Colors.red;
    }

    return Container(
      margin: EdgeInsets.all(4.0),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Center(
        child: Text(
          seatNumber,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
