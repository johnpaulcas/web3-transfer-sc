import * as dotenv from 'dotenv'
dotenv.config()

import { HardhatUserConfig } from 'hardhat/config'
import '@nomicfoundation/hardhat-toolbox'

import '@nomicfoundation/hardhat-foundry'

import '@matterlabs/hardhat-zksync-verify'
import '@matterlabs/hardhat-zksync-solc'

import 'hardhat-deploy'

const zkTestnet = {
  url: process.env.ZK_TESTNET_URL || '',
  ethNetwork: 'goerli',
  zksync: true,
  accounts:
    process.env.ZK_TESTNET_PRIVATE_KEY !== undefined
      ? [process.env.ZK_TESTNET_PRIVATE_KEY]
      : [],
  verifyURL: process.env.ZK_TESTNET || '',
}

const zkEra = {
  url: process.env.ZK_MAINNET_URL || '',
  ethNetwork: 'mainnet',
  zksync: true,
  accounts:
    process.env.ZK_MAINNET_PRIVATE_KEY !== undefined
      ? [process.env.ZK_MAINNET_PRIVATE_KEY]
      : [],
  verifyURL: process.env.ZK_MAINNET_EXPLORER || '',
}

const config: HardhatUserConfig = {
  zksolc: {
    version: '1.3.10',
    compilerSource: 'binary',
    settings: {},
  },
  solidity: {
    version: '0.8.9',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    goerli: {
      url: process.env.GOERLI_URL || '',
      zksync: false,
    },
    mainnet: {
      url: process.env.MAINNET_URL || '',
      zksync: false,
    },
    zkTestnet,
    zkEra,
  },
  namedAccounts: {
    deployer: {
      default: 0, // here this will by default take the first account as deployer
      1: 0, // similarly on mainnet it will take the first account as deployer. Note though that depending on how hardhat network are configured, the account 0 on one network can be different than on another
    },
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts',
    deployments: './deployments',
  },
}

export default config
