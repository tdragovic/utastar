const express = require('express')
const router = express.Router();

const {
    runScript  
} = require('../services/utastarServices');

router.post('/', runScript);

module.exports = router;