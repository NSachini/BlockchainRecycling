require('dotenv').config(); 
const express = require('express');
const connectDB = require('./config/db');

const app = express();

// Connect Database
connectDB();

// Init Middleware
app.use(express.json({ extended: false })); 

app.get('/', (req, res) => res.send('API Running'));

// Define Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/products', require('./routes/products'));
app.use('/api/recycle', require('./routes/recycle'));
app.use('/api/rewards', require('./routes/rewards'));

const port = process.env.PORT || 5000;
app.listen(port, () => console.log(`Server started on port ${port}`));