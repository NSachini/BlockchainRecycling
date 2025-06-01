const mongoose = require('mongoose');
const ProductSchema = new mongoose.Schema({
    barcode: { type: String, required: true, unique: true },
    name: { type: String, required: true },
    category: { type: String, required: true, enum: ['plastic', 'paper', 'tin', 'glass', 'other'] },
    manufacturer: { type: String, required: true },
    manufactureDate: { type: Date, required: true },
    distributionHistory: [{ location: String, date: Date }],
    currentStatus: { type: String, default: 'manufactured', enum: ['manufactured', 'distributed', 'sold', 'in_use', 'ready_for_disposal', 'disposed'] },
    owner: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }, // Consumer who scanned it
    usageNotes: { type: String },
    blockchainHistory: [{ // Simplified reference to blockchain transactions
        txHash: String,
        event: String,
        timestamp: Date
    }]
}, { timestamps: true });
module.exports = mongoose.model('Product', ProductSchema);