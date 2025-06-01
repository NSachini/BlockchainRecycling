const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const User = require('../models/User');
const RewardTransaction = require('../models/RewardTransaction');

// @route   POST api/rewards/earn
// @desc    Earn reward points for product disposal
router.get('/my', auth, async (req, res) => {
    try {
        const user = await User.findById(req.user.id).select('rewardPoints');
        if (!user) {
            return res.status(404).json({ msg: 'User not found' });
        }
        const transactions = await RewardTransaction.find({ userId: req.user.id }).sort({ date: -1 });
        res.json({
            currentPoints: user.rewardPoints,
            transactionHistory: transactions
        });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
});


router.post('/redeem', auth, async (req, res) => {
    const { pointsToRedeem, description } = req.body;
    try {
        const user = await User.findById(req.user.id);
        if (!user) {
            return res.status(404).json({ msg: 'User not found' });
        }

        if (user.rewardPoints < pointsToRedeem) {
            return res.status(400).json({ msg: 'Insufficient points' });
        }

        user.rewardPoints -= pointsToRedeem;
        await user.save();

        const transaction = new RewardTransaction({
            userId: req.user.id,
            type: 'redeemed',
            points: pointsToRedeem,
            description: description || `Redeemed ${pointsToRedeem} points`
        });
        await transaction.save();

        res.json({
            msg: `Successfully redeemed ${pointsToRedeem} points.`,
            currentPoints: user.rewardPoints
        });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
});

module.exports = router;