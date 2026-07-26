<!-- native <select> chrome can't be restyled in a CEF NUI, so this is a self-contained listbox with optional search -->
<script lang="ts">
	interface Option {
		value: string | number;
		label: string;
	}

	let {
		value = $bindable(),
		options,
		placeholder = 'Select...',
		searchable = false,
	}: {
		value: string | number;
		options: Option[];
		placeholder?: string;
		searchable?: boolean;
	} = $props();

	let open = $state(false);
	let query = $state('');
	let root: HTMLDivElement;

	const selected = $derived(options.find((o) => o.value === value));
	const filtered = $derived(
		searchable && query ? options.filter((o) => o.label.toLowerCase().includes(query.toLowerCase())) : options,
	);

	function toggle() {
		open = !open;
		query = '';
	}

	function pick(e: MouseEvent, opt: Option) {
		e.stopPropagation();
		value = opt.value;
		open = false;
		query = '';
		(document.activeElement as HTMLElement | null)?.blur();
	}

	function onWindowClick(e: MouseEvent) {
		if (open && root && !root.contains(e.target as Node)) open = false;
	}

	function onWindowKeydown(e: KeyboardEvent) {
		if (open && e.key === 'Escape') open = false;
	}

	function focusOnMount(node: HTMLInputElement) {
		node.focus();
	}
</script>

<svelte:window onclick={onWindowClick} onkeydown={onWindowKeydown} />

<div class="dropdown" bind:this={root}>
	<button type="button" class="control" class:open onclick={toggle}>
		<span class:placeholder={!selected}>{selected ? selected.label : placeholder}</span>
		<svg class="chevron" class:open viewBox="0 0 12 8" width="10" height="7">
			<path d="M1 1l5 5 5-5" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" />
		</svg>
	</button>

	{#if open}
		<div class="panel">
			{#if searchable}
				<input
					class="search"
					placeholder="Search..."
					bind:value={query}
					use:focusOnMount
					autocomplete="off"
					autocorrect="off"
					autocapitalize="off"
					spellcheck="false"
				/>
			{/if}
			<div class="options">
				{#each filtered as opt (opt.value)}
					<button type="button" class="option" class:active={opt.value === value} onclick={(e) => pick(e, opt)}>
						{opt.label}
					</button>
				{:else}
					<div class="empty">No matches</div>
				{/each}
			</div>
		</div>
	{/if}
</div>

<style>
	.dropdown {
		position: relative;
		width: 100%;
	}

	.control {
		width: 100%;
		display: flex;
		align-items: center;
		justify-content: space-between;
		background: var(--color-bg);
		border: var(--border-subtle);
		border-radius: var(--radius);
		padding: 0.9vh 0.8vw;
		font-size: 1.2vmin;
		color: var(--color-text);
		cursor: pointer;
		text-align: left;
	}

	.control.open {
		border-color: var(--color-primary);
	}

	.placeholder {
		color: var(--color-text-muted);
	}

	.chevron {
		flex-shrink: 0;
		margin-left: 0.6vw;
		color: var(--color-text-muted);
		transition: transform 150ms ease;
	}

	.chevron.open {
		transform: rotate(180deg);
	}

	.panel {
		position: absolute;
		top: calc(100% + 0.5vh);
		left: 0;
		right: 0;
		z-index: 20;
		background: var(--color-bg-panel-alt);
		border: var(--border-subtle);
		border-radius: var(--radius);
		box-shadow: 0 0.8vh 2vh rgba(0, 0, 0, 0.5);
		overflow: hidden;
	}

	.search {
		width: 100%;
		background: var(--color-bg);
		border: none;
		border-bottom: var(--border-subtle);
		padding: 0.8vh 0.8vw;
		font-size: 1.1vmin;
		color: var(--color-text);
	}

	.search:focus {
		outline: none;
	}

	.options {
		max-height: 22vh;
		overflow-y: auto;
	}

	.option {
		display: block;
		width: 100%;
		padding: 0.7vh 0.8vw;
		background: transparent;
		border: none;
		color: var(--color-text);
		font-size: 1.15vmin;
		text-align: left;
		cursor: pointer;
	}

	.option:hover {
		background: color-mix(in srgb, var(--color-primary) 12%, transparent);
	}

	.option.active {
		color: var(--color-primary-light);
	}

	.empty {
		padding: 1vh 0.8vw;
		font-size: 1.1vmin;
		color: var(--color-text-muted);
	}
</style>
