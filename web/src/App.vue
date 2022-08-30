<script setup lang="ts">
import { onMounted, inject } from 'vue'

// Basic UI Stuff
import InputDialog from './components/InputDialog.vue'
import Clipboard from './components/Clipboard.vue'
import Modal from './components/Modal.vue'
import SimpleAction from './components/SimpleAction.vue'
import Menu from './components/Menu.vue'
import ProgressBar from './components/ProgressBar.vue'
import ProgressCircle from './components/ProgressCircle.vue'
import KbdAction from './components/KbdAction.vue'
import Instruction from './components/Instruction.vue'
import Incidators from './components/Incidators.vue'
import Compass from './components/Compass.vue'
import VehicleIndicators from './components/VehicleIndicators.vue'
import Context from './components/Context.vue'

// Minigames
import CombinationMinigame from './components/CombinationMinigame.vue'
import MemoryMinigame from './components/MemoryMinigame.vue'
import PasswordMinigame from './components/PasswordMinigame.vue'
import SquareMinigame from './components/SquareMinigame.vue'
import KeysMinigame from './components/KeysMinigame.vue'
import VAR from './components/VAR.vue'
import PathMinigame from './components/PathMinigame.vue'

import { useApp } from './stores/app'
import { useLocale } from './stores/locale'
import { useAxios } from '@vueuse/integrations/useAxios'
import { getResource } from '@/utils'

const app = useApp()
const locale = useLocale()

const emitter: any = inject('emitter')

const events: { [key: string]: Function } = {
	setLocale: (strings: string) => {
		locale.setLocale(strings)
	},
	uiShown: (event: any) => {
		if (event.shown !== undefined) {
			app.shown = event.shown
		}

		if (event.partiallyShown !== undefined) {
			app.partiallyShown = event.partiallyShown
		}
	},
	toggleIndicators: (event: any) => {
		app.hudForcefullyHidden = event.hide
	},
	updateTheme: (event: any) => {
		app.updateTheme(event.theme)
	},
	isMinimapShown: (event: any) => {
		app.isMinimapShown = event.isShown
	},
}

onMounted(() => {
	window.addEventListener('message', handleMessage)

	locale.initLocale()
	app.updateSafezoneSettings()
	app.initializeTheme()
})

function handleMessage(event: any) {
	if (event.data.isOpen) {
		for (const item in app.apps) {
			//@ts-ignore
			if (app.apps[item]) {
				useAxios(`https://${getResource()}/openCheckCallback`, {
					method: 'POST',
					data: {
						app: item,
						isOpen: true,
					},
				})

				return
			}
		}

		useAxios(`https://${getResource()}/openCheckCallback`, {
			method: 'POST',
			data: {
				isOpen: false,
			},
		})

		return
	}

	if (event.data.event && events[event.data.event]) {
		events[event.data.event](event.data.data)

		return
	}

	const { app: toOpen, show, data }: { app: string; toOpen: string; show: boolean; data: any } = event.data

	if (!toOpen) return

	if (!(toOpen in app.apps)) return

	let type = show ? 'open' : 'close'

	if (typeof show === 'string') {
		type = show
	}

	emitter.emit(`${toOpen}:${type}`, data ?? {})
}
</script>

<template>
	<main class="absolute inset-0 grid place-items-center bg-transparent" :style="[app.getSafezoneStyles]" v-show="app.shown">
		<Clipboard />
		<Modal />
		<SimpleAction />
		<Menu />
		<ProgressBar />
		<ProgressCircle />
		<KbdAction />
		<Instruction />
		<InputDialog />
		<CombinationMinigame />
		<MemoryMinigame />
		<PasswordMinigame />
		<SquareMinigame />
		<KeysMinigame />
		<VAR />
		<PathMinigame />
		<Incidators />
		<Compass />
		<VehicleIndicators />
		<Context />
	</main>
</template>
