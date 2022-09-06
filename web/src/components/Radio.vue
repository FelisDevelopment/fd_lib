<template>
	<div
		class="absolute bottom-0 right-2 transform transition duration-150 ease-linear"
		:class="{
			'translate-y-[15vh]': app.apps.radio,
			'translate-y-[3500px]': !app.apps.radio,
		}"
	>
		<img :src="radio.getThemeFrame" class="h-[70vh] drop-shadow-2xl" />
		<div class="absolute top-[35.5%] left-[22.4%] bg-base-300 w-[55.2%] h-[30.35%] rounded-[6.2%] overflow-hidden z-10" ref="tabsList">
			<transition-group name="fade" mode="out-in">
				<component v-for="(component, index) in tabList" :is="component" :key="index" v-show="index === radio.currentTab" />
			</transition-group>
		</div>
	</div>
</template>
<script setup lang="ts">
import { inject, type Component } from 'vue'
//@ts-ignore
import { useKeypress } from 'vue3-keypress'

import { resource } from '@/utils'
import { useAxios } from '@vueuse/integrations/useAxios'

import Connection from './Radio/Connection.vue'
import Change from './Radio/Change.vue'
import List from './Radio/List.vue'

import { useApp } from '@/stores/app'
import { useRadio } from '@/stores/radio'

const emitter: any = inject('emitter')
const app = useApp()
const radio = useRadio()

const tabList: { [key: string]: Component } = {
	connection: Connection,
	change: Change,
	list: List,
}

function close(send?: boolean) {
	app.apps.radio = false

	if (send) {
		useAxios(`https://${resource()}/closeRadio`, {
			method: 'POST',
			data: false,
		})
	}
}

useKeypress({
	keyEvent: 'keyup',
	keyBinds: [
		{
			keyCode: 'esc',
			success: () => {
				if (app.apps.radio) {
					close(true)
				}
			},
		},
	],
})

emitter.on('radio:open', (event: any) => {
	app.apps.radio = true

	useAxios(`https://${resource()}/enableFocus`, {
		method: 'POST',
		data: {
			isFocused: true,
			cursorToggle: true,
			keepInput: event.keepInput,
		},
	})
})

emitter.on('radio:close', () => {
	close()
})

emitter.on('radio:changeTheme', (event: any) => {
	radio.theme = event.theme
})

emitter.on('radio:updateValues', (event: any) => {
	if (Object.keys(event).length <= 0) return

	for (const [key, value] of Object.entries(event)) {
		//@ts-ignore
		radio[key] = value
	}
})
</script>
