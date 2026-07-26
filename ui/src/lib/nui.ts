// outbound UI -> Lua transport, fire-and-forget, real work comes back via SendNUIMessage pushes in store.svelte.ts

import type { CharacterRecord, CreateCharacterPayload, SpawnPoint } from './types';

const RESOURCE_NAME = 'pulsar_characters';

async function send(event: string, data: unknown = {}): Promise<void> {
	if (import.meta.env.DEV) {
		const { mockNuiCall } = await import('./mock');
		mockNuiCall(event, data);
		return;
	}
	try {
		await fetch(`https://${RESOURCE_NAME}/${event}`, {
			method: 'post',
			headers: { 'Content-Type': 'application/json; charset=UTF-8' },
			body: JSON.stringify(data),
		});
	} catch {
		// expected to fail outside the actual NUI browser
	}
}

export const Nui = {
	getData: () => send('GetData'),
	createCharacter: (data: CreateCharacterPayload) => send('CreateCharacter', data),
	deleteCharacter: (id: number) => send('DeleteCharacter', { id }),
	selectCharacter: (id: number) => send('SelectCharacter', { id }),
	playCharacter: (spawn: SpawnPoint, character: CharacterRecord) => send('PlayCharacter', { spawn, character }),
	// no matching RegisterNUICallback on the Lua side, spawn selection is client-side only
	selectSpawn: (spawn: SpawnPoint) => send('SelectSpawn', { spawn }),
};
