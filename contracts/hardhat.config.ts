import 'dotenv';
import {Wallet} from '@ethersproject/wallet';
import 'hardhat/config';
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';
import {HardhatUserConfig} from 'hardhat/types';
//import {HardhatConfig} from 'hardhat/types';
//usePlugin('hardhat-ethers-v5');
//usePlugin('hardhat-deploy');
//usePlugin('solidity-coverage');
//usePlugin("@nomiclabs/hardhat-web3");

const mnemonic = process.env.MNEMONIC;
let accounts;
let hardhatEvmAccounts;
if (mnemonic) {
  accounts = {
    mnemonic,
  };
  hardhatEvmAccounts = [];
  for (let i = 0; i < 10; i++) {
    const wallet = Wallet.fromMnemonic(mnemonic, "m/44'/60'/0'/0/" + i);
    hardhatEvmAccounts.push({
      privateKey: wallet.privateKey,
      balance: '1000000000000000000000',
    });
  }
} else {
  hardhatEvmAccounts = [];
  for (let i = 0; i < 10; i++) {
    const wallet = Wallet.createRandom();
    hardhatEvmAccounts.push({
      privateKey: wallet.privateKey,
      balance: '1000000000000000000000',
    });
  }
}

const config: HardhatUserConfig = {
  solidity: {
    version: '0.7.1',
    settings: {
      optimizer: {
        enabled: true,
        runs: 2000,
      },
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
  networks: {
    //coverage: {
    //  url: 'http://localhost:5458',
    //},
    hardhat: {
      accounts: hardhatEvmAccounts,
    },
    localhost: {
      url: 'http://localhost:8545',
      accounts,
    },
    staging: {
      url: 'https://goerli.infura.io/v3/' + process.env.INFURA_TOKEN,
      accounts,
    },
    rinkeby: {
      url: 'https://rinkeby.infura.io/v3/' + process.env.INFURA_TOKEN,
      accounts,
    },
    kovan: {
      url: 'https://kovan.infura.io/v3/' + process.env.INFURA_TOKEN,
      accounts,
    },
    goerli: {
      url: 'https://goerli.infura.io/v3/' + process.env.INFURA_TOKEN,
      accounts,
    },
    mainnet: {
      url: 'https://mainnet.infura.io/v3/' + process.env.INFURA_TOKEN,
      accounts,
    },
  },
  paths: {
    sources: 'src',
  },
};
export default config;
