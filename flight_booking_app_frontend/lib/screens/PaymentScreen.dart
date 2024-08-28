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
  Stripe.publishableKey = 'pk_test_51PsKYGDfeL7GR0IaV7aOHhCIVCDHZU4i9fxSVb7zHAuzu4T2srHPxCniMTPqIIMmpkdPtRHCnqHV4HMD8pYMuiDP00EpJCGmSi';

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
  bool isLoading=false;

  Future<String> _createPaymentIntent(int amount, String currency) async {
    final String paymentUrl = 'http://192.168.219.182:3000/api/payment/createPaymentIntent';


    try {
      setState(() {
        isLoading = true;
      });
      final response = await http.post(
        Uri.parse(paymentUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amount,
          'currency': currency,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final clientSecret = data['client_secret'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$clientSecret')),
        );
        print("Response: $data");

        return clientSecret;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create Payment Intent')),
        );
        return "";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );

      return "";
    }finally {
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
      final clientSecret = await _createPaymentIntent(10000,'inr');
      if (clientSecret != "") {
        await Stripe.instance.initPaymentSheet(paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: "Stripe Test",
        ));
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
      final paymentIntent = await Stripe.instance.retrievePaymentIntent(clientSecret);
      if (paymentIntent.status == PaymentIntentsStatus.RequiresAction) {
        // Handle next action, such as 3D Secure authentication
        await Stripe.instance.handleNextAction(clientSecret);

        // Check the payment status after handling the next action
        final updatedIntent = await Stripe.instance.retrievePaymentIntent(clientSecret);
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
    }finally {
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
            :ElevatedButton(
          onPressed: () async {
            await _makePayment();  // Example amount in cents
          },
          child: Text('Pay Now'),
        ),
      ),
    );
  }
}
