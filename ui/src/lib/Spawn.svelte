<script lang="ts">
	import { config } from '../config';
	import { store, setScreen, showLoader, deselectCharacter, deselectSpawn, markSelectedPlayedNow } from './store.svelte';
	import { Nui } from './nui';
	import { STATE_CHARACTERS } from './types';
	import Motd from './Motd.svelte';
	import SpawnButton from './SpawnButton.svelte';

	const character = $derived(store.characters.selected);
	const spawn = $derived(store.spawn.selected);

	function onSpawn() {
		if (!character || !spawn) return;
		Nui.playCharacter(spawn, character);
		showLoader('Spawning');
		markSelectedPlayedNow();
		deselectCharacter();
		deselectSpawn();
	}

	function goBack() {
		deselectCharacter();
		deselectSpawn();
		setScreen(STATE_CHARACTERS);
	}
</script>

<div class="screen">
	<Motd />
	<img class="logo" src={config.logo} alt={config.brandName} />

	<div class="panel list-panel">
		<div class="panel-header">Spawn Locations</div>
		<div class="list">
			{#each store.spawn.spawns as point, i (`${point.id}-${i}`)}
				<SpawnButton spawn={point} onPlay={onSpawn} />
			{:else}
				<div class="empty">No spawn locations available</div>
			{/each}
		</div>
	</div>

	<div class="panel summary-panel">
		<div class="summary-row">
			<span class="k">Character</span>
			<span class="v">{character ? `${character.First} ${character.Last}` : '—'}</span>
		</div>
		<div class="summary-row">
			<span class="k">Location</span>
			<span class="v" class:muted={!spawn}>{spawn ? spawn.label : 'No location selected'}</span>
		</div>
		<div class="actions">
			<button class="btn btn-ghost" type="button" onclick={goBack}>Cancel</button>
			<button class="btn btn-primary" type="button" disabled={!spawn} onclick={onSpawn}>Play</button>
		</div>
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

	.panel {
		background: var(--color-bg-panel);
		border: var(--border-subtle);
		border-radius: var(--radius);
	}

	.list-panel {
		position: absolute;
		top: 12vh;
		left: 3vw;
		width: 22vw;
		max-height: 66vh;
		display: flex;
		flex-direction: column;
		overflow: hidden;
	}

	.panel-header {
		flex-shrink: 0;
		padding: 1.2vh 1.2vw;
		font-family: var(--font-heading);
		font-size: 1.15vmin;
		letter-spacing: 0.04em;
		text-transform: uppercase;
		color: var(--color-text-muted);
		border-bottom: var(--border-subtle);
	}

	.list {
		display: flex;
		flex-direction: column;
		gap: 0.2vh;
		padding: 0.6vh;
		overflow-y: auto;
	}

	.empty {
		padding: 1.4vh 1vw;
		font-size: 1.1vmin;
		color: var(--color-text-muted);
	}

	.summary-panel {
		position: absolute;
		bottom: 6vh;
		left: 50%;
		transform: translateX(-50%);
		width: 26vw;
		padding: 1.6vh 1.6vw;
	}

	.summary-row {
		display: flex;
		justify-content: space-between;
		align-items: baseline;
		padding: 0.7vh 0;
	}

	.summary-row + .summary-row {
		border-top: var(--border-subtle);
	}

	.k {
		font-size: 1vmin;
		letter-spacing: 0.04em;
		text-transform: uppercase;
		color: var(--color-text-muted);
	}

	.v {
		font-size: 1.25vmin;
		color: var(--color-text);
		text-align: right;
	}

	.v.muted {
		color: var(--color-text-muted);
	}

	.actions {
		margin-top: 1.4vh;
		display: flex;
		justify-content: flex-end;
		gap: 0.8vw;
	}

	.btn {
		border: none;
		padding: 0.8vh 1.6vw;
		font-size: 1.15vmin;
		font-family: var(--font-body);
		letter-spacing: 0.02em;
		cursor: pointer;
		border-radius: var(--radius);
	}

	.btn-ghost {
		background: transparent;
		color: var(--color-text-muted);
		border: var(--border-subtle);
	}

	.btn-ghost:hover {
		color: var(--color-text);
	}

	.btn-primary {
		background: var(--color-primary);
		color: #ffffff;
	}

	.btn-primary:hover {
		background: var(--color-primary-light);
	}

	.btn-primary:disabled {
		background: var(--color-bg-panel-alt);
		color: var(--color-text-muted);
		cursor: not-allowed;
	}
</style>
