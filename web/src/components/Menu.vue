<template>
	<transition
		enter-active-class="duration-300 ease-out"
		enter-from-class="transform opacity-0"
		enter-to-class="opacity-100"
		leave-active-class="duration-200 ease-in"
		leave-from-class="opacity-100"
		leave-to-class="transform opacity-0"
	>
		<div class="absolute top-1/4 right-1/4 z-50 flex min-w-[20rem] max-w-[30rem] flex-col gap-3" v-if="apps.menu">
			<div class="flex flex-1 space-x-1.5">
				<div v-if="menu?.title || menu?.description" class="flex flex-1 flex-col items-center justify-center rounded-md bg-base-300/90 p-3">
					<span class="w-full select-none text-center font-semibold text-base-content" v-html="menu?.title"></span>
					<span class="prose-sm w-full text-left text-xs text-base-content prose-p:mt-1 prose-p:mb-0 prose-li:my-1" v-html="marked.parse(menu?.description || '')"></span>
				</div>
				<div
					class="flex flex-shrink-0 items-center justify-center rounded-md bg-base-300/90 px-4 py-2 text-base-content transition duration-150 ease-linear hover:bg-primary/80 hover:text-primary-content"
					@click.prevent="menu?.returnBack()"
				>
					<i v-if="lastMenus.length === 0" class="gg-close text-xl"></i>
					<i v-if="lastMenus.length > 0" class="gg-arrow-left text-xl"></i>
				</div>
			</div>
			<search v-if="search" v-model="searchModel"></search>
			<div class="space-y-1">
				<component
					v-for="(item, index) in menu?.items"
					:is="components[item.component]"
					v-bind="item.bind()"
					:key="index"
					:index="index"
					:currentIndex="menu?.index"
					@click="menu?.processClick(index)"
					@mouseover.native="menu?.changeIndex(index)"
				></component>
			</div>
		</div>
	</transition>
</template>

<script setup lang="ts">
import { inject, watch, onMounted, type Component } from 'vue'
import { marked } from 'marked'

import { Menu, MenuItem, MenuSelection, type MenuItemInferface, type MenuSelectionInterface, lastMenus, setLastMenus } from './Menu/menu.func'

// Import Store
import { useApp } from '../stores/app'

// Import components
import Button from './Menu/Button.vue'
import Selection from './Menu/Selection.vue'
import Search from './Menu/Search.vue'

const emitter: any = inject('emitter')

const { apps } = useApp()

const components: { [key: string]: Component } = {
	button: Button,
	selection: Selection,
}

let search = $ref<boolean>(false)
let searchModel = $ref<string>()

let menu = $ref<Menu | null>()

onMounted(async () => {
	window.addEventListener('wheel', (e) => {
		if (!apps.menu || !menu) return

		let delta = e.deltaY || e.detail

		if (delta > 0) {
			menu.index++
		} else if (delta < 0) {
			menu.index--
		}
	})

	window.addEventListener('contextmenu', (e) => {
		// Right-click
		if (!apps.menu || !menu) return

		e.preventDefault()

		menu.returnBack()
	})

	window.addEventListener('keydown', (e) => {
		if (!apps.menu || !menu) return
		if (e.keyCode == 38) {
			// UP
			menu.index--
		} else if (e.keyCode == 40) {
			// DOWN
			menu.index++
		} else if (e.keyCode == 13) {
			// ENTER
			menu.processClick()
		} else if (e.keyCode == 8) {
			// BACKSPACE
			menu.returnBack()
		}

		if (menu.currentItem() != null) {
			if (e.keyCode == 37) {
				// LEFT
				menu.prevSelectionItem()
			} else if (e.keyCode == 39) {
				// RIGHT
				menu.nextSelectionItem()
			}
		}

		return false
	})
})

watch(
	() => menu?.index,
	(_, old) => menu?.updateVisibleItems(old ?? 0)
)

watch(
	() => searchModel,
	(_, old) => menu?.findItem(searchModel)
)

emitter.on('menu:open', async (data: any) => {
	apps.menu = true
	let items: (MenuItemInferface | MenuSelectionInterface)[] = []

	await Promise.all(
		data.items.map((item: MenuItemInferface | MenuSelectionInterface) => {
			if (item.component === 'selection' && 'values' in item) {
				const options = item.options || {}

				if (item.onChange) {
					options.onChange = true
				}

				items.push(new MenuSelection(item.title, item.values, item.selected || 0, options))
				return
			}

			const options = item.options || {}

			if ('menu' in item) {
				options.menu = item.menu
			}

			items.push(new MenuItem(item.title, item.description, options))
		})
	)

	search = data.search ?? false

	menu = new Menu(data.id, data.title, items, data.description, data.onItemChange, data.limit, data.index)
})

emitter.on('menu:close', () => {
	apps.menu = false
	menu = null
	setLastMenus([])
})
</script>
