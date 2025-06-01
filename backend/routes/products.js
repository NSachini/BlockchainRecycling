const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Product = require('../models/Product');
const blockchainService = require('../services/blockchainService');

// @route   POST api/products/add
// @desc    Manufacturer adds a new product
// @access  Private (Manufacturer only)
router.post('/add', auth, async (req, res) => {
    const { barcode, name, category, manufacturer, manufactureDate, distributionHistory } = req.body;
    try {
        let product = await Product.findOne({ barcode });
        if (product) {
            return res.status(400).json({ msg: 'Product with this barcode already exists' });
        }

        // Validate manufacturer role
        product = new Product({
            barcode, name, category, manufacturer, manufactureDate, distributionHistory
        });
        await product.save(); 

        const blockchainRecord = await blockchainService.recordProductManufacture({ barcode, name, category, manufacturer, manufactureDate });
        if (!blockchainRecord.success) {
            console.warn("Failed to record manufacture on mock blockchain:", blockchainRecord.error);
        }

        res.json({ msg: 'Product added and recorded.', product });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
});

// @route   POST api/products/scan-by-manufacturer
// @desc    Manufacturer scans a product to update its distribution history
router.post('/scan-by-consumer', auth, async (req, res) => {
    const { barcode } = req.body;
    try {
        let product = await Product.findOne({ barcode });
        if (!product) {
            return res.status(404).json({ msg: 'Product not found in system' });
        }
        if (product.owner && product.owner.toString() !== req.user.id) {
            return res.status(400).json({ msg: 'Product already owned by another user.' });
        }
        if (product.currentStatus === 'disposed') {
            return res.status(400).json({ msg: 'Product has already been disposed.' });
        }

        // Update distribution history
        const blockchainRecord = await blockchainService.recordProductSale(barcode, req.user.id);
        if (!blockchainRecord.success) {
             console.warn("Failed to record sale on mock blockchain:", blockchainRecord.error);
        }
        res.json({ msg: 'Product added to your account.', product: blockchainRecord.product });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
});

// @route   GET api/products/my
// @desc    Get all products owned by the user
// @access  Private
router.get('/my', auth, async (req, res) => {
    try {
        const products = await Product.find({ owner: req.user.id });
        res.json(products);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
});

// @route   GET api/products/:barcode
// @desc    Get product lifecycle by barcode
// @access  Private
router.get('/:barcode', auth, async (req, res) => {
    try {
        const barcode = req.params.barcode;
        const productInfo = await blockchainService.getProductLifecycle(barcode);
        if (!productInfo) {
            return res.status(404).json({ msg: 'Product not found' });
        }
        res.json(productInfo);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
});

// @route   PUT api/products/:barcode/status
// @desc    Update product status (in_use, ready_for_disposal)
// @access  Private
router.put('/:barcode/status', auth, async (req, res) => {
    const { status, notes } = req.body; 
    try {
        const barcode = req.params.barcode;
        const product = await Product.findOne({ barcode: barcode, owner: req.user.id });
        if (!product) {
            return res.status(404).json({ msg: 'Product not found or not owned by you' });
        }

        if (!['in_use', 'ready_for_disposal'].includes(status)) {
            return res.status(400).json({ msg: 'Invalid status update.' });
        }

        const blockchainUpdate = await blockchainService.recordProductStatusUpdate(barcode, status, req.user.id, notes);
        if (!blockchainUpdate.success) {
            console.warn("Failed to record status update on mock blockchain:", blockchainUpdate.error);
        }
        res.json({ msg: 'Product status updated.', product: blockchainUpdate.product });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
});

module.exports = router;