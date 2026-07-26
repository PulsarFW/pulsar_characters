<script lang="ts">
	let {
		characterName,
		onConfirm,
		onCancel,
	}: {
		characterName: string;
		onConfirm: () => void;
		onCancel: () => void;
	} = $props();
</script>

<div
	class="backdrop"
	onclick={onCancel}
	onkeydown={(e) => e.key === 'Escape' && onCancel()}
	role="button"
	tabindex="-1"
	aria-label="Close dialog"
>
	<div
		class="dialog"
		onclick={(e) => e.stopPropagation()}
		onkeydown={(e) => e.stopPropagation()}
		role="dialog"
		aria-modal="true"
		tabindex="-1"
	>
		<div class="title">Delete {characterName}?</div>
		<div class="body">
			This action is completely and entirely irreversible by anyone, including staff.
		</div>
		<div class="actions">
			<button class="btn btn-ghost" onclick={onCancel}>No</button>
			<button class="btn btn-danger" onclick={onConfirm}>Yes</button>
		</div>
	</div>
</div>

<style>
	.backdrop {
		position: fixed;
		inset: 0;
		background: rgba(0, 0, 0, 0.6);
		display: flex;
		align-items: center;
		justify-content: center;
		z-index: 100;
	}

	.dialog {
		width: 28vmin;
		background: var(--color-bg-panel);
		border-left: 0.2vw solid var(--color-error);
		padding: 2vh 1.6vw;
	}

	.title {
		font-family: var(--font-heading);
		font-size: 1.6vmin;
		color: var(--color-text);
	}

	.body {
		margin-top: 1vh;
		font-size: 1.15vmin;
		color: var(--color-text-muted);
		line-height: 1.5;
	}

	.actions {
		margin-top: 1.8vh;
		display: flex;
		justify-content: flex-end;
		gap: 0.8vw;
	}

	.btn {
		border: none;
		padding: 0.7vh 1.4vw;
		font-size: 1.1vmin;
		font-family: var(--font-body);
		letter-spacing: 0.02em;
		cursor: pointer;
		border-radius: var(--radius);
	}

	.btn-ghost {
		background: transparent;
		color: var(--color-text-muted);
	}

	.btn-ghost:hover {
		color: var(--color-text);
	}

	.btn-danger {
		background: var(--color-error-dark);
		color: var(--color-text);
	}

	.btn-danger:hover {
		background: var(--color-error);
	}
</style>
