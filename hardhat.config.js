require("@nomiclabs/hardhat-ethers");
module.exports = {
  networks: {
    ganache: {
      url: "http://127.0.0.1:7545",
      accounts: ['0x3dddef54e371ced961f577b9f57abfa1110c8ede2864016468776ce43bbaade8'], // Remember to replace '0x...' with your actual account private key(s)
    },
  },
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 20000
  }
};
