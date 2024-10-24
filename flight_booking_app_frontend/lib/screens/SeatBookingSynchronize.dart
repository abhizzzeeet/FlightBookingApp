import 'package:dio/dio.dart';
import 'package:flight_booking_app_frontend/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SeatBookingSyncronize {
  final List<dynamic> seatMapData;
  late IO.Socket socket;
  final BuildContext context; // Add context to show Snackbar
  late List<String> roomIds = [];

  SeatBookingSyncronize(this.seatMapData, this.context) {
    _initializeSocket();
  }

  void _initializeSocket() {
    // Configure the Socket.IO connection
    socket = IO.io('${Constants.baseUrl}', <String, dynamic>{
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

    // Existing socket initialization
    socket.on('seatAlreadyLocked', (data) {
      String seatNumber = data['seatNumber'];

      // Notify the user that the seat is already locked
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seat $seatNumber is already locked')),
      );
    });

    socket.on('seatUnlocked', (data) {
      String seatNumber = data['seatNumber'];

      print('Seat $seatNumber is unlocked');
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
    return roomId.replaceAll(
        RegExp(r'[^a-zA-Z0-9]'), ''); // Removing non-alphanumeric characters
  }

  // Function to join a room using Socket.IO
  Future<void> joinRoom() async {
    for (int i = 0; i < roomIds.length; i++) {
      try {
        var roomId = roomIds[i];
        // Join the room on the Socket.IO side
        socket.emit('joinRoom', roomId);
        print('Joined room with ID: $roomId');
      } catch (error) {
        _showSnackBar('Error joining room: $error');
      }
    }
  }

  // Function to disconnect from a room
  Future<void> disconnectFromRoom() async {
    for (int i = 0; i < roomIds.length; i++) {
      try {
        var roomId = roomIds[i];
        socket.emit('leaveRoom', roomId);
      } catch (error) {
        _showSnackBar('Error leaving room: $error');
      }
    }
  }

  // Function to iterate through seatMapData and create/join rooms
  Future<void> synchronizeWithWebSocket() async {
    for (var seatMap in seatMapData) {
      String roomId =
          _generateRoomId(seatMap); // Generate roomId for each element
      roomIds.add(roomId);
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
