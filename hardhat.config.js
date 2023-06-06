require("@nomiclabs/hardhat-waffle");

module.exports = {
  networks: {
    hardhat: {
      forking: {
        url: "http://localhost:8545", // This is the default Ganache CLI port
      },
    },
  },
  solidity: "0.8.4",
};
