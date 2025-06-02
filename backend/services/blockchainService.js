const { ethers } = require('ethers'); 
const Product = require('../models/Product'); 

const CONTRACT_ADDRESS = '0x5FbDB2315678afecb367f032d93F642f64180aa3'; 
const RPC_URL = 'http://127.0.0.1:8545/'; 

const CONTRACT_ABI = [
  {
    "inputs": [],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "string",
        "name": "barcode",
        "type": "string"
      },
      {
        "indexed": false,
        "internalType": "string",
        "name": "eventType",
        "type": "string"
      },
      {
        "indexed": false,
        "internalType": "address",
        "name": "actor",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "timestamp",
        "type": "uint256"
      }
    ],
    "name": "LifecycleEventRecorded",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "string",
        "name": "barcode",
        "type": "string"
      },
      {
        "indexed": false,
        "internalType": "string",
        "name": "name",
        "type": "string"
      },
      {
        "indexed": false,
        "internalType": "address",
        "name": "manufacturer",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "timestamp",
        "type": "uint256"
      }
    ],
    "name": "ProductRegistered",
    "type": "event"
  },
  {
    "inputs": [
      {
        "internalType": "string",
        "name": "_barcode",
        "type": "string"
      }
    ],
    "name": "getProductEvents",
    "outputs": [
      {
        "components": [
          {
            "internalType": "string",
            "name": "eventType",
            "type": "string"
          },
          {
            "internalType": "uint256",
            "name": "timestamp",
            "type": "uint256"
          },
          {
            "internalType": "string",
            "name": "details",
            "type": "string"
          },
          {
            "internalType": "address",
            "name": "actor",
            "type": "address"
          }
        ],
        "internalType": "struct ProductTracker.LifecycleEvent[]",
        "name": "",
        "type": "tuple[]"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "owner",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "string",
        "name": "",
        "type": "string"
      }
    ],
    "name": "productExists",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "string",
        "name": "",
        "type": "string"
      }
    ],
    "name": "products",
    "outputs": [
      {
        "internalType": "string",
        "name": "barcode",
        "type": "string"
      },
      {
        "internalType": "string",
        "name": "name",
        "type": "string"
      },
      {
        "internalType": "string",
        "name": "category",
        "type": "string"
      },
      {
        "internalType": "address",
        "name": "manufacturer",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "manufactureTimestamp",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "string",
        "name": "_barcode",
        "type": "string"
      },
      {
        "internalType": "string",
        "name": "_eventType",
        "type": "string"
      },
      {
        "internalType": "string",
        "name": "_details",
        "type": "string"
      },
      {
        "internalType": "address",
        "name": "_actor",
        "type": "address"
      }
    ],
    "name": "recordLifecycleEvent",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "string",
        "name": "_barcode",
        "type": "string"
      },
      {
        "internalType": "string",
        "name": "_name",
        "type": "string"
      },
      {
        "internalType": "string",
        "name": "_category",
        "type": "string"
      },
      {
        "internalType": "address",
        "name": "_manufacturer",
        "type": "address"
      }
    ],
    "name": "registerProduct",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];

let productTrackerContract; 
let deployerSigner;

const initBlockchain = async () => {
  try {

    const provider = new ethers.JsonRpcProvider(RPC_URL);

    const accounts = await provider.listAccounts();
    if (accounts.length === 0) {
      throw new Error('No accounts found in local Hardhat node. Is it running?');
    }
    deployerSigner = await provider.getSigner(accounts[0].address); 


    productTrackerContract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, deployerSigner);
    console.log('Blockchain service initialized. Connected to local ProductTracker contract.');

  } catch (error) {
    console.error('Failed to initialize blockchain service:', error.message);
    process.exit(1); 
  }
};

initBlockchain();


const blockchainService = {
  async recordProductManufacture(productData) {
    console.log(`Blockchain: Recording product manufacture for ${productData.barcode}`);
    try {
      const exists = await productTrackerContract.productExists(productData.barcode);
      if (exists) {
        console.warn(`Product ${productData.barcode} already exists on blockchain, skipping on-chain registration.`);
        const product = await Product.findOneAndUpdate(
          { barcode: productData.barcode },
          { $push: { blockchainHistory: { txHash: 'already_on_chain', event: 'manufactured', timestamp: new Date() } } },
          { new: true }
        );
        return { success: true, txHash: 'already_on_chain', product };
      }


      const tx = await productTrackerContract.registerProduct(
        productData.barcode,
        productData.name,
        productData.category,
        deployerSigner.address 
      );
      await tx.wait(); 

      console.log(`Blockchain: Product registered. Tx Hash: ${tx.hash}`);

      const product = await Product.findOneAndUpdate(
        { barcode: productData.barcode },
        { $push: { blockchainHistory: { txHash: tx.hash, event: 'manufactured', timestamp: new Date() } } },
        { new: true }
      );
      return { success: true, txHash: tx.hash, product };
    } catch (error) {
      console.error('Blockchain Error (Manufacture):', error.message);
      return { success: false, error: error.message };
    }
  },


  async recordProductSale(barcode, userId) {
    console.log(`Blockchain: Recording sale for barcode ${barcode} to user ${userId}`);
    try {

      const consumerActorAddress = deployerSigner.address; 


      const tx = await productTrackerContract.recordLifecycleEvent(
        barcode,
        'sold',
        `Sold to user ${userId}`, 
        consumerActorAddress 
      );
      await tx.wait();

      console.log(`Blockchain: Sale recorded. Tx Hash: ${tx.hash}`);


      const product = await Product.findOneAndUpdate(
        { barcode: barcode },
        {
          currentStatus: 'sold',
          owner: userId,
          $push: { blockchainHistory: { txHash: tx.hash, event: 'sold', timestamp: new Date() } }
        },
        { new: true }
      );
      return { success: true, txHash: tx.hash, product };
    } catch (error) {
      console.error('Blockchain Error (Sale):', error.message);
      return { success: false, error: error.message };
    }
  },

 
  async recordProductStatusUpdate(barcode, status, userId, notes) {
    console.log(`Blockchain: Recording status update for barcode ${barcode} to ${status}`);
    try {
      const actorAddress = deployerSigner.address; // Placeholder for MVP

      const tx = await productTrackerContract.recordLifecycleEvent(
        barcode,
        `status_update_${status}`,
        `Status updated to: ${status}. Notes: ${notes || 'N/A'}`,
        actorAddress
      );
      await tx.wait();

      console.log(`Blockchain: Status update recorded. Tx Hash: ${tx.hash}`);


      const product = await Product.findOneAndUpdate(
        { barcode: barcode, owner: userId },
        {
          currentStatus: status,
          usageNotes: notes,
          $push: { blockchainHistory: { txHash: tx.hash, event: `status_update_${status}`, timestamp: new Date() } }
        },
        { new: true }
      );
      return { success: true, txHash: tx.hash, product };
    } catch (error) {
      console.error('Blockchain Error (Status Update):', error.message);
      return { success: false, error: error.message };
    }
  },

  async recordProductDisposal(barcode, userId, disposalMachineLocation) {
    console.log(`Blockchain: Recording disposal for barcode ${barcode} by user ${userId}`);
    try {
      const actorAddress = deployerSigner.address; // Placeholder for MVP

      const tx = await productTrackerContract.recordLifecycleEvent(
        barcode,
        'disposed',
        `Disposed at machine: ${disposalMachineLocation}`,
        actorAddress
      );
      await tx.wait();

      console.log(`Blockchain: Disposal recorded. Tx Hash: ${tx.hash}`);


      const product = await Product.findOneAndUpdate(
        { barcode: barcode, owner: userId },
        {
          currentStatus: 'disposed',
          $push: { blockchainHistory: { txHash: tx.hash, event: 'disposed', timestamp: new Date(), location: disposalMachineLocation } }
        },
        { new: true }
      );
      return { success: true, txHash: tx.hash, product };
    } catch (error) {
      console.error('Blockchain Error (Disposal):', error.message);
      return { success: false, error: error.message };
    }
  },


  async getProductLifecycle(barcode) {
    console.log(`Blockchain: Fetching lifecycle for barcode ${barcode}`);
    try {
      const exists = await productTrackerContract.productExists(barcode);
      if (!exists) {
        console.warn(`Product ${barcode} not found on blockchain.`);
        return null;
      }

        // Fetch product events from the contract
      const onChainEvents = await productTrackerContract.getProductEvents(barcode);
      
      const blockchainHistory = onChainEvents.map(event => ({
        txHash: 'on-chain-tx', 
        event: event.eventType,
        timestamp: new Date(Number(event.timestamp) * 1000), 
        details: event.details,
      }));

        // Fetch product details from the contract
      const onChainProduct = await productTrackerContract.products(barcode);

      const localProduct = await Product.findOne({ barcode }).select('-owner'); 
      if (!localProduct) {
        console.warn(`Local DB entry for ${barcode} not found, but contract exists.`);
      }

      return {
        barcode: onChainProduct.barcode,
        name: onChainProduct.name,
        category: onChainProduct.category,
        manufacturer: onChainProduct.manufacturer, 
        manufactureDate: new Date(Number(onChainProduct.manufactureTimestamp) * 1000),
        distributionHistory: localProduct ? localProduct.distributionHistory : [], 
        currentStatus: localProduct ? localProduct.currentStatus : 'unknown', 
        usageNotes: localProduct ? localProduct.usageNotes : '', 
        blockchainHistory: blockchainHistory 
      };

    } catch (error) {
      console.error('Blockchain Error (Get Lifecycle):', error.message);
      return { success: false, error: error.message };
    }
  },
};

module.exports = blockchainService;