const dotenv = require('dotenv').config();

const serverPort = process.env.SERVER_PORT;
const serverHost = process.env.SERVER_HOST;

const octaveScriptPath = process.env.OCTAVE_PATH;


module.exports = {
  server: {
    port: serverPort,
    host: serverHost
  },
  octave: {
      path: octaveScriptPath
  }
  
}