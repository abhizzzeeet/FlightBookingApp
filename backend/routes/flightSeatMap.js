const express = require('express');
const axios = require('axios');
const { getAccessToken } = require('../services/amadeusServices');
const router = express.Router();
let pricingData; 

let accessToken;
router.post('/' , async (req,res) => {
    pricingData = req.body;
    console.log("pricingData: ", pricingData);
    try{
        accessToken = await getAccessToken();

        const response = await axios.post(
            'https://test.api.amadeus.com/v1/shopping/seatmaps',
            pricingData , 
            {
              headers: {
                'Authorization': `Bearer ${accessToken}`,
                'Content-Type': 'application/json',
              },
            }
        );
        // console.log("Seat Map Response: ", JSON.stringify(response.data, null, 2));
        return res.json(response.data);
            
    }catch (error) {
      console.error('Error making seat map request:', error);
      res.status(500).json({ error: 'Failed to fetch seatMap' });
    }
});

router.get('/seatmap', async (req, res) => {
  try {
      const response = await axios.post(
          'https://test.api.amadeus.com/v1/shopping/seatmaps',
          pricingData, 
          {
            headers: {
              'Authorization': `Bearer ${accessToken}`,
              'Content-Type': 'application/json',
            },
          }
      );

      res.setHeader('Content-Type', 'application/json');
      return res.send(response.data);
          
  } catch (error) {
      console.error('Error making seat map get request:', error);
      res.status(500).json({ error: 'Failed to get seatMap ' });
  }
});

module.exports = router;