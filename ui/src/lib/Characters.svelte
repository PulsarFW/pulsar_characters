<script lang="ts">
	import { config } from '../config';
	import { store } from './store.svelte';
	import Motd from './Motd.svelte';
	import Help from './Help.svelte';
	import CharacterButton from './CharacterButton.svelte';
	import CreateCharacterButton from './CreateCharacterButton.svelte';

	const canCreate = $derived(store.characters.characters.length < store.characters.characterLimit);
</script>

<div class="screen">
	<Motd />
	<Help />
	<img class="logo" src={config.logo} alt={config.brandName} />

	<div class="grid">
		{#if canCreate}
			<CreateCharacterButton />
		{/if}
		{#each store.characters.characters as character (character.ID)}
			<CharacterButton {character} />
		{/each}
	</div>
</div>

<style>
	.screen {
		position: relative;
		width: 100%;
		height: 100%;
	}

	.logo {
		position: absolute;
		top: 2vh;
		right: 2vw;
		width: 14vmin;
	}

	.grid {
		position: absolute;
		left: 0;
		right: 0;
		bottom: 6vh;
		display: flex;
		flex-wrap: nowrap;
		justify-content: center;
		gap: 1.2vw;
		padding: 0 2vw;
		overflow-x: auto;
	}
</style>
