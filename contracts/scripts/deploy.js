const hre = require("hardhat"); // Hardhat Runtime Environment

async function main() {
    const ProductTracker = await hre.ethers.getContractFactory("ProductTracker"); 

  // Deploy the contract
  const productTracker = await ProductTracker.deploy();

  await productTracker.waitForDeployment();

  console.log(`ProductTracker deployed to: ${productTracker.target}`); 
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});