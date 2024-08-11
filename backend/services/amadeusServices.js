// /services/amadeusService.js
const axios = require('axios');
require('dotenv').config();

let accessToken = null;
let tokenExpiry = null;

const getAccessToken = async () => {
  if (accessToken && tokenExpiry && new Date() < tokenExpiry) {
    return accessToken;
  }

  try {
    const response = await axios.post('https://test.api.amadeus.com/v1/security/oauth2/token', 
      new URLSearchParams({
        grant_type: 'client_credentials',
        client_id: process.env.AMA_CLIENT_ID,
        client_secret: process.env.AMA_CLIENT_SECRET
      }).toString(),
      {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      }
    );

    // Store the new token and calculate its expiry time
    accessToken = response.data.access_token;
    console.log('Acess Token:',accessToken);
    const expiresIn = response.data.expires_in; // Time in seconds
    tokenExpiry = new Date(new Date().getTime() + expiresIn * 1000);

    return accessToken;
  } catch (error) {
    console.error('Error fetching access token:', error);
    throw new Error('Failed to fetch access token');
  }
};

module.exports = {
  getAccessToken,
};
