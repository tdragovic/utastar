const app = require('../app');
const server = require('../utils/config').server;


const port = (server.port || 4000);

app.listen(port, () => {
  console.log('Express server started. Listening at port ' + port);
});