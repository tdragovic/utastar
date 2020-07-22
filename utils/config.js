const dotenv = require('dotenv').config();

const serverPort = process.env.SERVER_PORT;
const serverHost = process.env.SERVER_HOST;

const matlabScriptPath = process.env.MATLAB_PATH;


module.exports = {
  server: {
    port: serverPort,
    host: serverHost
  },
  matlab: {
      path: matlabScriptPath
  }
  
}