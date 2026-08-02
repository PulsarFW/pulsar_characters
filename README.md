<div align="center">

<img src="https://r2.fivemanage.com/GPYOH8Hq4GPyAY7czrgLe/pulsarbanner.png" alt="Pulsar Framework" width="100%" />

<br/>

# PULSAR-CHARACTERS

### Character select, creation, and spawn-point selection

<br/>

![Lua](https://img.shields.io/badge/Lua_5.4-2C2D72?style=flat-square&logo=lua&logoColor=white)
![FiveM](https://img.shields.io/badge/FiveM-F40552?style=flat-square)
![Svelte](https://img.shields.io/badge/Svelte_5-FF3E00?style=flat-square&logo=svelte&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?style=flat-square&logo=typescript&logoColor=white)
![Vite](https://img.shields.io/badge/Vite-646CFF?style=flat-square&logo=vite&logoColor=white)
![Bun](https://img.shields.io/badge/Bun-000000?style=flat-square&logo=bun&logoColor=white)

<br/>

<sub>Enjoy the framework? A coffee helps keep active development, hardening, and support going.</sub>

<a href="https://buymeacoffee.com/pulsarframework"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 50px !important;width: 180px !important;" /></a>

<br/>

[Overview](#overview) · [Theming](#theming) · [Dependencies](#dependencies)

</div>

---

## Overview

The screen shown after loading: character select, creation (name, DOB, gender, country of origin, biography), and spawn-point selection.

> [!NOTE]
> No ped/appearance customization step lives here — that always happens later in `pulsar_ped`.

---

## Theming

Edit `ui/src/theme.css` for colors and fonts, and `ui/src/config.ts` for brand name and logo, then rebuild:

```
cd ui
bun install
bun run build
```

Commit the rebuilt `ui/dist/` — that's what actually ships.

---

## Dependencies

- `pulsar_core` — framework core
- `pulsar_pwnzor` — anti-cheat check loaded alongside every resource

---

## License

This resource is free to use and modify under the [Pulsar Framework License](LICENSE.md). Redistribution is welcome as long as it stays free — selling this resource or any derivative of it requires written permission from the Pulsar Framework team.

---

<div align="center">

![Pulsar Framework](https://img.shields.io/badge/Pulsar-Framework-7c3aed?style=flat-square)
![Built for FiveM](https://img.shields.io/badge/Built_for-FiveM-F40552?style=flat-square)

</div>
