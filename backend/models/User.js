const mongoose = require('mongoose');
const UserSchema = new mongoose.Schema({
    username: { type: String, required: true, unique: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    rewardPoints: { type: Number, default: 0 },
    qrCode: { type: String } // Stores base64 QR code for user
}, { timestamps: true });
module.exports = mongoose.model('User', UserSchema);