// shared types for the Lua <-> NUI contract, see README.md for the full message table

export const STATE_SPLASH = 'STATE_SPLASH';
export const STATE_CHARACTERS = 'STATE_CHARACTERS';
export const STATE_CREATE = 'STATE_CREATE';
export const STATE_SPAWN = 'STATE_SPAWN';

export type ScreenState =
	| typeof STATE_SPLASH
	| typeof STATE_CHARACTERS
	| typeof STATE_CREATE
	| typeof STATE_SPAWN;

export interface Job {
	Id: string;
	Name: string;
	Workplace?: { Id: string; Name: string };
	Grade: { Id: string; Name: string };
}

// the full DB document has more fields than this UI touches, extras fall through the index signature
export interface CharacterRecord {
	ID: number;
	First: string;
	Last: string;
	Phone?: string;
	DOB: string;
	Gender: number;
	LastPlayed: number;
	Jobs?: Job[];
	SID: number;
	New?: boolean;
	[key: string]: unknown;
}

export interface SpawnPoint {
	id: string | number;
	label: string;
	location: { x: number; y: number; z: number; h: number };
	icon?: string;
	event?: string;
}

export interface CreateCharacterPayload {
	first: string;
	last: string;
	gender: number;
	dob: string;
	lastPlayed: -1;
	origin: { label: string; value: string } | null;
}
