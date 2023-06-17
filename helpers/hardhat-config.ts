export interface networkConfigItem {
  ethUsdPriceFeed?: string
  blockConfirmations?: number
}

export interface networkConfigInfo {
  [key: string]: networkConfigItem
}

export const networkConfig: networkConfigInfo = {
  localhost: {},
  hardhat: {},
  goerli: {
    blockConfirmations: 3,
  },
  mainnet: {
    blockConfirmations: 3,
  },
  zkTestnet: {
    blockConfirmations: 3,
  },
  zkEra: {
    blockConfirmations: 3,
  },
}

export const developmentChains = ['hardhat', 'localhost']
