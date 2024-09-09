    const express = require('express');
    const axios = require('axios');
    const Stripe = require('stripe');
    const router = express.Router();
    require('dotenv').config();

    const stripe = Stripe(process.env.STRIPE_SECRET_KEY);

    router.post('/createPaymentIntent' , async (req,res) => {
        const { amount, currency } = req.body;

        try {
            const paymentIntent = await stripe.paymentIntents.create({
                amount,
                currency,
                automatic_payment_methods: {
                    enabled: true,
                },    
            });

            console.log("paymentIntent : " , paymentIntent);
            
            res.status(200).send(paymentIntent);
        } catch (error) {
            
            console.log("Payment ERROR: ", error);
            res.status(500).send({ error: error.message });
        }
    }); 

    module.exports = router;