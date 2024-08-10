// controllers/authController.js
const admin = require('firebase-admin');

// User signup
exports.signup = async (req, res) => {
  const { email, password } = req.body;
  try {
    const userRecord = await admin.auth().createUser({
      email,
      password,
    });
    res.status(200).send({ message: 'User created successfully', userRecord });
  } catch (error) {
    res.status(400).send({ error: error.message });
  }
};

// User login
exports.login = async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await admin.auth().getUserByEmail(email);
    // Password verification should be handled on the client side
    res.status(200).send({ message: 'Login successful', user });
  } catch (error) {
    res.status(400).send({ error: error.message });
  }
};
