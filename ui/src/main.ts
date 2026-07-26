import { mount } from 'svelte';
import App from './App.svelte';
import './theme.css';

if (import.meta.env.DEV) {
	// Simulates the Lua-driven message contract so `bun run dev` renders a live,
	// navigable app in a regular browser. Never bundled into production
	import('./lib/mock').then(({ startMockCharacters }) => startMockCharacters());
}

const target = document.getElementById('app');
if (!target) {
	throw new Error('#app mount node not found');
}

const app = mount(App, { target });

export default app;
