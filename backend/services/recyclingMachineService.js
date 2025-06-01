const User = require('../models/User');
const Product = require('../models/Product');
const DisposalEvent = require('../models/DisposalEvent');
const RewardTransaction = require('../models/RewardTransaction');
const blockchainService = require('./blockchainService');

const recyclingMachineService = {
    // Points per category for disposal
    pointsPerCategory: {
        plastic: 10,
        paper: 5,
        tin: 8,
        glass: 12,
        other: 2
    },

    async processDisposal(productBarcode, userQRData, disposalMachineLocation) {
        try {
            // 1. Validate User QR Code
            const { userId } = JSON.parse(userQRData);
            const user = await User.findById(userId);
            if (!user) {
                throw new Error('Invalid user QR code or user not found.');
            }

            // 2. Validate Product Barcode
            const product = await Product.findOne({ barcode: productBarcode, owner: user._id });
            if (!product) {
                throw new Error('Product not found or not owned by this user.');
            }
            if (product.currentStatus !== 'ready_for_disposal') {
                throw new Error('Product is not marked as ready for disposal.');
            }

            // 3. Determine Category and Points
            const category = product.category;
            const pointsEarned = this.pointsPerCategory[category] || this.pointsPerCategory.other;

            // 4. Update User's Reward Points
            user.rewardPoints += pointsEarned;
            await user.save();

            // 5. Record Disposal Event
            const disposalEvent = new DisposalEvent({
                userId: user._id,
                productId: product._id,
                barcode: productBarcode,
                category: category,
                pointsEarned: pointsEarned,
                disposalMachineLocation: disposalMachineLocation
            });
            await disposalEvent.save();

            // 6. Record Reward Transaction
            const rewardTransaction = new RewardTransaction({
                userId: user._id,
                type: 'earned',
                points: pointsEarned,
                description: `Disposed ${product.name} (${category})`
            });
            await rewardTransaction.save();

            // 7. Update Product Status on "Blockchain"
            const blockchainUpdate = await blockchainService.recordProductDisposal(
                productBarcode,
                user._id,
                disposalMachineLocation
            );
            if (!blockchainUpdate.success) {
                console.warn('Failed to record disposal on mock blockchain:', blockchainUpdate.error);
            }


            return {
                success: true,
                message: `Disposal successful! You earned ${pointsEarned} points.`,
                pointsEarned,
                currentTotalPoints: user.rewardPoints
            };

        } catch (error) {
            console.error('Error processing disposal:', error);
            return { success: false, message: error.message };
        }
    }
};

module.exports = recyclingMachineService;