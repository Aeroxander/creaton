<script lang="ts">
  import WalletAccess from '../templates/WalletAccess.svelte';
  import Button from '../components/Button.svelte';
  import Input from '../components/Input.svelte';
  import Blockie from '../components/Blockie.svelte';
  import {test} from 'creaton-common';
  import {logs} from 'named-logs';
  import {wallet, flow, chain} from '../stores/wallet';

  let creatorName: string = '';
  let subscriptionPrice: number;
  let projectDuration: number; // 6337 = approx # of blocks per day
  let files;
  let data;
  let counter;
  let key;
  let encrypted;

  $: if (files) {
    let file = files[0];
    let reader = new FileReader();
    reader.onload = function(evt) {
        data = new Uint8Array(evt.target.result);
    }
    reader.readAsArrayBuffer(file);
        const result = hubClient.addFileToBucket("testname", data);
        }
  }

  async function deployCreator() {
    await flow.execute(async (contracts) => {
      const receipt = await contracts.CreatonFactory.deployCreator(creatorName, subscriptionPrice);
      console.log(receipt);
      return receipt;
    });
  }

  function encrypt(data, key, counter, encrypted){ //TODO: add compression, try to find something more efficient than Base64, like Base85
    counter = new Uint8Array(16) //TODO: no counter reuse, probably should generate random but works for now
    window.crypto.subtle.encrypt(
        {
            name: "AES-CTR",
            counter: counter, 
            length: 128, 
        },
        key, 
        data 
    ).then(function(encData){
        encrypted = arrayBufferToBase64(encData);
        console.log(encrypted);
    });
}

function genKey(data){
    window.crypto.subtle.generateKey(
        {
            name: "AES-CTR",
            length: 256
        },
        true,
        ["encrypt", "decrypt"]
    ).then(function(keyData){
        key = keyData;
        return encrypt(data, key);
    });
    
}

function arrayBufferToBase64(buffer) {
	var binary = '';
	var bytes = new Uint8Array( buffer );
	var len = bytes.byteLength;
	for (var i = 0; i < len; i++) {
		binary += String.fromCharCode( bytes[ i ] );
	}
	return window.btoa(binary);
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
      <div class="field-row"><label>Upload content:</label> <input bind:files type="file" /></div>
      <button class="mt-6" type="button" on:click={deployCreator}>Create!</button>
    </form>
  </section>
</WalletAccess>
