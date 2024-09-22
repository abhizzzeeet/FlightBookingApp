import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SeatBookingSyncronize {
  final List<dynamic> seatMapData;
  late IO.Socket socket;
  final BuildContext context; // Add context to show Snackbar

  SeatBookingSyncronize(this.seatMapData, this.context) {
    _initializeSocket();
  }

  void _initializeSocket() {
    // Configure the Socket.IO connection
    socket = IO.io('http://192.168.232.90:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // Connect to the Socket.IO server
    socket.connect();

    // Handle connection events
    socket.onConnect((_) {
      print('Socket connected');
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
    });

    // Add any other socket event listeners as needed
  }

  String _generateRoomId(Map<String, dynamic> seatMap) {
    String carrierCode = seatMap['carrierCode'];
    String flightNumber = seatMap['number'];
    String departureCode = seatMap['departure']['iataCode'];
    String arrivalCode = seatMap['arrival']['iataCode'];
    String departureAt = seatMap['departure']['at'];
    String arrivalAt = seatMap['arrival']['at'];

    // Combine all elements without spaces
    String roomId =
        '$carrierCode$flightNumber$departureCode$arrivalCode$departureAt$arrivalAt';
    return roomId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ''); // Removing non-alphanumeric characters
  }

  // Function to join a room using Socket.IO
  Future<void> _joinRoom(String roomId) async {
    try {
      // Join the room on the Socket.IO side
      socket.emit('joinRoom', roomId);
      print('Joined room with ID: $roomId');
    } catch (error) {
      _showSnackBar('Error joining room: $error');
    }
  }

  // Function to iterate through seatMapData and create/join rooms
  Future<void> synchronizeWithWebSocket() async {
    for (var seatMap in seatMapData) {
      String roomId = _generateRoomId(seatMap); // Generate roomId for each element
      await _joinRoom(roomId); // Call the backend for each room
    }
  }

  // Function to show Snackbar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
