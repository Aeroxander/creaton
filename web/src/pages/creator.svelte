<script lang="ts">
  import WalletAccess from '../templates/WalletAccess.svelte';
  import Button from '../components/Button.svelte';
  import Input from '../components/Input.svelte';
  import Blockie from '../components/Blockie.svelte';
  import {test} from 'creaton-common';
  import {logs} from 'named-logs';
  import {wallet, balance, flow, chain} from '../stores/wallet';
  import { identity } from 'svelte/internal'; 
  import { TextileStore } from '../stores/textileStore'
  import web3 from Web3;
import { emptyDirSync } from 'fs-extra';

  const web3 = new Web3(wallet.web3Provider);

  const textile: TextileStore = new TextileStore(wallet);

  let creatorName: string = '';
  let subscriptionPrice: number;
  let files;
  let encrypted;
  var arrayBuffer, uint8Array;

  $: if (files) {
    let file = files[0];
    let reader = new FileReader();
      reader.onload = async function(evt) {
        arrayBuffer = this.result;
        uint8Array = new Uint8Array(arrayBuffer);
      }
    reader.readAsArrayBuffer(file);
      encrypted = textile.uploadFile(uint8Array);
    }

    //TODO: set contract.address
    const MembershipTier = new web3.eth.Contract(contract.abi, contract.address, {
      from: web3.eth.accounts[0],
    });

    //TODO: add error catching/validation
    let metadata = MembershipTier.methods
      //built-in mint function in openzeppelin minterpauser preset
      .mint(membershipAddress, 1, 1, `${contentName},${subscriptionPrice},${result.path.path}`) //mint(to, id, amount, data) might need to iterate ID
      .encodeABI();

    web3.eth.sendTransaction(
    {
      from: web3.eth.accounts[0],
      to: contract.address,
      data: metadata,
    },
    function (receipt) {
      console.log(receipt);
    }
  );
  }

  async function deployCreator() {
    await flow.execute(async (contracts) => {
      const receipt = await contracts.CreatonFactory.deployCreator(this.creatorName, this.subscriptionPrice);
      console.log(receipt);
      return receipt;
    });
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
        <label>Name:</label>
        <Input type="text" placeholder="Name / title" className="field" bind:value={creatorName} />
      </div>
      <div class="field-row">
        <label>Subscription Price: $</label>
        <Input type="number" placeholder="Cost per month" className="field" bind:value={subscriptionPrice} />
      </div>
      <div class="field-row">
        <label>Upload content:</label>
        <input accept="image/png, image/jpeg" bind:files type="file" />
      </div>
      <button class="mt-6" type="button" on:click={deployCreator}>Create!</button>
    </form>
  </section>
</WalletAccess>
