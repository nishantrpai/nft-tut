const { ethers } = require("hardhat");

async function main() {
  const creator = process.env.PUBLIC_KEY;
  const provider = new ethers.providers.AlchemyProvider("maticmum", process.env.ALCHEMY_API_KEY);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

  // interact with vault
  let vaultabi = ["function setWhiteList(address addr, bool isWhiteListed)"];
  const vaultaddr = "0x84243561d488cd758764B0848469cB9a9798fcBf";
  const vaultcontract = await ethers.getContractAt(vaultabi, vaultaddr);
  let tx1 = await vaultcontract.setWhiteList(creator, true);
  console.log(tx1);
  await tx1.wait();

  const NFTaddr = '0x5107A6919Dbd91E8498B364A37C075efAe5A6Ee7';
  const nft = await ethers.getContractAt("NFT",NFTaddr);
  let tx2 = await nft["safeTransferFrom(address,address,uint256)"](creator,vaultaddr,1);
  console.log(tx2.hash);
  await tx2.wait();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
