const express = require('express');
const bodyParser = require('body-parser');
const admin = require('firebase-admin');
const cors = require('cors');
const http = require('http');
const { Server } = require("socket.io");
const Redis = require('ioredis');

const authRoutes = require('./routes/authRoutes');
const flightSuggestion = require('./routes/flightSuggest');
const flightSearch = require('./routes/flightSearch');
const flightCheckPrice = require('./routes/flightCheckPrice');
const flightCheckCountry = require('./routes/flightCheckCountry');
const flightSeatMap = require('./routes/flightSeatMap');
const payment = require('./routes/payment');
const socketRoutes = require('./routes/socketRoutes');
const serviceAccount = require('./serviceAccountKey.json');


admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*', // You can restrict the origins in production
  },
});

// Initialize Redis
const redis = new Redis({
  host: '127.0.0.1', // Replace with your Redis host (Google Cloud Redis instance)
  port: 6379, // Default Redis port
});

// Add connection and error event listeners
redis.on('connect', () => {
  console.log('Connected to local Redis');
});

redis.on('error', (err) => {
  console.error('Redis connection error:', err);
});


// Middleware
app.use(bodyParser.json());
app.use(cors());

// HTTP Routes
app.use('/api/auth', authRoutes);
app.use('/api/flights', flightSuggestion);
app.use('/api/flights', flightSearch);
app.use('/api/flights', flightCheckPrice);
app.use('/api/flights/checkCountry', flightCheckCountry);
app.use('/api/flights/flightSeatMap', flightSeatMap);
app.use('/api/payment', payment);

// New: Socket.IO routes
socketRoutes(io,redis); // Pass `io` instance to the socket route

// Start the server
const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
});
