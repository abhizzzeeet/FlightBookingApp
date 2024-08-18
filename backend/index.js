const express = require('express');
const bodyParser = require('body-parser');
const admin = require('firebase-admin');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes')
const flightSuggestion = require('./routes/flightSuggest');
const flightSearch = require('./routes/flightSearch');
const flightCheckPrice = require('./routes/flightCheckPrice');
const flightCheckCountry = require('./routes/flightCheckCountry');
const flightSeatMap = require('./routes/flightSeatMap');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const app = express();
app.use(bodyParser.json());
app.use(cors());

app.use('/api/auth',authRoutes)
app.use('/api/flights', flightSuggestion);
app.use('/api/flights', flightSearch);
app.use('/api/flights', flightCheckPrice);
app.use('/api/flights/checkCountry',flightCheckCountry);
app.use('/api/flights/flightSeatMap', flightSeatMap);

const PORT = process.env.PORT || 3000;
app.listen(PORT,'0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
});
