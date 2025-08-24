import pkg from "hardhat";
const { ethers } = pkg;

async function main() {
  console.log("Starting deployment...");

  // Get the contract factory
  const Counter = await ethers.getContractFactory("Counter");
  
  console.log("Deploying Counter contract...");
  
  // Deploy the contract
  const counter = await Counter.deploy();
  
  // Wait for deployment to finish
  await counter.waitForDeployment();
  
  const address = await counter.getAddress();
  console.log(`Counter deployed to: ${address}`);
  
  // Verify the contract on Etherscan
  console.log("Waiting for block confirmations...");
  await counter.deploymentTransaction().wait(6); // Wait for 6 block confirmations
  
  console.log("Verifying contract on Etherscan...");
  try {
    await hre.run("verify:verify", {
      address: address,
      constructorArguments: [],
    });
    console.log("Contract verified successfully on Etherscan!");
  } catch (error) {
    if (error.message.includes("Already Verified")) {
      console.log("Contract is already verified on Etherscan!");
    } else {
      console.log("Verification failed:", error.message);
    }
  }
  
  console.log("Deployment completed successfully!");
  console.log(`Contract address: ${address}`);
  
  // Return the address for potential use in other scripts
  return address;
}

// Handle errors
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Deployment failed:", error);
    process.exit(1);
  }); 