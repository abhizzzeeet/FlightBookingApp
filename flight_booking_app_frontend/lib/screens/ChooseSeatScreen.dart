import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'PaymentScreen.dart';

class ChooseSeatScreen extends StatefulWidget {
  final Map<String, Map<String, Object?>> combinedData;

  ChooseSeatScreen({required this.combinedData});

  @override
  _ChooseSeatScreenState createState() => _ChooseSeatScreenState();
}

class _ChooseSeatScreenState extends State<ChooseSeatScreen> {
  List<Map<String, dynamic>> seatMapPages = [];
  bool isLoading = true;
  Map<String, dynamic> selectedSeats = {}; // Map to track selected seats and their prices
  Map<int, int> selectedSeatsPerPage = {}; // Map to track selected seats per page
  double totalAmount = 0.0;
  late int numberOfTravellers;

  @override
  void initState() {
    super.initState();
    final dataMap = widget.combinedData['data'] as Map<String, dynamic>?;
    final flightOffers = dataMap?['flightOffers'] as List<dynamic>?;
    final travelers = dataMap?['travelers'] as List<dynamic>?;
    if (flightOffers != null && flightOffers.isNotEmpty) {
      final priceMap = flightOffers[0]['price'] as Map<String, dynamic>?;
      totalAmount = double.parse(priceMap?['total'] ?? '0.0');
    }
    numberOfTravellers = travelers?.length ?? 1;
    print("Number of travelers in ChooseSeatScreen $numberOfTravellers");
    _fetchSeatMap();
  }

  Future<void> _fetchSeatMap() async {
    Dio dio = Dio();
    final url = 'http://192.168.232.90:3000/api/flights/flightSeatMap';

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
          final seatMapData = response.data['data'];
          _createSeatMapPages(seatMapData);
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

  void _createSeatMapPages(List<dynamic> seatMapData) {
    for (var seatMap in seatMapData) {
      final departureCode = seatMap['departure']['iataCode'] ?? 'Unknown';
      final arrivalCode = seatMap['arrival']['iataCode'] ?? 'Unknown';
      final decks = seatMap['decks'];

      if (decks is List) {
        seatMapPages.add({
          'departureCode': departureCode,
          'arrivalCode': arrivalCode,
          'decks': decks,
        });
      } else {
        print('Error: Decks data is not in the expected format.');
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  void _onSeatSelected(int pageIndex, String seatNumber, double seatPrice) {
    setState(() {
      int currentPageSelection = selectedSeatsPerPage[pageIndex] ?? 0;

      if (selectedSeats.containsKey(seatNumber)) {
        // Deselect seat if already selected
        totalAmount -= selectedSeats[seatNumber]['price'];
        selectedSeats.remove(seatNumber);
        selectedSeatsPerPage[pageIndex] = currentPageSelection - 1;
      } else {
        // Select seat
        if (currentPageSelection < numberOfTravellers) {
          selectedSeats[seatNumber] = {'price': seatPrice};
          selectedSeatsPerPage[pageIndex] = currentPageSelection + 1;
          totalAmount += seatPrice;
          _showPricePopup(seatNumber, seatPrice);
        } else {
          // Show a message if more seats are selected than allowed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Maximum number of seats selected on this page.')),
          );
        }
      }
    });
  }

  void _showPricePopup(String seatNumber, double seatPrice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seat Selected'),
          content: Text('Seat $seatNumber selected. Price: \$${seatPrice.toStringAsFixed(2)}'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Seat'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: seatMapPages.length,
              itemBuilder: (context, index) {
                final pageData = seatMapPages[index];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${pageData['departureCode']} to ${pageData['arrivalCode']}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16.0),
                      _buildSeatMap(index, pageData['decks']),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to PaymentScreen and pass totalAmount
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(amount: totalAmount,combinedData: widget.combinedData),
                  ),
                );
              },
              child: Text(
                'Pay: Rs${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatMap(int pageIndex, List<dynamic> decks) {
    return Column(
      children: decks.map<Widget>((deck) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deck: ${deck['deckType'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            _buildDeckSeats(pageIndex, deck),
            SizedBox(height: 16.0), // Space between decks
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDeckSeats(int pageIndex, Map<String, dynamic> deck) {
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

      if (x >= 0 && x < length && y >= 0 && y < width) {
        seatMatrix[x][y] = seat;
      } else {
        print('Warning: Seat with coordinates ($x, $y) is out of bounds.');
      }
    }

    return Column(
      children: List.generate(
        length,
            (rowIndex) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            width,
                (colIndex) {
              final seat = seatMatrix[rowIndex][colIndex];
              if (seat.isEmpty) {
                return SizedBox(width: 30, height: 30); // Reduced size for empty space
              }
              bool isSelected = selectedSeats.containsKey(seat['number']);
              return GestureDetector(
                onTap: () {
                  print("Seat Clicked");
                  double seatPrice = double.parse(seat['travelerPricing'][0]['price']['total'] ?? '0.0');
                  _onSeatSelected(pageIndex, seat['number'], seatPrice);
                },
                child: SeatWidget(
                  seatNumber: seat['number'],
                  status: seat['travelerPricing'][0]['seatAvailabilityStatus'],
                  isSelected: isSelected,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class SeatWidget extends StatelessWidget {
  final String seatNumber;
  final String status;
  final bool isSelected;

  SeatWidget({
    required this.seatNumber,
    required this.status,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    if (isSelected) {
      color = Colors.blue; // Color for selected seat
    } else {
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
    }

    return Container(
      margin: EdgeInsets.all(2.0), // Reduced margin for better spacing
      width: 20, // Reduced width
      height: 20, // Reduced height
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Center(
        child: Text(
          seatNumber,
          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), // Adjust font size
        ),
      ),
    );
  }
}
