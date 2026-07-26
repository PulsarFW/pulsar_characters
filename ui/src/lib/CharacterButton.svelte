<script lang="ts">
	import type { CharacterRecord } from './types';
	import Icon from './Icon.svelte';
	import { Nui } from './nui';
	import { showLoader, selectCharacter, store } from './store.svelte';
	import DeleteConfirmDialog from './DeleteConfirmDialog.svelte';

	let { character }: { character: CharacterRecord } = $props();

	let confirmingDelete = $state(false);

	const active = $derived(store.characters.selected?.ID === character.ID);

	const jobLine = $derived.by(() => {
		const jobs = character.Jobs ?? [];
		if (jobs.length === 0) return 'Unemployed';
		if (jobs.length === 1) {
			const job = jobs[0];
			const org = job.Workplace ? job.Workplace.Name : job.Name;
			return `${org} - ${job.Grade.Name}`;
		}
		return `${jobs.length} Jobs`;
	});

	const lastPlayedLine = $derived(
		character.LastPlayed === -1
			? 'Never'
			: new Date(character.LastPlayed).toLocaleString(undefined, {
					month: 'numeric',
					day: 'numeric',
					year: 'numeric',
					hour: 'numeric',
					minute: '2-digit',
					second: '2-digit',
				}),
	);

	function onDoubleClick() {
		showLoader('Getting Spawn Points');
		selectCharacter(character);
		Nui.selectCharacter(character.ID);
	}

	function onContextMenu(e: MouseEvent) {
		e.preventDefault();
		confirmingDelete = true;
	}

	function confirmDelete() {
		confirmingDelete = false;
		showLoader('Deleting Character');
		Nui.deleteCharacter(character.ID);
	}
</script>

<button class="card" class:active ondblclick={onDoubleClick} oncontextmenu={onContextMenu} type="button">
	<div class="top">
		<span class="sid">#{character.SID}</span>
		<Icon name={character.Gender === 1 ? 'venus' : 'mars'} size="1.1vmin" />
	</div>

	<div class="avatar">
		<Icon name="user" size="4.2vmin" />
	</div>

	<div class="name">{character.First}<br />{character.Last}</div>
	<div class="job">{jobLine}</div>
	<div class="played" title={lastPlayedLine}>Last played: {lastPlayedLine}</div>
</button>

{#if confirmingDelete}
	<DeleteConfirmDialog
		characterName={`${character.First} ${character.Last}`}
		onConfirm={confirmDelete}
		onCancel={() => (confirmingDelete = false)}
	/>
{/if}

<style>
	.card {
		display: flex;
		flex-direction: column;
		align-items: center;
		width: 12vw;
		height: 24vh;
		flex-shrink: 0;
		background: var(--color-bg-panel);
		border: 1px solid color-mix(in srgb, var(--color-text) 8%, transparent);
		border-radius: var(--radius);
		color: inherit;
		cursor: pointer;
		font-family: inherit;
		padding: 1.4vh 1vw 1.6vh;
		transition:
			border-color 150ms ease,
			transform 150ms ease;
	}

	.card:hover {
		border-color: color-mix(in srgb, var(--color-primary) 40%, transparent);
		transform: translateY(-0.4vh);
	}

	.card.active {
		border-color: var(--color-primary);
		background: color-mix(in srgb, var(--color-bg-panel) 70%, var(--color-primary) 8%);
	}

	.top {
		width: 100%;
		display: flex;
		align-items: center;
		justify-content: space-between;
		color: var(--color-text-muted);
	}

	.sid {
		font-size: 1vmin;
		letter-spacing: 0.03em;
	}

	.avatar {
		margin-top: 2vh;
		width: 8vmin;
		height: 8vmin;
		border-radius: 50%;
		display: flex;
		align-items: center;
		justify-content: center;
		background: var(--color-bg);
		color: var(--color-text-muted);
	}

	.name {
		margin-top: 2vh;
		font-family: var(--font-heading);
		font-size: 1.5vmin;
		line-height: 1.3;
		color: var(--color-text);
		text-align: center;
	}

	.job {
		margin-top: 1vh;
		font-size: 1.05vmin;
		color: var(--color-primary-light);
		text-align: center;
	}

	.played {
		margin-top: auto;
		padding-top: 1.4vh;
		font-size: 0.9vmin;
		color: var(--color-text-muted);
		text-align: center;
	}
</style>
