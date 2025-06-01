const QRCode = require('qrcode');

const generateUserQR = async (userId) => {
    try {
        const qrData = JSON.stringify({ userId: userId.toString(), type: 'user' });
        const qrCodeBase64 = await QRCode.toDataURL(qrData);
        return qrCodeBase64;
    } catch (err) {
        console.error('Error generating QR code:', err);
        throw err;
    }
};

module.exports = { generateUserQR };