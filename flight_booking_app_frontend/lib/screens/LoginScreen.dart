import 'package:flight_booking_app_frontend/screens/HomeScreen.dart';
import 'package:flight_booking_app_frontend/screens/PaymentScreen.dart';
import 'package:flight_booking_app_frontend/utils/constants.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'SignUpScreen.dart';

Future<void> login(String email, String password) async {
  print("Login Handled");
  final url = '${Constants.baseUrl}/api/auth/login'; // Change to your backend URL
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (response.statusCode == 200) {
    print("Logged in response from backend");
  } else {
    // Handle error
    print("ERROR response from server: $response");
    throw Exception('Failed to log in');
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      await login(email, password);
      // Show success message or navigate to another screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        // MaterialPageRoute(builder: (context) => PaymentScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful')),
      );

    } catch (e) {
      print("Login ERROR : $e");
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log in')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _emailController.text='abhijeetbasfore@gmail.com';
    _passwordController.text='Abhijeet@123';

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleLogin,
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: Text('Don\'t have an account? Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}
