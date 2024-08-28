import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      home: PaymentScreen(),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isLoading = false;

  Future<String> _createPaymentIntent(int amount, String currency) async {
    try {
      // isLoading = true;
      print("before making request");
      final url =
          'https://us-central1-flightbook-b446d.cloudfunctions.net/createPaymentIntentHTTP';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount.toString(),
          'currency': currency,
        }),
      );
      print("After making request");
      final jsonResponse = jsonDecode(response.body);

      // final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('createPaymentIntent');
      // final results = await callable.call(<String, dynamic>{
      //   'amount': amount,
      //   'currency': currency,
      // });
      final clientSecret = jsonResponse['clientSecret'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('clientSecret: $clientSecret')),
      );
      return clientSecret;
    } catch (e) {
      print("ERROR create payment intent: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ERROR create payment intent: $e')),
      );
      return "";
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _makePayment() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('pay pressed')),
    );
    try {
      final clientSecret = await _createPaymentIntent(10000, 'inr');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('clientSecret in makePayment: $clientSecret')),
      );
      if (clientSecret != "") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Before initPaymentSheet')),
        );
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: "Stripe Test",
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('After initPaymentSheet')),
        );
        await _displayPaymentSheet(clientSecret);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Error: $e')),
      );
    }
  }

  Future<void> _displayPaymentSheet(String clientSecret) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('presenting payment sheet')),
      );
      await Stripe.instance.presentPaymentSheet();
      await Stripe.instance.confirmPaymentSheetPayment();

      // Retrieve and check the payment intent status
      final paymentIntent =
          await Stripe.instance.retrievePaymentIntent(clientSecret);
      if (paymentIntent.status == PaymentIntentsStatus.RequiresAction) {
        // Handle next action, such as 3D Secure authentication
        await Stripe.instance.handleNextAction(clientSecret);

        // Check the payment status after handling the next action
        final updatedIntent =
            await Stripe.instance.retrievePaymentIntent(clientSecret);
        if (updatedIntent.status == PaymentIntentsStatus.Succeeded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment successful!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment failed: ${updatedIntent.status}')),
          );
        }
      } else if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment successful!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${paymentIntent.status}')),
        );
      }
    } catch (e) {
      print("Display Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error presenting payment sheet: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Screen'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () async {
                  await _makePayment(); // Example amount in cents
                },
                child: Text('Pay Now'),
              ),
      ),
    );
  }
}
