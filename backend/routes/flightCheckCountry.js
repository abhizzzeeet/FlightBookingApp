const express = require('express');
const axios = require('axios');
const { getAccessToken } = require('../services/amadeusServices')
const router = express.Router();

router.get('/:iataCode', async (req , res) => {
    const iataCode = req.params.iataCode;
    try{    
        const accessToken = await getAccessToken();
        const response = await axios.get(`https://test.api.amadeus.com/v1/reference-data/locations?subType=AIRPORT&keyword=${iataCode}`, {
            headers: {
                'Authorization': `Bearer ${accessToken}`
            }
        });

        const data = response.data;
        if (data.data && data.data.length > 0) {
            const countryCode = data.data[0].address.countryCode;
            return res.json({ countryCode });
        } else {
            return res.status(404).json({ error: 'Airport not found' });
        }

    }catch(error){
        console.error('Error checking country:', error);
        res.status(500).json({ error: 'Failed to check country' });
    }
});

module.exports = router;