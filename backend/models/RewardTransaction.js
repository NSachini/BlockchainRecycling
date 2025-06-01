const mongoose = require('mongoose');
const RewardTransactionSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    type: { type: String, enum: ['earned', 'redeemed'], required: true },
    points: { type: Number, required: true },
    description: { type: String },
    date: { type: Date, default: Date.now }
});
module.exports = mongoose.model('RewardTransaction', RewardTransactionSchema);