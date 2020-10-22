import {BuidlerRuntimeEnvironment, DeployFunction} from '@nomiclabs/buidler/types';
import { utils } from 'ethers';

import {ethers} from '@nomiclabs/buidler';
const Transaction = require("ethereumjs-tx").Transaction;
const ethUtils = require("ethereumjs-util");

const func: DeployFunction = async function (bre: BuidlerRuntimeEnvironment) {
  let {deployer} = await bre.getNamedAccounts();
  const {deploy} = bre.deployments;
  const useProxy = !bre.network.live;

  console.log('deployer: ', deployer);

  // proxy only in non-live network (localhost and buidlerevm) enabling HCR (Hot Contract Replaement)
  // in live network, proxy is disabled and constructor is invoked
  await deploy('CreatonFactory', {from: deployer, proxy: useProxy, args: [], log: true});
  await deploy('Creator', {
    from: deployer,
    proxy: useProxy && 'init',
    args: ['https://utulsa.edu/wp-content/uploads/2018/08/generic-avatar.jpg', 'ETHGlobal', 5],
    log: true,
  });


  console.log("Static erc1820 deployment initiated");
  const targetAddress = "0xa990077c3205cbDf861e17Fa532eeB069cE9fF96";
  const rawTx = {
    nonce: 0,
    gasPrice: 10000,
    value: 0,
    data: "0x" + require("../src/superfluid/introspection/ERC1820Registry.json").bin,
    gasLimit: 800000,
    v: 27,
    r: "0x1820182018201820182018201820182018201820182018201820182018201820",
    s: "0x1820182018201820182018201820182018201820182018201820182018201820"
    
};

const tx = new Transaction(rawTx);

const signer = await ethers.getSigners();
const res = {
  sender: ethUtils.toChecksumAddress(
    "0x" + tx.getSenderAddress().toString("hex")
),
  rawTx: "0x" + tx.serialize().toString("hex"),
  contractAddr: ethUtils.toChecksumAddress(
      "0x" + ethUtils.generateAddress(tx.getSenderAddress(), ethUtils.toBuffer(0)).toString("hex")
  ),
};
console.log('test')
//assert.equal("0xa990077c3205cbDf861e17Fa532eeB069cE9fF96", res.sender);
//assert.equal("0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24", res.contractAddr);

//expect(await res.sender.to.equal(
//  '0xa990077c3205cbDf861e17Fa532eeB069cE9fF96'
//));

//expect(await res.contractAddr.to.equal(
//  '0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24'
//));

  //sendeth
  
  const tx1 = await signer[0].sendTransaction({
    to: res.sender,
    value: utils.parseEther("0.08") //ethers.utils.parseEther("0.08"), 
  });
  await tx1.wait();
  console.log("erc1820 target address funded");
  const tx2 = await ethers.provider.sendTransaction(res.rawTx);
  await tx2.wait();
  //console.log("REACT_APP_ERC1820='" + ERC820_ADDRESS + "'");
  //await saveContractAddress("erc1820", ERC820_ADDRESS);
  console.log("successful erc1820 deploy!")
  

  return !useProxy; // when live network, record the script as executed to prevent rexecution
};
export default func;
