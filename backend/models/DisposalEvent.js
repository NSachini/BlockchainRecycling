const mongoose = require('mongoose');
const DisposalEventSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
    barcode: { type: String, required: true },
    category: { type: String, required: true },
    pointsEarned: { type: Number, required: true },
    disposalMachineLocation: { type: String },
    disposalDate: { type: Date, default: Date.now }
});
module.exports = mongoose.model('DisposalEvent', DisposalEventSchema);