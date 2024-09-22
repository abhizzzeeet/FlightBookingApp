// routes/socketRoutes.js

module.exports = function (io) {
    io.on('connection', (socket) => {
      console.log('New WebSocket connection established');
  
      // Handle room joining
      socket.on('joinRoom', (roomId) => {
        console.log(`Client joining room: ${roomId}`);
        socket.join(roomId);
        
        // Notify others in the room (optional)
        socket.to(roomId).emit('newUserJoined', `User joined room ${roomId}`);
      });
  
      // Handle messages
      socket.on('message', (data) => {
        console.log(`Received message from room ${data.roomId}: ${data.message}`);
        io.to(data.roomId).emit('messageFromServer', data.message);
      });
  
      // Handle disconnection
      socket.on('disconnect', () => {
        console.log('Client disconnected from WebSocket');
      });
    });
  };
  