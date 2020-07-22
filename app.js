const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const app = express();
const utastarRoutes = require('./routes/utaStarRoutes');


app.use(cors());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json({limit: '100mb'}));


app.use('/utastar', utastarRoutes);

app.use((req, res, next) => {
    res.status(404).send('Page not found');
});

module.exports = app;
