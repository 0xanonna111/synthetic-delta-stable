const hre = require("hardhat");

async function main() {
  // Sepolia ETH/USD Price Feed
  const PRICE_FEED = "0x694AA1769357215DE4FAC081bf1f309aDC325306";

  const DeltaVault = await hre.ethers.getContractFactory("DeltaVault");
  const vault = await DeltaVault.deploy(PRICE_FEED);

  await vault.waitForDeployment();
  console.log(`DeltaVault deployed to: ${await vault.getAddress()}`);
  console.log(`sUSD Token deployed to: ${await vault.sUSD()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
