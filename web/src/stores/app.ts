import { defineStore } from 'pinia'

import { resource } from '../utils'
import { useAxios } from '@vueuse/integrations/useAxios'

export const useApp = defineStore({
	id: 'app',
	state: () => ({
		shown: false,
		partiallyShown: false,
		theme: 'light',
		apps: {
			input: false,
			clipboard: false,
			modal: false,
			simpleAction: false,
			menu: false,
			progressBar: false,
			progressCircle: false,
			kbdAction: false,
			instruction: false,
			combinationMinigame: false,
			memoryMinigame: false,
			passwordMinigame: false,
			squareMinigame: false,
			keysMinigame: false,
			var: false,
			pathMinigame: false,
			indicators: false,
			compass: false,
			vehicleIndicator: false,
			context: false,
		},
		hudForcefullyHidden: false,
		safezone: {
			x: 0,
			y: 0,
		},
		minimap: {
			left: 0,
			width: 0,
			height: 0,
			top: 0,
		} as { [key: string]: any },
		isMinimapShown: false,
	}),
	getters: {
		getSafezoneStyles: (state) => `right: ${state.safezone.x}px; left: ${state.safezone.x}px; top: ${state.safezone.y}px; bottom: ${state.safezone.y}px;`,
		getRawSafezone: (state) => state.safezone,
		getLeftPosition: (state) => `left: ${state.minimap.left}px; top: ${parseInt(state.minimap.bottom) + 2}px;`,
		getRawLeftPosition: (state) => state.minimap.left,
		getRawMinimapPosition: (state) => state.minimap,
	},
	actions: {
		updateTheme(theme: string) {
			this.theme = theme

			document.documentElement.setAttribute('data-theme', this.theme)
		},

		async updateSafezoneSettings() {
			const {
				data: { value },
			} = await useAxios(`https://${resource()}/getSafezoneSize`, {
				method: 'POST',
				data: {},
			})

			this.safezone.x = value.x
			this.safezone.y = value.y
			this.minimap = value.minimap

			setTimeout(() => {
				this.updateSafezoneSettings()
			}, 2000)
		},

		async initializeTheme() {
			const {
				data: { value },
			} = await useAxios(`https://${resource()}/initializeTheme`, {
				method: 'POST',
				data: {},
			})

			this.updateTheme(value)
		},
	},
})
