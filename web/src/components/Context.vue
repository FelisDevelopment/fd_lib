<template>
	<transition
		enter-active-class="duration-300 ease-out"
		enter-from-class="transform opacity-0"
		enter-to-class="opacity-100"
		leave-active-class="duration-200 ease-in"
		leave-from-class="opacity-100"
		leave-to-class="transform opacity-0"
	>
		<div class="relative max-h-[60vh] min-h-[60vh] w-1/2 min-w-[50%] 2k:w-1/3 2k:min-w-[33.333333%]" v-if="apps.context">
			<div class="absolute -top-3 -right-3 z-50 flex h-7 w-7 items-center justify-center rounded-full bg-base-300" @click.stop="closeContext()">
				<i class="fa-solid fa-xmark text-base-content/70 transition duration-150 ease-linear hover:text-base-content"></i>
			</div>
			<div class="relative flex max-h-[60vh] min-h-[60vh] w-full flex-1 overflow-hidden rounded-md bg-base-300/90">
				<div class="scl flex w-1/4 max-w-[25%] flex-1 flex-col overflow-y-auto overflow-x-hidden bg-base-100/90 py-2">
					<div class="flex flex-col justify-center gap-1 p-2" v-if="(data?.buttons?.length ?? 0) > 0">
						<button
							v-for="(button, index) in data?.buttons"
							class="btn btn-primary btn-sm"
							:class="button.classes ?? []"
							v-html="button.label"
							@click="triggerButtonAction(index + 1)"
						></button>
					</div>
					<ul class="menu w-full">
						<div class="" v-for="(menu, index) in tabsMenu">
							<li class="menu-title pt-2" v-if="index !== 'nocategory'">
								<span v-html="menu.label"></span>
							</li>
							<li v-for="link in menu.items" @click.native="openTab(link.link)" class="relative">
								<a :class="{ active: link.link === activeTab }" v-html="link.label"></a>
								<i
									v-if="link.close"
									class="fa-solid fa-xmark absolute top-1/2 right-0 z-50 -translate-y-1/2 transform transition duration-150 ease-linear"
									:class="{
										'text-base-content/70': link.link !== activeTab,
										'hover:text-base-content': link.link !== activeTab,
										'text-primary-content/70': link.link === activeTab,
										'hover:text-primary-content': link.link === activeTab,
									}"
									@click.stop="tabLinkClose(link.realIndex)"
								></i>
							</li>
						</div>
					</ul>
				</div>
				<div class="scl flex w-3/4 flex-col gap-3 overflow-y-auto overflow-x-hidden p-2" v-for="(tab, index) in tabs" :key="(tab as ContextTab).id ?? index" v-show="index === activeTab">
					<section v-for="(section, sectionIndex) in (tab as ContextTab).sections" :key="`${sectionIndex}`">
						<div class="shadow sm:rounded-md">
							<div class="bg-base-100 py-6 px-4 sm:p-6">
								<div>
									<h2 class="text-lg font-medium leading-6 text-base-content" v-html="section?.title"></h2>
									<p class="mt-1 text-sm text-base-content/60" v-html="section?.description"></p>
								</div>

								<div class="mt-6 flex flex-col gap-6">
									<component
										v-if="section.components"
										v-for="(component, componentIndex) in section.components"
										:key="`${componentIndex}`"
										:is="inputTypes[component.type]"
										v-bind="component.options ?? []"
										v-model="component.value"
									></component>
								</div>
							</div>
							<div class="bg-base-200 px-4 py-3 text-right sm:px-6" v-if="section.submit">
								<button type="submit" class="btn btn-primary btn-sm" @click.stop="submitSectionForm(index as number, sectionIndex)">{{ locale.t('submit') }}</button>
							</div>
						</div>
					</section>
				</div>
			</div>
		</div>
	</transition>
</template>
<script setup lang="ts">
import { computed, inject } from 'vue'

// Import interfaces
import type { ContextData, ContextTab, InputTypes } from '..//interfaces/dialog.interface'

// Import Store
import { useApp } from '../stores/app'
import { useLocale } from '../stores/locale'

// Import necessary components
import { useAxios } from '@vueuse/integrations/useAxios'

import Input from './Dialog/Input.vue'
import Sepator from './Dialog/Sepator.vue'
import TextArea from './Dialog/TextArea.vue'
import Checkbox from './Dialog/Checkbox.vue'
import Radio from './Dialog/Radio.vue'
import Select from './Dialog/Select.vue'
import Switch from './Dialog/Switch.vue'
import Range from './Dialog/Range.vue'
import Text from './Dialog/Text.vue'

const { apps } = useApp()
const locale = useLocale()

const resource: string | undefined = inject('resource')
const emitter: any = inject('emitter')

// Define Input Types
const inputTypes = {
	input: Input,
	sepator: Sepator,
	textarea: TextArea,
	checkbox: Checkbox,
	radio: Radio,
	select: Select,
	switch: Switch,
	range: Range,
	text: Text,
} as InputTypes

let data = $ref<ContextData | null>()
let activeTab = $ref<string>()
let tabsMenu = $ref<{ [key: string]: any }>({})
let tabs = $ref<{ [key: string]: ContextTab }>()

const snakeCase = (string: string) =>
	string
		.split(/(?=[A-Z])/)
		.join('_')
		.replace(/\s/g, '')
		.toLowerCase()

function openTab(tab: string) {
	activeTab = tab
}

function closeContext() {
	emitter.emit('context:close')
}

function triggerButtonAction(index: number) {
	useAxios(`https://${resource}/contextButtonTriggered`, {
		method: 'POST',
		data: {
			index: index,
		},
	})
}

function tabLinkClose(tabIndex: number) {
	useAxios(`https://${resource}/tabCloseTriggered`, {
		method: 'POST',
		data: {
			index: tabIndex,
		},
	})
}

function submitSectionForm(tabIndex: number, sectionIndex: number) {
	const tab = tabs[tabIndex]
	const form = tab?.sections[sectionIndex].components ?? null

	useAxios(`https://${resource}/sectionSubmit`, {
		method: 'POST',
		data: {
			data: form,
			tab: tab.id,
			section: sectionIndex + 1,
		},
	})
}

emitter.on('context:open', (event: ContextData) => {
	tabsMenu = {}
	tabs = {}

	data = event
	let temp = 0

	if (!apps.context) {
		useAxios(`https://${resource}/enableFocus`, {
			method: 'POST',
			data: {
				isFocused: true,
				cursorToggle: true,
				keepInput: false,
			},
		})
	}

	apps.context = true

	if (event.tabs) {
		event.tabs.forEach((tab, index) => {
			const category = tab.category ? snakeCase(tab.category) : `nocategory`

			if (!tabsMenu[category]) {
				tabsMenu[category] = {
					label: tab.category,
					items: [],
				}
			}

			if (!tabs) {
				tabs = {}
			}

			let tabIndicator = `tab-${category}-${snakeCase(tab.label)}-${temp}`

			tabsMenu[category].items.push({
				label: tab.label,
				link: tabIndicator,
				close: tab.close,
				realIndex: index + 1,
			})

			temp++

			tabs[tabIndicator] = tab
			tabs[tabIndicator].id = index + 1
		})
	}
})

emitter.on('context:close', () => {
	apps.context = false
	data = null
	activeTab = ''
	tabsMenu = {}
	tabs = {}
	// activeTabIndex = null

	useAxios(`https://${resource}/enableFocus`, {
		method: 'POST',
		data: {
			isFocused: false,
			cursorToggle: false,
			keepInput: false,
		},
	})
})
</script>
