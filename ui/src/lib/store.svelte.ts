// single reactive store, client/nui.lua, client/spawn.lua and client/component.lua drive it via SendNUIMessage

import { STATE_SPLASH, type CharacterRecord, type ScreenState, type SpawnPoint } from './types';

interface AppState {
	hidden: boolean;
	state: ScreenState;
}

interface LoaderState {
	loading: boolean;
	message: string | null;
}

interface CharactersState {
	characters: CharacterRecord[];
	changelog: unknown | null;
	motd: string | null;
	selected: CharacterRecord | null;
	characterLimit: number;
}

interface SpawnState {
	spawns: SpawnPoint[];
	selected: SpawnPoint | null;
}

function initialAppState(): AppState {
	return { hidden: true, state: STATE_SPLASH };
}
function initialLoaderState(): LoaderState {
	return { loading: false, message: null };
}
function initialCharactersState(): CharactersState {
	return { characters: [], changelog: null, motd: null, selected: null, characterLimit: 3 };
}
function initialSpawnState(): SpawnState {
	return { spawns: [], selected: null };
}

export const store = $state({
	app: initialAppState(),
	loader: initialLoaderState(),
	characters: initialCharactersState(),
	spawn: initialSpawnState(),
});

// --- local (non-Lua-driven) UI actions, purely client-side navigation/selection state ---

export function setScreen(state: ScreenState) {
	store.app.state = state;
}

export function selectCharacter(character: CharacterRecord) {
	store.characters.selected = character;
}

export function deselectCharacter() {
	store.characters.selected = null;
}

export function selectSpawn(spawn: SpawnPoint) {
	store.spawn.selected = spawn;
}

export function deselectSpawn() {
	store.spawn.selected = null;
}

export function showLoader(message: string) {
	store.loader.loading = true;
	store.loader.message = message;
}

// optimistic client-side update fired right before the actual spawn call resolves
export function markSelectedPlayedNow() {
	if (!store.characters.selected) return;
	const id = store.characters.selected.ID;
	for (const c of store.characters.characters) {
		if (c.ID === id) c.LastPlayed = Date.now();
	}
}

// --- Inbound Lua -> UI message handling ---

interface InboundMessage {
	type?: string;
	data?: Record<string, unknown>;
}

export function applyMessage(msg: InboundMessage) {
	const data = msg.data ?? {};
	switch (msg.type) {
		case 'APP_SHOW':
			store.app.hidden = false;
			break;
		case 'APP_HIDE':
			store.app.hidden = true;
			break;
		case 'APP_RESET':
			Object.assign(store.app, initialAppState(), { hidden: false });
			Object.assign(store.loader, initialLoaderState());
			Object.assign(store.characters, initialCharactersState());
			Object.assign(store.spawn, initialSpawnState());
			break;
		case 'LOADING_SHOW':
			store.loader.loading = true;
			store.loader.message = (data.message as string) ?? null;
			break;
		case 'LOADING_HIDE':
			store.loader.loading = false;
			store.loader.message = null;
			break;
		case 'SET_DATA':
			store.characters.characters = (data.characters as CharacterRecord[]) ?? [];
			store.characters.changelog = data.changelog ?? null;
			store.characters.motd = (data.motd as string) ?? null;
			store.characters.characterLimit = (data.characterLimit as number) ?? 3;
			store.characters.selected = null;
			break;
		case 'SET_STATE':
			store.app.state = data.state as ScreenState;
			break;
		case 'CREATE_CHARACTER':
			store.characters.characters.push(data.character as CharacterRecord);
			break;
		case 'DELETE_CHARACTER':
			store.characters.characters = store.characters.characters.filter((c) => c.ID != data.id);
			break;
		case 'SET_SPAWNS':
			store.spawn.spawns = (data.spawns as SpawnPoint[]) ?? [];
			break;
		default:
			break;
	}
}

// rejects untrusted (page-script-forged) events via event.isTrusted
export function attachMessageListener(): () => void {
	const handler = (event: MessageEvent<InboundMessage>) => {
		if (!event.isTrusted) return;
		if (event.data?.type) applyMessage(event.data);
	};
	window.addEventListener('message', handler);
	return () => window.removeEventListener('message', handler);
}
