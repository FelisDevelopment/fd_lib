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

			this.ui = value.ui
		},

		setLocale(locale: any) {
			this.ui = locale.ui
		},
	},
})
