import { defineStore } from 'pinia'
import { resource } from '../utils'

// Import necessary components
import { useAxios } from '@vueuse/integrations/useAxios'

export const useLocale = defineStore({
	id: 'language',
	state: () => ({
		ui: <{ [key: string]: string }>{},
	}),
	getters: {
		t: (state) => (key: string) => state.ui[key],
	},
	actions: {
		async initLocale() {
			const {
				data: { value },
			} = await useAxios(`https://${resource()}/getLocale`, {
				method: 'POST',
				data: {},
			})

			if (!value) return

			this.ui = value.ui
		},

		setLocale(locale: any) {
			this.ui = locale.ui
		},

		overrideLocaleKeys(event: { [key: string]: string }) {
			if (Object.keys(event.locale).length <= 0) return

			for (const [key, value] of Object.entries(event.locale)) {
				this.ui[key] = value
			}
		},
	},
})
