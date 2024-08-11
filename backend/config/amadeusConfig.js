const { getAccessToken } = require('../services/amadeusServices');

let accessToken = null;

const initialize = async () => {
  try {
    accessToken = await getAccessToken();
  } catch (error) {
    console.error('Failed to initialize Amadeus config:', error);
  }
};

// Initialize access token when the module is loaded
initialize();

module.exports = {
  accessToken: () => accessToken,
};
