import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'MyBookingsScreen.dart';

void main() async {
  await _setup();
  runApp(MyApp());
}

Future<void> _setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
  'pk_test_51PsKYGDfeL7GR0IaV7aOHhCIVCDHZU4i9fxSVb7zHAuzu4T2srHPxCniMTPqIIMmpkdPtRHCnqHV4HMD8pYMuiDP00EpJCGmSi';
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PaymentScreen(amount: 10000, combinedData: {}),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  final double amount;
  final Map<String, Map<String, Object?>> combinedData;

  PaymentScreen({required this.amount, required this.combinedData});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isLoading = true;  // Show loading indicator initially

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _makePayment(); // Call makePayment after widget is fully built
    });
  }

  Future<String> _createPaymentIntent(double amount, String currency) async {
    try {
      amount = amount * 100;
      int amt = amount.toInt();
      print("before making request");
      final url =
          'https://us-central1-flightbook-b446d.cloudfunctions.net/createPaymentIntentHTTP';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amt.toString(),
          'currency': currency,
        }),
      );
      print("After making request");
      final jsonResponse = jsonDecode(response.body);
      final clientSecret = jsonResponse['clientSecret'];
      return clientSecret;
    } catch (e) {
      print("ERROR create payment intent: $e");
      return "";
    }
  }

  Future<void> _makePayment() async {
    try {
      final clientSecret = await _createPaymentIntent(widget.amount, 'inr');
      if (clientSecret != "") {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: "Stripe Test",
          ),
        );
        await _displayPaymentSheet(clientSecret);
      }
    } catch (e) {
      print("Payment Error: $e");
    }
  }

  Future<void> _displayPaymentSheet(String clientSecret) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MyBookingsScreen(combinedData: widget.combinedData),
        ),
      );
    } catch (e) {
      print("Display Error: $e");
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator after processing
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Screen'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Center(child: Text('Processing Payment...')), // Show processing message
    );
  }
}
