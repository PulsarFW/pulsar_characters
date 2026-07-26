<script lang="ts">
	import { onMount } from 'svelte';
	import { store, attachMessageListener } from './lib/store.svelte';
	import { STATE_CHARACTERS, STATE_CREATE, STATE_SPAWN } from './lib/types';
	import Loader from './lib/Loader.svelte';
	import Splash from './lib/Splash.svelte';
	import Characters from './lib/Characters.svelte';
	import Create from './lib/Create.svelte';
	import Spawn from './lib/Spawn.svelte';

	onMount(() => attachMessageListener());
</script>

{#if !store.app.hidden}
	<main>
		{#if store.loader.loading}
			<Loader />
		{:else if store.app.state === STATE_CHARACTERS}
			<Characters />
		{:else if store.app.state === STATE_CREATE}
			<Create />
		{:else if store.app.state === STATE_SPAWN}
			<Spawn />
		{:else}
			<Splash />
		{/if}
	</main>
{/if}

<style>
	main {
		position: relative;
		width: 100vw;
		height: 100vh;
		overflow: hidden;
	}
</style>
