<!-- Static help bar for the Characters screen. Purely informational -->
<script lang="ts">
</script>

<div class="help">HELP &nbsp;|&nbsp; <b>Double Click</b> to play as character. <b>Right Click</b> to delete character.</div>

<style>
	.help {
		position: absolute;
		bottom: 1.6vh;
		left: 50%;
		transform: translateX(-50%);
		padding: 0.6vh 1.4vw;
		font-size: 1.1vmin;
		letter-spacing: 0.02em;
		color: var(--color-text-muted);
		background: rgba(14, 13, 19, 0.92);
		border: 1px solid rgba(232, 232, 236, 0.08);
		border-radius: var(--radius);
		pointer-events: none;
		z-index: 5;
	}

	.help b {
		color: var(--color-text);
		font-weight: 600;
	}
</style>
