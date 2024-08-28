import 'package:flight_booking_app_frontend/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';


void main() async {
  await _setup();
  runApp(const MyApp());
}

Future<void> _setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_51PsKYGDfeL7GR0IaV7aOHhCIVCDHZU4i9fxSVb7zHAuzu4T2srHPxCniMTPqIIMmpkdPtRHCnqHV4HMD8pYMuiDP00EpJCGmSi';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login SignUp Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen()
    );
  }
}



