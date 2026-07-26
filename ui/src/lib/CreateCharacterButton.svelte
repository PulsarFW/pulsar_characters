<script lang="ts">
	import Icon from './Icon.svelte';
	import { setScreen } from './store.svelte';
	import { STATE_CREATE } from './types';
</script>

<button class="card" type="button" onclick={() => setScreen(STATE_CREATE)}>
	<Icon name="plus-circle" size="3.2vmin" />
	<span class="label">Create Character</span>
</button>

<style>
	.card {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		gap: 1.4vh;
		width: 12vw;
		height: 24vh;
		flex-shrink: 0;
		background: rgba(14, 13, 19, 0.5);
		border: 1px dashed rgba(139, 92, 246, 0.45);
		border-radius: var(--radius);
		color: var(--color-primary-light);
		cursor: pointer;
		transition:
			border-color 150ms ease,
			background 150ms ease;
	}

	.card:hover {
		border-color: var(--color-primary);
		background: rgba(139, 92, 246, 0.06);
	}

	.label {
		font-size: 1.1vmin;
		letter-spacing: 0.03em;
		color: var(--color-text-muted);
	}
</style>
