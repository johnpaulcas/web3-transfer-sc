import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import verify from '../helpers/verify'
import { networkConfig, developmentChains } from '../helpers/hardhat-config'

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  // @ts-ignore
  const { getNamedAccounts, deployments, network } = hre
  const { deploy, log } = deployments
  const { deployer } = await getNamedAccounts()

  log('----------------------------------------------------')
  log(`Network ${network.name}`)
  log(`Deployer ${deployer}`)

  const token = await deploy('MultiTokenDisperser', {
    from: deployer,
    args: [],
    log: true,
    // we need to wait if on a live network so we can verify properly
    waitConfirmations: networkConfig[network.name].blockConfirmations || 1,
  })

  log(`Zk (${network.name}): ${token.address}`)

  if (!developmentChains.includes(network.name) && process.env.ZK_TESTNET) {
    await verify(token.address, [])
  }
}

export default deploy
deploy.tags = ['zk']
