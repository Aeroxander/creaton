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

  if (typeof window !== 'undefined') {
    contractAddress = window.location.pathname.split('/')[2];

    onMount(async () => {
      creatorContract = await new Contract(
          contractAddress, 
          contracts.Creator.abi,
          wallet.provider
        )

      owner = await creatorContract.owner();
      title = await creatorContract.creatorTitle();
      avatarURL = await creatorContract.avatarURL();
      subscriptionPrice = await creatorContract.subscriptionPrice();
    })
  }

  async function handleSubscribe(){
    if(!subscriptionPrice) return; // todo: show error
    flow.execute(async (contracts) => {
      await contracts.creator.subscribe(subscriptionPrice);
    })
  }
</script>
<WalletAccess>
  <section class="py-8 px-4 text-center max-w-md mx-auto">
    {#if !owner}
      <div>Fetching creator...</div>
    {:else}
      <h3 class="text-4xl leading-normal font-medium text-gray-900 dark:text-gray-500 truncate">{title}</h3>
      <p class="mb-2 text-base leading-6 text-gray-500 dark:text-gray-300 text-center">
        {owner}
      </p>
      <img class="w-full" src={avatarURL} alt={title}/>
          <Button class="mt-3" on:click={handleSubscribe}>
            Subscribe - ${subscriptionPrice}</Button>
    {/if}
  </section>
</WalletAccess>