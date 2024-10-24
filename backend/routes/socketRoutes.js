// routes/socketRoutes.js

module.exports = function (io) {
  let lockedSeats = {};

    io.on('connection', (socket) => {
      console.log('New WebSocket connection established');
  
      // Handle room joining
      socket.on('joinRoom', (roomId) => {
        console.log(`Client joining room: ${roomId}`);
        socket.join(roomId);
        
        // Notify others in the room (optional)
        socket.to(roomId).emit('newUserJoined', `User joined room ${roomId}`);
        console.log(`New User has joined room: ${roomId}`);
      });
      
      
      
  
      // Handle messages
      socket.on('message', (data) => {
        console.log(`Received message from room ${data.roomId}: ${data.message}`);
        io.to(data.roomId).emit('messageFromServer', data.message);
      });
  
      

      // Handle seat lock
        socket.on('lockSeat', (data) => {
            const { roomId, seatNumber } = data;
            if (!lockedSeats[roomId]) {
                lockedSeats[roomId] = [];
            }

            // Lock the seat if it's not already locked
            if (!lockedSeats[roomId].includes(seatNumber)) {
                lockedSeats[roomId].push(seatNumber);
                io.to(roomId).emit('seatLocked', { seatNumber: seatNumber.toString() }); // Notify all users in the room
                console.log(`Seat ${seatNumber} locked in room ${roomId}`);
            } else {
                socket.emit('seatAlreadyLocked', { seatNumber: seatNumber.toString() }); // Notify user if seat is already locked
            }
        });
        
      // Handle seat unlock (optional)
        socket.on('unlockSeat', (data) => {
            const { roomId, seatNumber } = data;
            if (lockedSeats[roomId]) {
                lockedSeats[roomId] = lockedSeats[roomId].filter(seat => seat !== seatNumber);
                io.to(roomId).emit('seatUnlocked', { seatNumber: seatNumber.toString() }); // Notify all users in the room
                console.log(`Seat ${seatNumber} unlocked in room ${roomId}`);
            }
        });  

      socket.on('leaveRoom', (roomId) => {
        console.log(`Client leaving room: ${roomId}`);
        socket.leave(roomId); // Leave the room
      
        // Optionally notify others in the room
        socket.to(roomId).emit('userLeft', `User left room ${roomId}`);
      });
      
      // Handle disconnection
      socket.on('disconnect', () => {
        console.log('Client disconnected from WebSocket');
      });
    });
  };
  