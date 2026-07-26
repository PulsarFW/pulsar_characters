<!-- press-to-continue gate, auth already happened before this UI became interactive -->
<script lang="ts">
	import { onMount } from 'svelte';
	import { config } from '../config';
	import { Nui } from './nui';
	import { showLoader } from './store.svelte';

	function login() {
		Nui.getData();
		showLoader('Loading Server Data');
	}

	onMount(() => {
		const onKey = (e: KeyboardEvent) => {
			if (e.key === 'Enter' || e.key === ' ') login();
		};
		const onClick = (e: MouseEvent) => {
			if (e.button === 0) login();
		};
		window.addEventListener('keydown', onKey);
		window.addEventListener('click', onClick);
		return () => {
			window.removeEventListener('keydown', onKey);
			window.removeEventListener('click', onClick);
		};
	});
</script>

<div class="splash">
	<img class="logo" src={config.logo} alt={config.brandName} />
	<div class="tip">Press <b>ENTER</b> / <b>SPACE</b> / <b>LEFT MOUSE</b> to select character</div>
</div>

<style>
	.splash {
		position: absolute;
		inset: 0;
		margin: auto;
		width: fit-content;
		height: fit-content;
		text-align: center;
	}

	.logo {
		width: 30vmin;
	}

	.tip {
		margin-top: 2.2vh;
		font-size: 1.3vmin;
		letter-spacing: 0.03em;
		color: var(--color-text-muted);
		animation: blink 1.6s ease-in-out infinite;
	}

	.tip b {
		color: var(--color-primary-light);
		font-weight: 600;
	}

	@keyframes blink {
		0%,
		100% {
			opacity: 1;
		}
		50% {
			opacity: 0.45;
		}
	}
</style>
