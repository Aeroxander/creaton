<script lang="ts">
  import Dropzone from "svelte-file-dropzone";

  let files = {
    accepted: [],
    rejected: []
  };

  function handleFilesSelect(e) {
    const { acceptedFiles, fileRejections } = e.detail;
    files.accepted = [...files.accepted, ...acceptedFiles];
    files.rejected = [...files.rejected, ...fileRejections];
  }
</script>

<section class="py-8 px-4 text-center">
  <div class="max-w-auto md:max-w-lg mx-auto">
    <h1 class="text-4xl mb-2 font-heading">Creator Admin</h1>
     <Dropzone on:drop={handleFilesSelect} />
      <ol>
      {#each files.accepted as item}
        <li>{item.name}</li>
      {/each}
      </ol>
  </div>
</section>
