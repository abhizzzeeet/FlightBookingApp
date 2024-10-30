// routes/socketRoutes.js

module.exports = function (io, redis) {
  const seatLockTimers = {}; // Store timers for each locked seat
  // Listen for key expiration
  // redis.on('expired', (key) => {
  //   console.log(`Expire event triggered`);
  //   const match = key.match(/lockedSeats:(.*?):(.*?)/);
  //   if (match) {
  //     const roomId = match[1];
  //     const seatNumber = match[2];
  //     console.log(`Seat automatically unlocked for roomId: ${roomId}, seatNumber: ${seatNumber}`);
  //   }
  // });

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
    socket.on('lockSeat', async (data) => {
      const { roomId, seatNumber } = data;
      const redisKey = `lockedSeats:${roomId}:${seatNumber}`;
      const seatLocked = await redis.get(redisKey);

      // Lock the seat if it's not already locked
      if (!seatLocked) {
        await redis.set(redisKey, 'locked'); // Lock seat for 10 sec
        io.to(roomId).emit('seatLocked', { seatNumber: seatNumber.toString() });
        console.log(`Seat locked for roomId: ${roomId} `);

        // Automatically unlock the seat after 10 minutes
        seatLockTimers[redisKey] = setTimeout(async () => {
          await redis.del(redisKey);
          io.to(roomId).emit('seatUnlocked', { seatNumber: seatNumber.toString() });
          delete seatLockTimers[redisKey];
          console.log(`Seat automatically unlocked for roomId: ${roomId}, seatNumber: ${seatNumber}`);
        }, 600000); // 10 minutes in milliseconds
      } else {
        socket.emit('seatAlreadyLocked', { seatNumber: seatNumber.toString() });
        console.log(`Seat already locked`);
      }
    });

    // Handle reset lock timer
    socket.on('resetLockTimer', async (data) => {
      const { roomId, seatNumber } = data;
      const redisKey = `lockedSeats:${roomId}:${seatNumber}`;

      // Clear existing timer if it exists
      if (seatLockTimers[redisKey]) {
        clearTimeout(seatLockTimers[redisKey]);
        console.log(`Timer reset for seat: ${seatNumber} in room: ${roomId}`);
      }

      // Start a new timer for 5 minutes
      seatLockTimers[redisKey] = setTimeout(async () => {
        await redis.del(redisKey);
        io.to(roomId).emit('seatUnlocked', { seatNumber: seatNumber.toString() });
        delete seatLockTimers[redisKey];
        console.log(`Seat automatically unlocked for roomId: ${roomId}, seatNumber: ${seatNumber}`);
      }, 5 * 60 * 1000); // 5 minutes in milliseconds
    });

    // Handle seat unlock (optional)
    socket.on('unlockSeat', async (data) => {
      const { roomId, seatNumber } = data;
      const redisKey = `lockedSeats:${roomId}:${seatNumber}`;
      await redis.del(redisKey);
      io.to(roomId).emit('seatUnlocked', { seatNumber: seatNumber.toString() });
      if (seatLockTimers[redisKey]) {
        clearTimeout(seatLockTimers[redisKey]);
        delete seatLockTimers[redisKey];
      }
      console.log(`Seat unlocked in roomId : ${roomId}`);
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
