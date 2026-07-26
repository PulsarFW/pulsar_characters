<script lang="ts">
	import type { SpawnPoint } from './types';
	import Icon from './Icon.svelte';
	import { Nui } from './nui';
	import { selectSpawn, store } from './store.svelte';

	let { spawn, onPlay }: { spawn: SpawnPoint; onPlay: () => void } = $props();

	// reference equality, not id equality, spawn point ids aren't guaranteed unique across sources
	const active = $derived(store.spawn.selected === spawn);

	function onClick() {
		selectSpawn(spawn);
		Nui.selectSpawn(spawn);
	}
</script>

<button class="row" class:active type="button" onclick={onClick} ondblclick={onPlay}>
	<span class="icon">
		<Icon name={spawn.icon ?? 'map-pin'} size="1.3vmin" />
	</span>
	<span class="label">{spawn.label}</span>
</button>

<style>
	.row {
		display: flex;
		align-items: center;
		gap: 0.7vw;
		width: 100%;
		padding: 0.9vh 0.8vw;
		background: transparent;
		border: none;
		border-left: 0.18vw solid transparent;
		border-radius: var(--radius);
		color: var(--color-text);
		text-align: left;
		cursor: pointer;
		font-family: inherit;
		transition: background 120ms ease;
	}

	.row:hover {
		background: color-mix(in srgb, var(--color-text) 5%, transparent);
	}

	.row.active {
		border-left-color: var(--color-primary);
		background: color-mix(in srgb, var(--color-primary) 10%, transparent);
	}

	.icon {
		display: flex;
		color: var(--color-primary-light);
		flex-shrink: 0;
	}

	.label {
		font-size: 1.15vmin;
	}
</style>
