import { useAxios } from '@vueuse/integrations/useAxios'
import { resource, waitFor } from '@/utils'
import { useApp } from '@/stores/app'

interface MenuItemInferface {
	visible: boolean
	component: string
	title: string
	description?: string
	menu?: string
	options?: { [key: string]: any }
	onChange?: any
	bind: () => {
		[key: string]: any
	}
}

interface MenuSelectionInterface extends MenuItemInferface {
	selected: number
	values: string[]

	onItemChange: (index: number, old: number, currentIndex: number) => void
}

let lastMenus: string[] = []

const setLastMenus = (menu: string[]) => {
	lastMenus = menu
}

class Menu {
	constructor(
		public id: string,
		public title: string,
		public items: (MenuItemInferface | MenuSelectionInterface)[],
		public description?: string,
		public onItemChange?: (index: string) => void,
		public limit: number = 7,
		public index: number = 0
	) {
		this.initVisibleItems()
	}

	private async initVisibleItems() {
		let limit = this.limit > this.items.length ? this.items.length : this.limit

		if (this.items.length > limit) {
			for (let i = 0; i < this.items.length; i++) {
				this.items[i].visible = i < limit
			}
		}
	}

	changeIndex(index: number) {
		this.index = index
	}

	updateVisibleItems(oldValue: number) {
		if (this.index > this.items.length - 1) {
			for (let i: number = 0; i < this.items.length; i++) {
				this.items[i].visible = i < this.limit
			}

			this.index = 0

			return
		}

		if (this.index < 0) {
			for (let i = 0; i < this.items.length; i++) {
				this.items[i].visible = this.items.length - i <= this.limit
			}

			this.index = this.items.length - 1

			return
		}

		if (this.index > this.limit - 1) {
			this.items[this.index - this.limit].visible = false
		} else if (this.items.length - this.index > this.limit) {
			this.items[this.index + this.limit].visible = false
		}

		if (this.index < oldValue && !this.items[this.index].visible) {
			this.items[oldValue + this.limit - 1].visible = false
		}

		this.items[this.index].visible = true

		if (this.index !== oldValue && this.onItemChange) {
			this.activeItemChanged(oldValue)
		}
	}

	async findItem(search: string) {
		if (search) {
			const index = this.items.findIndex((item) => {
				return item.title.toLowerCase().includes(search.toLowerCase()) || item.description?.toLowerCase().includes(search.toLowerCase())
			})

			if (index !== -1) {
				// item exists, improsive user scrolling for correct display and rendering, whole menu will need refactor
				// TODO: refactor

				if (index > this.index) {
					while (index !== this.index) {
						this.index++
						await waitFor(5)
					}
				}

				if (index < this.index) {
					while (index !== this.index) {
						this.index--
						await waitFor(5)
					}
				}
			}
		}
	}

	currentItem() {
		return this.items[this.index]
	}

	nextSelectionItem() {
		let item = this.currentItem() as MenuSelectionInterface
		const old = item.selected

		if (!Array.isArray(item.values)) return

		item.selected++

		if (item.selected > item.values.length - 1) item.selected = 0

		if (item.options?.onChange) item.onItemChange(item.selected, old, this.index)
	}

	prevSelectionItem() {
		let item = this.currentItem() as MenuSelectionInterface
		const old = item.selected

		if (!Array.isArray(item.values)) return

		item.selected--

		if (item.selected < 0) item.selected = item.values.length - 1

		if (item.options?.onChange) item.onItemChange(item.selected, old, this.index)
	}

	activeItemChanged(oldIndex: number) {
		useAxios(`https://${resource()}/processActiveItemChange`, {
			method: 'POST',
			data: {
				current: this.index + 1,
				old: oldIndex + 1,
			},
		})
	}

	processClick(index?: number) {
		if (index !== undefined) {
			this.index = index
		}

		const item = this.currentItem()

		let value: {
			index: number
			selection?: {
				index: number
				value: any
			}
		} = {
			index: this.index + 1,
		}

		if (item.component === 'selection' && 'values' in item) {
			value.selection = {
				index: item.selected + 1,
				value: item.values[item.selected],
			}
		}

		if (item.options?.menu) {
			lastMenus.push(this.id)

			useAxios(`https://${resource()}/openSubMenu`, {
				method: 'POST',
				data: {
					id: item.options.menu,
				},
			})

			return
		}

		useAxios(`https://${resource()}/processClick`, {
			method: 'POST',
			data: value,
		})
	}

	returnBack() {
		const { apps } = useApp()

		if (lastMenus.length > 0) {
			const id = lastMenus.pop()

			useAxios(`https://${resource()}/openSubMenu`, {
				method: 'POST',
				data: {
					id,
				},
			})

			return
		}

		useAxios(`https://${resource()}/closeMenu`, {
			method: 'POST',
		})

		apps.menu = false
	}
}

class MenuItem implements MenuItemInferface {
	public component: string = 'button'
	public visible: boolean = true

	constructor(public title: string, public description?: string, public options?: { [key: string]: any }) {}

	bind() {
		return {
			title: this.title,
			description: this.description,
			visible: this.visible,
			arrow: this.options?.arrow || true,
			image: this.options?.image || null,
			icon: this.options?.icon || null,
			menu: this.options?.menu || null,
			metadata: this.options?.metadata || null,
			disabled: this.options?.disabled || null,
		}
	}
}

class MenuSelection implements MenuSelectionInterface {
	public component: string = 'selection'
	public visible: boolean = true

	constructor(public title: string, public values: any[], public selected: number = 0, public options?: { [key: string]: any }) {}

	bind() {
		return {
			title: this.title,
			values: this.values || ['None'],
			visible: this.visible,
			metadata: this.options?.metadata || null,
			selected: this.selected,
		}
	}

	onItemChange(index: number, old: number, currentIndex: number) {
		useAxios(`https://${resource()}/processListItemChange`, {
			method: 'POST',
			data: {
				index: currentIndex + 1,
				current: index + 1,
				old: old + 1,
			},
		})
	}
}

export { Menu, MenuItem, MenuSelection, type MenuItemInferface, type MenuSelectionInterface, lastMenus, setLastMenus }
