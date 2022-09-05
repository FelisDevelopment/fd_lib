import { defineStore } from 'pinia'
import { resource } from '../utils'

// Import necessary components
import { useAxios } from '@vueuse/integrations/useAxios'

export const useRadio = defineStore({
	id: 'radio',
	state: () => ({
		change: {
			sign: '',
			name: '',
		},
		current: 0 as number | boolean,
		input: 1 as number,
		volume: 50 as number,
		tabsList: ['connection', 'change', 'list'] as string[],
		currentTab: 'connection',
		radioThemes: {
			default: `./radio/default.svg`,
			blue: `./radio/radio_blue.svg`,
			green: `./radio/radio_green.svg`,
			red: `./radio/radio_red.svg`,
			yellow: `./radio/radio_yellow.svg`,
		} as { [key: string]: string },
		theme: 'default' as string,
		radioList: {} as { [key: string]: { [key: string]: string } },
		isRadioWithList: false,
		ranges: {
			min: 1,
			max: 999,
		},
		urls: {} as { [key: string]: string },
	}),
	getters: {
		getThemeFrame: (state) => {
			return state.radioThemes[state.theme] ?? state.radioThemes['default']
		},
	},
	actions: {
		goBack() {
			this.currentTab = 'connection'
		},
		setTab(tab: string) {
			if (this.tabsList.includes(this.currentTab)) {
				if (tab === 'list') {
					this.fetchList()
				} else {
					this.radioList = {}
				}

				if (this.urls.radioChangeEnabled) {
					if (tab === 'change') {
						useAxios(this.urls.radioChangeEnabled, {
							method: 'POST',
							data: {
								enabled: true,
							},
						})
					} else {
						useAxios(this.urls.radioChangeEnabled, {
							method: 'POST',
							data: {
								enabled: false,
							},
						})
					}
				}

				return (this.currentTab = tab)
			}

			return (this.currentTab = 'connection')
		},
		updateRadio(isMinus?: boolean) {
			if (isMinus) return this.input--

			return this.input++
		},
		updateVolume(isMinus?: boolean) {
			useAxios(isMinus ? this.urls.volumeDown : this.urls.volumeUp, {
				method: 'POST',
				data: false,
			})
		},
		joinRadio() {
			useAxios(this.urls.join, {
				method: 'POST',
				data: {
					radio: this.input,
				},
			})
		},
		leaveRadio() {
			useAxios(this.urls.leave, {
				method: 'POST',
				data: false,
			})
		},
		async fetchList() {
			const {
				data: { value },
			} = await useAxios(this.urls.fetchList, {
				method: 'POST',
				data: {
					channel: this.current,
				},
			})

			this.radioList = value
		},

		updateName() {
			useAxios(this.urls.updateName, {
				method: 'POST',
				data: {
					sign: this.change.sign,
					name: this.change.name,
				},
			})
		},
	},
})
