<!-- character creation form, name/DOB/gender/origin/bio only, no appearance step in this flow -->
<script lang="ts">
	import { getCodeList } from 'country-list';
	import { Nui } from './nui';
	import { setScreen, showLoader } from './store.svelte';
	import { STATE_CHARACTERS } from './types';
	import Dropdown from './Dropdown.svelte';

	const genderOptions = [
		{ value: 0, label: 'Male' },
		{ value: 1, label: 'Female' },
	];

	const countries = Object.entries(getCodeList())
		.map(([value, label]) => ({ value, label }))
		.sort((a, b) => a.label.localeCompare(b.label));

	function eighteenYearsAgo(): string {
		const d = new Date();
		d.setFullYear(d.getFullYear() - 18);
		return d.toISOString().slice(0, 10);
	}

	let first = $state('');
	let last = $state('');
	let gender = $state(0);
	let dob = $state(eighteenYearsAgo());
	let origin = $state('');
	let bio = $state('');

	function stripSpaces(value: string): string {
		return value.replace(/\s/g, '');
	}

	function cancel() {
		setScreen(STATE_CHARACTERS);
	}

	function submit(e: SubmitEvent) {
		e.preventDefault();
		const originEntry = origin ? { label: countries.find((c) => c.value === origin)?.label ?? origin, value: origin } : null;
		Nui.createCharacter({
			first,
			last,
			gender,
			dob,
			lastPlayed: -1,
			origin: originEntry,
		});
		showLoader('Creating Character');
	}
</script>

<div class="screen">
	<form class="panel" onsubmit={submit}>
		<div class="title">Create Character</div>

		<div class="row">
			<label>
				First Name
				<input
					required
					value={first}
					oninput={(e) => (first = stripSpaces(e.currentTarget.value))}
				/>
			</label>
			<label>
				Last Name
				<input
					required
					value={last}
					oninput={(e) => (last = stripSpaces(e.currentTarget.value))}
				/>
			</label>
		</div>

		<div class="row">
			<label>
				Gender
				<Dropdown bind:value={gender} options={genderOptions} />
			</label>
			<label>
				Date of Birth
				<input type="date" required bind:value={dob} max={new Date().toISOString().slice(0, 10)} />
			</label>
		</div>

		<label class="full">
			Country of Origin
			<Dropdown bind:value={origin} options={countries} placeholder="—" searchable />
		</label>

		<label class="full">
			Character Biography
			<textarea required rows="4" bind:value={bio}></textarea>
		</label>

		<div class="actions">
			<button type="button" class="btn btn-ghost" onclick={cancel}>Cancel</button>
			<button type="submit" class="btn btn-primary">Create</button>
		</div>
	</form>
</div>

<style>
	.screen {
		position: relative;
		width: 100%;
		height: 100%;
	}

	.panel {
		position: absolute;
		inset: 0;
		margin: auto;
		width: 44vw;
		height: fit-content;
		background: var(--color-bg-panel);
		border-left: 0.2vw solid var(--color-primary);
		padding: 2.4vh 2vw;
		display: flex;
		flex-direction: column;
		gap: 1.6vh;
	}

	.title {
		font-family: var(--font-heading);
		font-size: 2vmin;
		color: var(--color-text);
	}

	.row {
		display: flex;
		gap: 1.2vw;
	}

	label {
		flex: 1;
		display: flex;
		flex-direction: column;
		gap: 0.5vh;
		font-size: 1.1vmin;
		color: var(--color-text-muted);
		letter-spacing: 0.02em;
	}

	label.full {
		flex: unset;
		width: 100%;
	}

	input,
	textarea {
		background: var(--color-bg);
		border: var(--border-subtle);
		border-radius: var(--radius);
		padding: 0.9vh 0.8vw;
		font-size: 1.2vmin;
		color: var(--color-text);
	}

	input:focus,
	textarea:focus {
		outline: none;
		border-color: var(--color-primary);
	}

	input[type='date'] {
		color-scheme: dark;
	}

	input[type='date']::-webkit-calendar-picker-indicator {
		filter: invert(1);
		cursor: pointer;
	}

	textarea {
		resize: vertical;
	}

	.actions {
		display: flex;
		justify-content: flex-end;
		gap: 0.8vw;
		margin-top: 0.6vh;
	}

	.btn {
		border: none;
		padding: 0.9vh 1.6vw;
		font-size: 1.2vmin;
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
</style>
