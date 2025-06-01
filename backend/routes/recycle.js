const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const recyclingMachineService = require('../services/recyclingMachineService');
const User = require('../models/User');

// @route   POST api/recycle/process
// @desc    Process product disposal through recycling machine
// @access  Private (Authenticated users only)
router.post('/process', auth, async (req, res) => {
    const { productBarcode, userQRData, disposalMachineLocation } = req.body;
    if (!productBarcode || !userQRData || !disposalMachineLocation) {
        return res.status(400).json({ msg: 'Missing required disposal data.' });
    }
    try {
        // Validate user QR code
        const decodedQR = JSON.parse(userQRData);
        if (!decodedQR || decodedQR.userId !== req.user.id) {
            return res.status(403).json({ msg: 'QR code does not match authenticated user.' });
        }

        const result = await recyclingMachineService.processDisposal(
            productBarcode,
            userQRData, 
            disposalMachineLocation
        );

        if (result.success) {
            res.json(result);
        } else {
            res.status(400).json({ msg: result.message });
        }
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
});

module.exports = router;