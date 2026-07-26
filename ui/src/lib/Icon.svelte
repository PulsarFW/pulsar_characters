<!-- to add a new icon name, import it from @fortawesome/free-solid-svg-icons and add one line to ICONS below -->
<script lang="ts">
	import {
		faLocationDot,
		faPlusCircle,
		faHouse,
		faBuilding,
		faHospital,
		faHandcuffs,
		faClockRotateLeft,
		faCity,
		faPlane,
		faCar,
		faUser,
		faMars,
		faVenus,
		faBullhorn,
		faMapPin,
		type IconDefinition,
	} from '@fortawesome/free-solid-svg-icons';

	const ICONS: Record<string, IconDefinition> = {
		'location-dot': faLocationDot,
		'plus-circle': faPlusCircle,
		house: faHouse,
		building: faBuilding,
		hospital: faHospital,
		handcuffs: faHandcuffs,
		'clock-rotate-left': faClockRotateLeft,
		city: faCity,
		plane: faPlane,
		car: faCar,
		user: faUser,
		mars: faMars,
		venus: faVenus,
		bullhorn: faBullhorn,
		'map-pin': faMapPin,
	};

	let { name, size = '1em' }: { name: string; size?: string } = $props();

	const icon = $derived(ICONS[name] ?? faLocationDot);
	const path = $derived(icon.icon[4] as string);
	const viewBox = $derived(`0 0 ${icon.icon[0]} ${icon.icon[1]}`);
</script>

<svg {viewBox} width={size} height={size} fill="currentColor" aria-hidden="true">
	<path d={path} />
</svg>
