const Product = require('../models/Product');

const blockchainService = {
    async recordProductManufacture(productData) {
        console.log('Mock Blockchain: Recording product manufacture...');
        const txHash = `mock_tx_manufacture_${Date.now()}`;
        // Create or update the product in the database
        const product = await Product.findOneAndUpdate(
            { barcode: productData.barcode },
            { $push: { blockchainHistory: { txHash, event: 'manufactured', timestamp: new Date() } } },
            { new: true }
        );
        return { success: true, txHash, product };
    },

    async recordProductSale(barcode, userId) {
        console.log(`Mock Blockchain: Recording sale for barcode ${barcode} to user ${userId}`);
        const txHash = `mock_tx_sale_${Date.now()}`;
        const product = await Product.findOneAndUpdate(
            { barcode: barcode },
            {
                currentStatus: 'sold',
                owner: userId,
                $push: { blockchainHistory: { txHash, event: 'sold', timestamp: new Date() } }
            },
            { new: true }
        );
        return { success: true, txHash, product };
    },

    async recordProductStatusUpdate(barcode, status, userId, notes) {
        console.log(`Mock Blockchain: Recording status update for barcode ${barcode} to ${status}`);
        const txHash = `mock_tx_status_${Date.now()}`;
        const product = await Product.findOneAndUpdate(
            { barcode: barcode, owner: userId }, // Ensure only owner can update
            {
                currentStatus: status,
                usageNotes: notes,
                $push: { blockchainHistory: { txHash, event: `status_update_${status}`, timestamp: new Date() } }
            },
            { new: true }
        );
        return { success: true, txHash, product };
    },

    async recordProductDisposal(barcode, userId, disposalMachineLocation) {
        console.log(`Mock Blockchain: Recording disposal for barcode ${barcode} by user ${userId}`);
        const txHash = `mock_tx_disposal_${Date.now()}`;
        const product = await Product.findOneAndUpdate(
            { barcode: barcode, owner: userId },
            {
                currentStatus: 'disposed',
                $push: { blockchainHistory: { txHash, event: 'disposed', timestamp: new Date(), location: disposalMachineLocation } }
            },
            { new: true }
        );
        return { success: true, txHash, product };
    },

    async getProductLifecycle(barcode) {
        console.log(`Mock Blockchain: Fetching lifecycle for barcode ${barcode}`);
        const product = await Product.findOne({ barcode }).select('-owner'); // Exclude owner for privacy
        if (!product) return null;
        // Return a simplified product lifecycle
        return {
            barcode: product.barcode,
            name: product.name,
            category: product.category,
            manufacturer: product.manufacturer,
            manufactureDate: product.manufactureDate,
            distributionHistory: product.distributionHistory,
            currentStatus: product.currentStatus,
            usageNotes: product.usageNotes,
            blockchainHistory: product.blockchainHistory
        };
    }
};

module.exports = blockchainService;