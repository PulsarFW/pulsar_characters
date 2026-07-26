/*
	Pulsar Characters content config
	Server owners: edit brand text and the logo asset here. For colors/fonts, edit theme.css instead youve been warned
*/

import logo from './assets/logo_pulsar.png';

export interface CharactersConfig {
	brandName: string;
	logo: string;
}

export const config: CharactersConfig = {
	brandName: 'SOLYX Roleplay',
	logo,
};
