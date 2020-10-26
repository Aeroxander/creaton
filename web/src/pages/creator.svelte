<script lang="ts">
  import WalletAccess from '../templates/WalletAccess.svelte';
  import Button from '../components/Button.svelte';
  import {Contract} from '@ethersproject/contracts';
  import {contracts} from '../contracts.json';
  import {wallet, flow, chain} from '../stores/wallet';
  import { onMount } from 'svelte';

  let creatorContract;
  let contractAddress;
  let owner;
  let title;
  let avatarURL;
  let subscriptionPrice;
  let currentBalance;

  if (typeof window !== 'undefined') {
    contractAddress = window.location.pathname.split('/')[2];
  }

  onMount(async () => {
    if(wallet.provider){
      loadCreatorData();
    } else {
      flow.execute(async () => {
        loadCreatorData();
      })
    }
  })

  async function loadCreatorData(){
    creatorContract = await new Contract(
        contractAddress, 
        contracts.Creator.abi,
        wallet.provider
      )

    owner = await creatorContract.owner();
    title = await creatorContract.creatorTitle();
    avatarURL = await creatorContract.avatarURL();
    subscriptionPrice = await creatorContract.subscriptionPrice();
    creatorContract.currentBalance(owner).then(console.log).catch(console.error)  // <- TODO: this is not working
  }

  async function handleSubscribe(){
    if(!subscriptionPrice) return; // todo: show error
    flow.execute(async (contracts) => {
      return await contracts.Creator.subscribe(subscriptionPrice);
    })
  }
</script>
<WalletAccess>
  <section class="py-8 px-4 text-center max-w-md mx-auto">
    {#if !owner || !title || !avatarURL || !subscriptionPrice}
      <div>Fetching creator...</div>
    {:else}
      <h3 class="text-4xl leading-normal font-medium text-gray-900 dark:text-gray-500 truncate">{title}</h3>
      <p class="mb-2 text-base leading-6 text-gray-500 dark:text-gray-300 text-center">
        {owner}
      </p>
      <img class="w-full" src={avatarURL} alt={title}/>
      <Button class="mt-3" on:click={handleSubscribe}>
            Subscribe - ${subscriptionPrice}</Button>
      <p class="mb-2 text-base leading-6 text-gray-500 dark:text-gray-300 text-center">
        Current balance: {currentBalance}
      </p>
    {/if}
  </section>
</WalletAccess>