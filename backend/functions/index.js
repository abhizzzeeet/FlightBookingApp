const functions = require('firebase-functions');
const admin = require('firebase-admin');
const stripe = require('stripe')('sk_test_51PsKYGDfeL7GR0IavFrQFySL8Uzcy3QE16R3hsVpKgBpRqIgojArAdUzm9KyqvqjIGOAKnBgQsBFEnB6vR87AkbU00cvLNbmm2');

exports.createPaymentIntentHTTP = functions.https.onRequest(async (req, res) => {
  try {
    console.log("Arrived createPaymentIntent backend");
    const{ amount , currency } = req.body;
    
    console.log("Amount passed: ", amount);
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
      automatic_payment_methods: { enabled: true },
    });
    console.log("Payment Intent: ", paymentIntent);
    res.status(200).send({ clientSecret: paymentIntent.client_secret });
  } catch (error) {
    console.error("Payment ERROR: ", error);

  }
});
