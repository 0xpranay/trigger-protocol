/**
 * @type import('hardhat/config').HardhatUserConfig
 */

require("dotenv").config();
import "hardhat-contract-sizer";

import { HardhatUserConfig } from "hardhat/config";

import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import "hardhat-deploy";
import "@nomiclabs/hardhat-etherscan";
import "solidity-coverage";
import "hardhat-gas-reporter";
import "hardhat-tracer";

const mnemonic = process.env.DEPLOYER_MNEMONIC as string;

const config: HardhatUserConfig = {
  //@ts-ignore
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
  solidity: {
    version: "0.8.10",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: "./src",
    tests: "./test/integrationTests",
  },
  networks: {
    hardhat: {
      chainId: 1337,
    },
    localhost: {
      saveDeployments: true,
      tags: ["test", "local"],
    },
    goerli: {
      url: process.env.GOERLI_API_URL,
      accounts: { mnemonic: mnemonic },
      tags: ["staging"],
    },
    mainnet: {
      url: process.env.MAINNET_API_URL,
      accounts: { mnemonic: mnemonic },
      tags: ["staging"],
    },
    matic: {
      url: process.env.POLYGON_API_URL,
      accounts: [process.env.MATIC_KEY ?? ""],
    },
  },
  contractSizer: {
    runOnCompile: true,
    strict: true,
  },
};

export default config;
