// dev-only simulated Lua backend so `bun run dev` renders the full Splash -> Characters -> Create/Spawn flow

import { applyMessage } from './store.svelte';
import type { CharacterRecord, SpawnPoint } from './types';

const MOCK_CHARACTERS: CharacterRecord[] = [
	{
		ID: 1,
		SID: 1,
		First: 'John',
		Last: 'Doe',
		DOB: '1990-05-14',
		Gender: 0,
		LastPlayed: Date.now() - 1000 * 60 * 60 * 24 * 3,
		Jobs: [{ Id: 'police', Name: 'Police', Workplace: { Id: 'lspd', Name: 'LSPD' }, Grade: { Id: 'officer', Name: 'Officer' } }],
	},
	{
		ID: 2,
		SID: 2,
		First: 'Jane',
		Last: 'Smith',
		DOB: '1995-11-02',
		Gender: 1,
		LastPlayed: -1,
		Jobs: [],
	},
];

const MOCK_SPAWNS: SpawnPoint[] = [
	{ id: 1, label: 'Legion Square', location: { x: 215.0, y: -810.0, z: 30.7, h: 0 }, icon: 'location-dot' },
	{ id: 2, label: 'Sandy Shores', location: { x: 1961.0, y: 3740.0, z: 32.3, h: 0 }, icon: 'location-dot' },
	{ id: 3, label: 'Last Location', location: { x: 0, y: 0, z: 0, h: 0 }, icon: 'clock-rotate-left' },
];

let nextCharacterId = 100;

export function mockNuiCall(event: string, data: unknown) {
	switch (event) {
		case 'GetData':
			setTimeout(() => applyMessage({ type: 'LOADING_SHOW', data: { message: 'Getting Character Data' } }), 200);
			setTimeout(() => {
				applyMessage({
					type: 'SET_DATA',
					data: {
						characters: MOCK_CHARACTERS,
						changelog: null,
						motd: 'Dev preview server — this banner is mock MOTD data.',
						characterLimit: 3,
					},
				});
				applyMessage({ type: 'SET_STATE', data: { state: 'STATE_CHARACTERS' } });
				applyMessage({ type: 'LOADING_HIDE' });
			}, 700);
			break;

		case 'CreateCharacter': {
			const payload = data as Record<string, unknown>;
			setTimeout(() => {
				const character: CharacterRecord = {
					ID: nextCharacterId,
					SID: nextCharacterId++,
					First: (payload.first as string) ?? 'New',
					Last: (payload.last as string) ?? 'Character',
					DOB: (payload.dob as string) ?? '2000-01-01',
					Gender: (payload.gender as number) ?? 0,
					LastPlayed: -1,
					Jobs: [],
				};
				applyMessage({ type: 'CREATE_CHARACTER', data: { character } });
				applyMessage({ type: 'SET_STATE', data: { state: 'STATE_CHARACTERS' } });
				applyMessage({ type: 'LOADING_HIDE' });
			}, 500);
			break;
		}

		case 'DeleteCharacter': {
			const payload = data as { id: number };
			setTimeout(() => {
				applyMessage({ type: 'DELETE_CHARACTER', data: { id: payload.id } });
				applyMessage({ type: 'LOADING_HIDE' });
			}, 400);
			break;
		}

		case 'SelectCharacter':
			setTimeout(() => {
				applyMessage({ type: 'SET_SPAWNS', data: { spawns: MOCK_SPAWNS } });
				applyMessage({ type: 'SET_STATE', data: { state: 'STATE_SPAWN' } });
				applyMessage({ type: 'LOADING_HIDE' });
			}, 400);
			break;

		case 'PlayCharacter':
			// nothing meaningful to preview past this point in a browser, just clear the loader
			setTimeout(() => applyMessage({ type: 'LOADING_HIDE' }), 600);
			break;

		case 'SelectSpawn':
			// no-op here too, see nui.ts
			break;

		default:
			break;
	}
}

export function startMockCharacters(): void {
	applyMessage({ type: 'APP_SHOW' });
}
