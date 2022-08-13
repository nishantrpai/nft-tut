async function main() {
  const Present = await ethers.getContractFactory("Present")

  // Start deployment, returning a promise that resolves to a contract object
  console.log("Deploying present contract...")
  const contract = await Present.deploy()
  await contract.deployed()
  console.log("Present Contract deployed to address:", contract.address)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })

// npx hardhat run scripts/deploy.js --network rinkeby
// npx hardhat run scripts/deploy.js --network mainnet
