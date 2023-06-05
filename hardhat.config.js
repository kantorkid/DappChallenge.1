module.exports = {
  networks: {
    ganache: {
      url: "http://127.0.0.1:7545",
      accounts: ['3330b205a183f3b6aca1ba7f9cf375928f899df09c9a9a4ecfcf1e40dcd05ce3'], // Remember to replace '0x...' with your actual account private key(s)
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
