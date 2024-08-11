const express = require('express');
const axios = require('axios');
// const { accessToken} = require('../config/amadeusConfig');
const { getAccessToken } = require('../services/amadeusServices')
const router = express.Router();

router.get('/search', async (req, res) => {
  const { keyword} = req.query;

  try {
    const accessToken = await getAccessToken();
    console.log("AccessToken in flightSuggest:",accessToken);
    const response = await axios.get('https://test.api.amadeus.com/v1/reference-data/locations', {
      headers: {
        Authorization: `Bearer ${accessToken}`
      },
      params: {
        subType: 'AIRPORT,CITY',
        keyword: keyword,
        'page[limit]': 10
      }
    });

    return res.json(response.data.data);
  } catch (error) {
    console.error('Error fetching locations:', error);
    throw new Error('Failed to fetch locations');
  }
});

module.exports = router;
