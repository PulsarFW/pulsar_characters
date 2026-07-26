<!-- full-screen replacement while store.loader.loading is true, not an overlay, App.svelte swaps it in for the current screen -->
<script lang="ts">
	import { config } from '../config';
	import { store } from './store.svelte';
</script>

<div class="loader">
	<img class="logo" src={config.logo} alt={config.brandName} />
	<div class="message">{store.loader.message}</div>
	<div class="bar-track">
		<div class="bar-fill"></div>
	</div>
</div>

<style>
	.loader {
		position: absolute;
		inset: 0;
		margin: auto;
		width: fit-content;
		height: fit-content;
		max-width: 60vw;
		text-align: center;
	}

	.logo {
		width: 22vmin;
	}

	.message {
		margin-top: 2vh;
		font-family: var(--font-heading);
		font-size: 1.8vmin;
		color: var(--color-metal);
	}

	.bar-track {
		position: relative;
		margin-top: 1.6vh;
		width: 26vmin;
		height: 0.6vh;
		background: var(--color-bg-panel);
		overflow: hidden;
	}

	.bar-fill {
		position: absolute;
		top: 0;
		bottom: 0;
		width: 40%;
		background: var(--color-primary);
		animation: indeterminate 1.3s ease-in-out infinite;
	}

	@keyframes indeterminate {
		0% {
			left: -40%;
		}
		100% {
			left: 100%;
		}
	}
</style>
