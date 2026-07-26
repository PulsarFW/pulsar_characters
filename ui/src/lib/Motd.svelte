<!-- MOTD banner, self-contained, drop <Motd /> in a screen and it decides its own visibility -->
<script lang="ts">
	import Icon from './Icon.svelte';
	import { store } from './store.svelte';

	const visible = $derived(!!store.characters.motd);
</script>

{#if visible}
	<div class="motd">
		<Icon name="bullhorn" size="1.1vmin" />
		<span class="tag">MOTD</span>
		<span class="divider"></span>
		<span class="message">{store.characters.motd}</span>
	</div>
{/if}

<style>
	.motd {
		position: absolute;
		top: 2.4vh;
		left: 50%;
		transform: translateX(-50%);
		max-width: 56vw;
		display: flex;
		align-items: center;
		gap: 0.6vw;
		background: var(--color-bg-panel);
		border: var(--border-subtle);
		border-radius: 999px;
		padding: 0.8vh 1.4vw;
		color: var(--color-primary);
		pointer-events: none;
		z-index: 5;
	}

	.tag {
		font-size: 1vmin;
		font-weight: 600;
		letter-spacing: 0.06em;
		color: var(--color-primary-light);
		flex-shrink: 0;
	}

	.divider {
		width: 1px;
		height: 1.4vh;
		background: color-mix(in srgb, var(--color-text) 15%, transparent);
		flex-shrink: 0;
	}

	.message {
		font-size: 1.1vmin;
		color: var(--color-text-muted);
	}
</style>
