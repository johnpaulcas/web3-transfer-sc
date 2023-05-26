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
    blockConfirmations: 5,
  },
  zkTestnet: {
    blockConfirmations: 5,
  },
}

export const developmentChains = ['hardhat', 'localhost']
