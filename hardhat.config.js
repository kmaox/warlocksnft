require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

// Go to https://www.alchemyapi.io, sign up, create
// a new App in its dashboard, and replace "KEY" with its key

// Replace this private key with your Ropsten account private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Be aware of NEVER putting real Ether into testing accounts
const RINKEBY_PRIVATE_KEY =
  "0x764b448dab264ccb0808a226fb2ba23b4f0e88bf2cf406101ad867679369af42";

module.exports = {
  solidity: "0.8.4",
  settings: {
    optimizer: {
      enabled: true,
      runs: 2000,
    },
  },
  networks: {
    rinkeby: {
      url: "https://eth-rinkeby.alchemyapi.io/v2/2rkZXmXP1QBDaKzQZE_cFW142VAMVvEn",
      accounts: [`${RINKEBY_PRIVATE_KEY}`],
    },
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: "RBTBZCNVW7I13Y7SHHA5WGRFMHKC6I8I6F",
  },
};
