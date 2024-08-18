const express = require('express');
const axios = require('axios');
// const { accessToken} = require('../config/amadeusConfig');
const { getAccessToken } = require('../services/amadeusServices')
const router = express.Router();

router.get('/searchAvailableFlights', async (req, res) => {
    const { origin, destination, departureDate, returnDate, adults, children, travelClass } = req.query;

    
    try{
        const accessToken = await getAccessToken();
        console.log("AccessToken in flightSearch:",accessToken);
        let params = {
            originLocationCode: origin,
            destinationLocationCode: destination,
            departureDate: departureDate,
            adults: adults,
            children: children,
            travelClass: travelClass,
            currencyCode: 'INR'
        };

        // Conditionally add returnDate if it's provided
        if (returnDate) {
            params.returnDate = returnDate;
        }

        const response = await axios.get('https://test.api.amadeus.com/v2/shopping/flight-offers', {
            headers: { Authorization: `Bearer ${accessToken}` },
            params: params,
        });
        
                      
        const value = res.json(response.data);
        console.log('flightSearch response: ', value);
        return value;

    }catch (error) {
        console.error('Error fetching flight data:', error);
        res.status(500).send('Error fetching flight data');
    }
});


module.exports = router;