import 'dart:convert';

import 'package:flight_booking_app_frontend/screens/ChooseSeatScreen.dart';
import 'package:flight_booking_app_frontend/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/Traveller.dart';

class SelectTravellersScreen extends StatefulWidget {
  final Map<String, dynamic>? pricingData;
  SelectTravellersScreen({Key? key, this.pricingData}) : super(key: key);

  @override
  _SelectTravellersScreenState createState() => _SelectTravellersScreenState();
}

class _SelectTravellersScreenState extends State<SelectTravellersScreen> {
  List<Traveller> travellers = [
    Traveller(
      id: '1',
      firstName: '',
      lastName: '',
      dateOfBirth: '',
      gender: '',
      emailAddress: '',
      phoneCountryCode: '',
      phoneNumber: '',
      travellerType: 'ADULT',
    )
  ];
  bool isDomestic = true;
  late int numberOfTravellers = 0;

  @override
  void initState() {
    super.initState();
    // var travelerPricings = widget.pricingData?['data']?['flightOffers']?[0]['travelerPricings'] as List<dynamic>?;
    final travelers = widget.pricingData?['travelerPricings'] as List<dynamic>?;

    numberOfTravellers = travelers?.length ?? 1;
    print("SelectTravellersScreen Number of travellers: $numberOfTravellers");
    _checkTravelType();
  }

  Future<void> _checkTravelType() async {
    if (widget.pricingData != null) {
      final segments = widget.pricingData!['itineraries'] as List<dynamic>;
      final iataCodes = <String>{};
      final countryCodes = <String>[];

      for (var itinerary in segments) {
        for (var segment in itinerary['segments']) {
          iataCodes.add(segment['departure']['iataCode']);
          iataCodes.add(segment['arrival']['iataCode']);
        }
      }

      for (var code in iataCodes) {
        try {
          String countryCode = await _getCountryCode(code);
          if (!countryCodes.contains(countryCode)) {
            countryCodes.add(countryCode);
          }
        } catch (e) {
          print('Error fetching country code for $code: $e');
        }
      }

      setState(() {
        isDomestic = countryCodes.length == 1;
      });
    }
  }

  Future<String> _getCountryCode(String iataCode) async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/api/flights/checkCountry/$iataCode'),
    );
    print("Country Code response : ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['countryCode'];
    } else {
      throw Exception('Failed to load country code');
    }
  }

  void _addTraveller() {
    setState(() {
      travellers.add(Traveller(
        id: (travellers.length + 1).toString(),
        firstName: '',
        lastName: '',
        dateOfBirth: '',
        gender: '',
        emailAddress: '',
        phoneCountryCode: '',
        phoneNumber: '',
        travellerType: 'ADULT',
      ));
    });
  }

  void _removeTraveller(int index) {
    setState(() {
      travellers.removeAt(index);
    });
  }

  Future<void> _submitTravellers() async {
    if (travellers.length != numberOfTravellers) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter information for all travelers."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final travellersJson = travellers
        .map((traveller) => traveller.toJson(isDomestic: isDomestic))
        .toList();

    // Combine pricingData and traveller data
    final combinedData = {
      'data': {
        'type': 'flight-order',
        'flightOffers': widget.pricingData != null
            ? [widget.pricingData] // Wrap pricingData in an array
            : [], // Ensure it's an array even if null
        'travelers': travellersJson,
      }
    };

    print("Combined Data : ${json.encode(combinedData)}");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChooseSeatScreen(
          combinedData: combinedData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Travellers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: travellers.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            decoration:
                                InputDecoration(labelText: 'First Name'),
                            onChanged: (value) {
                              travellers[index].firstName = value;
                            },
                          ),
                          TextField(
                            decoration: InputDecoration(labelText: 'Last Name'),
                            onChanged: (value) {
                              travellers[index].lastName = value;
                            },
                          ),
                          TextField(
                            decoration:
                                InputDecoration(labelText: 'Date of Birth'),
                            onChanged: (value) {
                              travellers[index].dateOfBirth = value;
                            },
                          ),
                          TextField(
                            decoration: InputDecoration(labelText: 'Gender'),
                            onChanged: (value) {
                              travellers[index].gender = value;
                            },
                          ),
                          TextField(
                            decoration:
                                InputDecoration(labelText: 'Email Address'),
                            onChanged: (value) {
                              travellers[index].emailAddress = value;
                            },
                          ),
                          TextField(
                            decoration: InputDecoration(
                                labelText: 'Phone Country Code'),
                            onChanged: (value) {
                              travellers[index].phoneCountryCode = value;
                            },
                          ),
                          TextField(
                            decoration:
                                InputDecoration(labelText: 'Phone Number'),
                            onChanged: (value) {
                              travellers[index].phoneNumber = value;
                            },
                          ),
                          if (!isDomestic) ...[
                            TextField(
                              decoration:
                                  InputDecoration(labelText: 'Document Type'),
                              onChanged: (value) {
                                travellers[index].documentType = value;
                              },
                            ),
                            TextField(
                              decoration:
                                  InputDecoration(labelText: 'Document Number'),
                              onChanged: (value) {
                                travellers[index].documentNumber = value;
                              },
                            ),
                            TextField(
                              decoration: InputDecoration(
                                  labelText: 'Document Expiry Date'),
                              onChanged: (value) {
                                travellers[index].documentExpiry = value;
                              },
                            ),
                            TextField(
                              decoration:
                                  InputDecoration(labelText: 'Birth Place'),
                              onChanged: (value) {
                                travellers[index].birthPlace = value;
                              },
                            ),
                            TextField(
                              decoration: InputDecoration(
                                  labelText: 'Issuance Location'),
                              onChanged: (value) {
                                travellers[index].issuanceLocation = value;
                              },
                            ),
                            TextField(
                              decoration:
                                  InputDecoration(labelText: 'Issuance Date'),
                              onChanged: (value) {
                                travellers[index].issuanceDate = value;
                              },
                            ),
                            TextField(
                              decoration: InputDecoration(
                                  labelText: 'Issuance Country'),
                              onChanged: (value) {
                                travellers[index].issuanceCountry = value;
                              },
                            ),
                            TextField(
                              decoration: InputDecoration(
                                  labelText: 'Validity Country'),
                              onChanged: (value) {
                                travellers[index].validityCountry = value;
                              },
                            ),
                            TextField(
                              decoration:
                                  InputDecoration(labelText: 'Nationality'),
                              onChanged: (value) {
                                travellers[index].nationality = value;
                              },
                            ),
                            TextField(
                              decoration: InputDecoration(labelText: 'Holder'),
                              onChanged: (value) {
                                travellers[index].holder =
                                    value.toLowerCase() == 'true';
                              },
                            ),
                          ],
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _removeTraveller(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addTraveller,
              child: Text('Add Traveller'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitTravellers,
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
