require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");
require("dotenv").config();

module.exports = {
  solidity: "0.8.20",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    // polygonTestnet: {
    //   url: "https://rpc.public.zkevm-test.net",
    //   accounts: [process.env.PRIVATE_KEY],
    // },
  },
};
