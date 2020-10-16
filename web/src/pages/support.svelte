<script lang="ts">
  import WalletAccess from '../templates/WalletAccess.svelte';
  import Button from '../components/Button.svelte';
  import Input from '../components/Input.svelte';
  import Blockie from '../components/Blockie.svelte';
  import {test} from 'creaton-common';
  import {logs} from 'named-logs';
  import {wallet, flow, chain} from '../stores/wallet';
  import TruffleContract from '@truffle/contract';
  import SuperfluidSDK from '@superfluid-finance/ethereum-contracts';
  import wad4human from '@decentral.ee/web3-helpers';

  let sf = new SuperfluidSDK.Framework({
    chainId: 5, //goerli testnet
    //version: "master",
    version: '0.1.2-preview-20201014',
    web3Provider: wallet.web3Provider,
  });

  let creatorName: string = '';
  let subscriptionPrice: number;

  let usdc;
  let usdcx;
  let app;
  let usdcApproved;

  let membership; //get membership from URL creaton.io/creatoraddress/membershipaddress

  //TODO: subgraph
  //import GET_TRANSFERS from './graphql/subgraph';

  //TODO: set right address and get superapp json
  const APP_ADDRESS = '0x4690Fa515cfEC6afb03bC5B80FA0De2BD9e1103b';
  const MINIMUM_FLOW_RATE = '3858024691358'; //TODO
  const CreatonSuperApp = this.TruffleContract(require('./CreatonSuperApp.json'));

  async function approveUSDC() {
    const usdcAddress = await sf.resolver.get('tokens.USDC');
    usdc = await sf.contracts.TestToken.at(usdcAddress);
    const usdcxWrapper = await sf.getERC20Wrapper(usdc);
    usdcx = await sf.contracts.ISuperToken.at(usdcxWrapper.wrapperAddress);

    //TODO: The Creaton Super App
    //CreatonSuperApp.setProvider(wallet.web3Provider);
    //app = await CreatonSuperApp.at(APP_ADDRESS);

    await sf.initialize();
    //approve unlimited please
    await usdc
      .approve(usdcx.address, '115792089237316195423570985008687907853269984665640564039457584007913129639935', {
        from: wallet.address,
      })
      .then(async (i) => (usdcApproved = wad4human(await usdc.allowance.call(wallet.address, usdcx.address))));
  }

  async function startSupport() {
    var usdcxBalance = wad4human(await usdcx.balanceOf.call(wallet.address));
    var call;
    if (usdcxBalance < 10)
      //TODO: actual membership price + double the collateral/streaming amount
      call = [
        [
          2, // upgrade 10 usdcx to support
          usdcx.address,
          sf.web3.eth.abi.encodeParameters(['uint256'], [sf.web3.utils.toWei('10', 'ether').toString()]),
        ],
        [
          0, // approve the collateral fee
          usdcx.address,
          sf.web3.eth.abi.encodeParameters(
            ['address', 'uint256'],
            [APP_ADDRESS, sf.web3.utils.toWei('5', 'ether').toString()]
          ),
        ],
        [
          5, // callAppAction to support
          app.address,
          app.contract.methods.support('0x').encodeABI(),
        ],
        [
          4, // create constant flow (5/mo)
          sf.agreements.cfa.address,
          sf.agreements.cfa.contract.methods
            .createFlow(usdcx.address, app.address, MINIMUM_FLOW_RATE.toString(), '0x')
            .encodeABI(),
        ],
      ];
    else
      call = [
        [
          0, // approve the collateral fee
          usdcx.address,
          sf.web3.eth.abi.encodeParameters(
            ['address', 'uint256', 'address'],
            [APP_ADDRESS, sf.web3.utils.toWei('5', 'ether').toString(), membership_address] //TODO
          ),
        ],
        [
          5, // callAppAction to support
          app.address,
          app.contract.methods.support('0x').encodeABI(),
        ],
        [
          4, // create constant flow
          sf.agreements.cfa.address,
          sf.agreements.cfa.contract.methods
            .createFlow(usdcx.address, app.address, MINIMUM_FLOW_RATE.toString(), '0x')
            .encodeABI(),
        ],
      ];
    console.log('this is the batchcall: ', call);
    await sf.host.batchCall(call, {from: wallet.address});

    await sf.host.batchCall(
      [
        [
          2, // upgrade 10 usdcx to support
          usdcx.address,
          sf.web3.eth.abi.encodeParameters(['uint256'], [sf.web3.utils.toWei('10', 'ether').toString()]),
        ],
        [
          0, // approve the collateral fee
          usdcx.address,
          sf.web3.eth.abi.encodeParameters(
            ['address', 'uint256'],
            [APP_ADDRESS, sf.web3.utils.toWei('5', 'ether').toString()]
          ),
        ],
        [
          5, // callAppAction to support
          app.address,
          app.contract.methods.support('0x').encodeABI(),
        ],
        [
          4, // create constant flow (5/mo)
          sf.agreements.cfa.address,
          sf.agreements.cfa.contract.methods
            .createFlow(usdcx.address, app.address, MINIMUM_FLOW_RATE.toString(), '0x')
            .encodeABI(),
        ],
      ],
      {from: wallet.address}
    );
  }

  async function stopSupport() {
    await sf.host.callAgreement(
      sf.agreements.cfa.address,
      sf.agreements.cfa.contract.methods.deleteFlow(usdcx.address, wallet.address, app.address, '0x').encodeABI(),
      {from: wallet.address}
    );
  }

  async function check() {
    let supporting = (await sf.agreements.cfa.getFlow(usdcx.address, wallet.address, app.address)).timestamp > 0;
  }
</script>

<style>
  ::-webkit-input-placeholder {
    /* Chrome/Opera/Safari */
    color: black;
    opacity: 0.5;
  }
  ::-moz-placeholder {
    /* Firefox 19+ */
    color: black;
    opacity: 0.5;
  }
  :-ms-input-placeholder {
    /* IE 10+ */
    color: black;
    opacity: 0.5;
  }
  :-moz-placeholder {
    /* Firefox 18- */
    color: black;
    opacity: 0.5;
  }
  .field-row {
    @apply mt-3 flex items-center;
  }

  label {
    @apply mr-3;
  }

  button {
    @apply flex-shrink-0 bg-pink-600 hover:bg-pink-700 border-pink-600 hover:border-pink-700 text-sm border-4
          text-white py-1 px-2 rounded disabled:bg-gray-400 disabled:border-gray-400 disabled:cursor-not-allowed;
  }
</style>

<WalletAccess>
  <section class="py-8 px-4 text-center">
    <div class="max-w-auto md:max-w-lg mx-auto">
      <h1 class="text-4xl mb-2 font-heading">Become a Creator</h1>
    </div>
    <form class="content flex flex-col max-w-lg mx-auto">
      <div class="field-row">
        <p>Your USDC approved balance: {usdcApproved}</p>
      </div>
      <div class="field-row"><button class="mt-6" type="button" on:click={approveUSDC}>USDC approval</button></div>
      <div class="field-row"><button class="mt-6" type="button" on:click={startSupport}>Support!</button></div>
    </form>
  </section>
</WalletAccess>
