require('dotenv').config(); 
require("@nomicfoundation/hardhat-toolbox");


console.log('--- Hardhat Config Debug ---');
console.log('process.env.INFURA_API_KEY:', process.env.INFURA_API_KEY ? 'Set' : 'MISSING/UNDEFINED');
console.log('process.env.SEPOLIA_PRIVATE_KEY:', process.env.SEPOLIA_PRIVATE_KEY ? 'Set' : 'MISSING/UNDEFINED');
console.log('Value of INFURA_API_KEY:', process.env.INFURA_API_KEY ? process.env.INFURA_API_KEY.substring(0, 5) + '...' : 'N/A');
console.log('Value of SEPOLIA_PRIVATE_KEY:', process.env.SEPOLIA_PRIVATE_KEY ? process.env.SEPOLIA_PRIVATE_KEY.substring(0, 5) + '...' : 'N/A');
console.log('--- End Debug ---');

const INFURA_API_KEY = process.env.INFURA_API_KEY;
const SEPOLIA_PRIVATE_KEY = process.env.SEPOLIA_PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28", 
  networks: {
    sepolia: {
      url: `https://sepolia.infura.io/v3/${INFURA_API_KEY}`,
      accounts: SEPOLIA_PRIVATE_KEY ? [SEPOLIA_PRIVATE_KEY] : [],
    },
  },
};