require("@shardlabs/starknet-hardhat-plugin");
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  cairo: {
    // The default in this version of the plugin
    //version: "0.7.0",
    venv: "active"
  },
  // networks: {
  //   "develop": {
  //     url: "127.0.0.1:5000",
  //     gateway_url: "127.0.0.1:5000"
  //   }
  // },
  mocha: {
    // Used for deployment in Mocha tests
    // Defaults to "alpha" (for Alpha testnet), which is preconfigured even if you don't see it under `networks:`
    starknetNetwork: "alpha"
  }
};
