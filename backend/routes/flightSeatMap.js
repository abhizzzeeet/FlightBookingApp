const express = require('express');
const axios = require('axios');
const { getAccessToken } = require('../services/amadeusServices');
const router = express.Router();

router.post('/' , async (req,res) => {
    const pricingData = req.body;

    try{
        const accessToken = await getAccessToken();

        const response = await axios.post(
            'https://test.api.amadeus.com/v1/shopping/seatmaps',
            { data: [pricingData] }, // Use pricingData instead of flightOffer
            {
              headers: {
                'Authorization': `Bearer ${accessToken}`,
                'Content-Type': 'application/json',
              },
            }
        );
        return res.json(response.data);
            
    }catch (error) {
      console.error('Error making pricing request:', error);
      res.status(500).json({ error: 'Failed to fetch pricing' });
    }
});

module.exports = router;