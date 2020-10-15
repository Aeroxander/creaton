import {BuidlerRuntimeEnvironment, DeployFunction} from '@nomiclabs/buidler/types';

const func: DeployFunction = async function (bre: BuidlerRuntimeEnvironment) {
  const {deployer} = await bre.getNamedAccounts();
  const {deploy} = bre.deployments;
  const useProxy = !bre.network.live;

  // proxy only in non-live network (localhost and buidlerevm) enabling HCR (Hot Contract Replaement)
  // in live network, proxy is disabled and constructor is invoked
  await deploy('CreatonFactory', {from: deployer, proxy: useProxy, args: [], log: true});
  await deploy('Creator', {from: deployer, proxy: useProxy && 'init', args: ['ETHGlobal', 5, 12], log: true});

  return !useProxy; // when live network, record the script as executed to prevent rexecution
};
export default func;
