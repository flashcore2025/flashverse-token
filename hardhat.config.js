require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");
require("dotenv").config();

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.20",
      },
      {
        version: "0.8.22",
      }
      // {
      //   version: "0.8.18",
      //   settings: {
      //     optimizer: {
      //       enabled: true,
      //       runs: 200,
      //     },
      //   },
      // },
    ],
  },
  networks: {
    // Localhost (optional)
    // localhost: {
    //   url: "http://127.0.0.1:8545",
    // },

    polygon_amoy: {
      url: "https://rpc-amoy.polygon.technology",
      chainId: 80002,
      accounts: [process.env.PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: {
      polygon_amoy: process.env.POLYGONSCAN_API_KEY
    },
    customChains: [
      {
        network: "polygon_amoy",
        chainId: 80002,
        urls: {
          apiURL: "https://api-amoy.polygonscan.com/api",
          browserURL: "https://amoy.polygonscan.com"
        }
      }
    ]
  },
  sourcify: {
    enabled: true
  }
};
