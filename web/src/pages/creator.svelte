<script lang="ts">
  import WalletAccess from '../templates/WalletAccess.svelte';
  import Button from '../components/Button.svelte';
  import {Contract} from '@ethersproject/contracts';
  import {contracts} from '../contracts.json';
  import {wallet, flow, chain} from '../stores/wallet';
  import { onMount } from 'svelte';

  let creatorContract;
  let contractAddress;
  let creator;
  let title;
  let avatarURL;
  let subscriptionPrice;
  let currentBalance;
  let isSubscribed;

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
        wallet.provider.getSigner()
      )

    creator = await creatorContract.creator();
    title = await creatorContract.creatorTitle();
    avatarURL = await creatorContract.avatarURL();
    subscriptionPrice = await creatorContract.subscriptionPrice();
    console.log(wallet.address);
    [currentBalance, isSubscribed] = await creatorContract.currentBalance(wallet.address);
  }

  async function handleSubscribe(){
    if(!subscriptionPrice) return; // todo: show error
      try {
        const receipt = await creatorContract.subscribe(subscriptionPrice);
        console.log(receipt)
      } catch(err){
        console.error(err)
      };
  }
</script>
<WalletAccess>
  <section class="py-8 px-4 text-center max-w-md mx-auto">
    {#if !creator || !title || !avatarURL || !subscriptionPrice}
      <div>Fetching creator...</div>
    {:else}
      <h3 class="text-4xl leading-normal font-medium text-gray-900 dark:text-gray-500 truncate">{title}</h3>
      <p class="mb-2 text-base leading-6 text-gray-500 dark:text-gray-300 text-center">
        {creator}
      </p>
      <img class="w-full" src={avatarURL} alt={title}/>
      {#if !isSubscribed}
      <Button class="mt-3" on:click={handleSubscribe}>
            Subscribe - ${subscriptionPrice}</Button>
      {:else}
      <p class="mt-4 text-2xl leading-6 dark:text-gray-300 text-center">
        Subscription balance: ${currentBalance}
      </p>
      {/if}
    {/if}
  </section>
</WalletAccess>