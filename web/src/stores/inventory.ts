import { defineStore } from 'pinia'
import { resource } from '../utils'

// Import necessary components
import { useAxios } from '@vueuse/integrations/useAxios'

export interface CoreItem {
	name: string
	label: string
	weight: number
	type: string
	image: string
	unique: boolean
	useable: boolean
	shouldClose: boolean
	description: string
	combinable?: any
}

export interface Item {
	type: string
	name: string
	slot: number
	weight: number
	amount: number
	info?: { [key: string]: any }
	price?: number
}

export interface Items {
	[key: string]: CoreItem
}

export interface Inventory {
	label?: string
	maxWeight: number
	slots: number
	items: Map<number, Item>
	type?: 'inventory' | 'crafting' | 'shop'
}

export const useInventory = defineStore({
	id: 'inventory',
	state: () => ({
		cash: 0,
		bank: 0,
		credits: 0,
		player: {} as Inventory,
		secondary: {} as Inventory,
		items: {
			cherry: {
				name: 'cherry',
				label: 'Cherry',
				weight: 500,
				type: 'item',
				image: 'someimg.png',
				unique: true,
				useable: false,
				shouldClose: true,
				description: 'Very tasty cherry',
			},
		} as Items,
	}),
	getters: {
		getPlayerInventory: (state) => state.player,
		getSecondaryInventory: (state) => state.secondary,
	},
	actions: {
		populate(inv: any, invToPopulate: any) {
			let type = (inv.type ?? 'player') as 'player' | 'secondary'

			this[type].slots = invToPopulate.slots ?? 0
			this[type].maxWeight = invToPopulate.maxWeight ?? 0
			this[type].label = invToPopulate.label
			this[type].items = new Map()

			for (let i = 1; i <= this[type].slots; i++) {
				const slotItem = invToPopulate.items.find((item: any) => {
					return i === item.slot
				}) ?? {
					slot: i,
				}

				this[type].items.set(i, slotItem)
			}
		},
	},
})

export const useAmount = defineStore({
	id: 'amount',
	state: () => ({
		amount: 0,
	}),
	getters: {
		// doubleCount: (state) => state.counter * 2,
	},
	actions: {
		handleWheel(delta: any) {
			if (delta < 0) {
				this.amount++

				if (this.amount > 9999) {
					this.amount = 9999
				}

				return
			}

			this.amount--

			if (this.amount < 0) {
				this.amount = 0
			}
		},
	},
})
