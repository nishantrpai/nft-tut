/**
* @type import('hardhat/config').HardhatUserConfig
*/
require('dotenv').config(process.cwd(), '.env');
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-truffle5");
require("@nomiclabs/hardhat-etherscan");
const { API_URL, PRIVATE_KEY, ETHERSCAN_KEY } = process.env;
module.exports = {
  solidity: "0.8.1",
  defaultNetwork: "rinkeby",
  networks: {
    hardhat: {
    },
    rinkeby: {
      url: API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    }
  },
  etherscan: {
    apiKey: {
      polygonMumbai: ETHERSCAN_KEY
    }
  }
}
