import pkg from "hardhat";
const { ethers } = pkg;
import fs from 'fs';
import path from 'path';

async function main() {
  console.log("Starting generalized deployment for all contracts...");
  
  const contractsDir = './contracts';
  const deploymentResults = [];
  
  // Get all .sol files from contracts directory
  const contractFiles = fs.readdirSync(contractsDir)
    .filter(file => file.endsWith('.sol'))
    .map(file => path.join(contractsDir, file));
  
  console.log(`Found ${contractFiles.length} contract files:`, contractFiles.map(f => path.basename(f)));
  
  for (const contractFile of contractFiles) {
    try {
      const contractName = path.basename(contractFile, '.sol');
      console.log(`\n=== Processing ${contractName} ===`);
      
      // Extract contract name from file content (first contract declaration)
      const fileContent = fs.readFileSync(contractFile, 'utf8');
      const contractMatch = fileContent.match(/contract\s+(\w+)/);
      const actualContractName = contractMatch ? contractMatch[1] : contractName;
      
      console.log(`Contract name: ${actualContractName}`);
      
      // Check if contract has constructor parameters
      const constructorMatch = fileContent.match(/constructor\s*\(([^)]*)\)/);
      if (constructorMatch && constructorMatch[1].trim()) {
        console.log(`⚠️  ${actualContractName} has constructor parameters: ${constructorMatch[1].trim()}`);
        console.log(`   Skipping deployment - requires manual configuration`);
        
        // Store skipped deployment result
        deploymentResults.push({
          name: actualContractName,
          file: path.basename(contractFile),
          address: null,
          status: 'skipped',
          reason: `Constructor parameters required: ${constructorMatch[1].trim()}`
        });
        continue;
      }
      
      // Get the contract factory
      const ContractFactory = await ethers.getContractFactory(actualContractName);
      
      console.log(`Deploying ${actualContractName} contract...`);
      
      // Deploy the contract
      const contract = await ContractFactory.deploy();
      
      // Wait for deployment to finish
      await contract.waitForDeployment();
      
      const address = await contract.getAddress();
      console.log(`${actualContractName} deployed to: ${address}`);
      
      // Wait for block confirmations
      console.log("Waiting for block confirmations...");
      await contract.deploymentTransaction().wait(6);
      
      // Verify the contract on Etherscan
      console.log("Verifying contract on Etherscan...");
      try {
        await hre.run("verify:verify", {
          address: address,
          constructorArguments: [],
        });
        console.log(`${actualContractName} verified successfully on Etherscan!`);
      } catch (error) {
        if (error.message.includes("Already Verified")) {
          console.log(`${actualContractName} is already verified on Etherscan!`);
        } else {
          console.log(`Verification failed for ${actualContractName}:`, error.message);
        }
      }
      
      // Store deployment result
      deploymentResults.push({
        name: actualContractName,
        file: path.basename(contractFile),
        address: address,
        status: 'success',
        verified: true
      });
      
      console.log(`${actualContractName} deployment completed successfully!`);
      
    } catch (error) {
      console.error(`Failed to deploy contract from ${path.basename(contractFile)}:`, error.message);
      
      // Store failed deployment result
      deploymentResults.push({
        name: path.basename(contractFile, '.sol'),
        file: path.basename(contractFile),
        address: null,
        status: 'failed',
        error: error.message
      });
    }
  }
  
  // Generate deployment summary
  console.log("\n" + "=".repeat(60));
  console.log("DEPLOYMENT SUMMARY");
  console.log("=".repeat(60));
  
  const successful = deploymentResults.filter(r => r.status === 'success');
  const failed = deploymentResults.filter(r => r.status === 'failed');
  const skipped = deploymentResults.filter(r => r.status === 'skipped');
  
  console.log(`Total contracts processed: ${deploymentResults.length}`);
  console.log(`Successfully deployed: ${successful.length}`);
  console.log(`Failed deployments: ${failed.length}`);
  console.log(`Skipped (constructor params): ${skipped.length}`);
  
  if (successful.length > 0) {
    console.log("\nSuccessfully deployed contracts:");
    successful.forEach(result => {
      console.log(`  ✓ ${result.name}: ${result.address}`);
    });
  }
  
  if (failed.length > 0) {
    console.log("\nFailed deployments:");
    failed.forEach(result => {
      console.log(`  ✗ ${result.name}: ${result.error}`);
    });
  }
  
  if (skipped.length > 0) {
    console.log("\nSkipped deployments (constructor parameters required):");
    skipped.forEach(result => {
      console.log(`  ⚠️  ${result.name}: ${result.reason}`);
    });
  }
  
  // Write deployment summary to file
  const summaryContent = `DEPLOYMENT SUMMARY
Generated: ${new Date().toISOString()}
Total contracts: ${deploymentResults.length}
Successful: ${successful.length}
Failed: ${failed.length}
Skipped: ${skipped.length}

${successful.length > 0 ? 'SUCCESSFUL DEPLOYMENTS:\n' + successful.map(r => `${r.name}: ${r.address}`).join('\n') + '\n' : ''}
${failed.length > 0 ? 'FAILED DEPLOYMENTS:\n' + failed.map(r => `${r.name}: ${r.error}`).join('\n') + '\n' : ''}
${skipped.length > 0 ? 'SKIPPED DEPLOYMENTS (Constructor Parameters Required):\n' + skipped.map(r => `${r.name}: ${r.reason}`).join('\n') : ''}
`;
  
  fs.writeFileSync('deployment-summary.txt', summaryContent);
  console.log("\nDeployment summary written to deployment-summary.txt");
  
  // Exit with error code if any deployments failed
  if (failed.length > 0) {
    console.log("\nSome deployments failed. Check the logs above for details.");
    process.exit(1);
  }
  
  // Show warning if some contracts were skipped
  if (skipped.length > 0) {
    console.log(`\n⚠️  ${skipped.length} contracts were skipped due to constructor parameters.`);
    console.log("   These contracts require manual configuration before deployment.");
  }
  
  console.log("\nAll contracts deployed successfully!");
}

// Handle errors
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("General deployment failed:", error);
    process.exit(1);
  });
