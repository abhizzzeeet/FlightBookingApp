const express = require('express');
const axios = require('axios');
const { getAccessToken } = require('../services/amadeusServices')
const router = express.Router();

router.post('/price', async (req, res) => {
    const flightData = req.body;
  
    try {
      const accessToken = await getAccessToken();
      const response = await axios.post(
        'https://test.api.amadeus.com/v1/shopping/flight-offers/pricing',
        {
          'data': {
            'type': 'flight-offers-pricing',
            'flightOffers': [flightData]
          }
        },
        {
          headers: {
            'Authorization': `Bearer ${accessToken}`,
            'Content-Type': 'application/json'
          }
        }
      );
  
      return res.json(response.data);
    } catch (error) {
      console.error('Error making pricing request:', error);
      res.status(500).json({ error: 'Failed to fetch pricing' });
    }
});
  
module.exports = router;