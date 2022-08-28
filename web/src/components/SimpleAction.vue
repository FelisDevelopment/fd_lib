<template>
	<transition
		enter-active-class="duration-350 ease-linear"
		:enter-from-class="enterFromClass"
		:enter-to-class="enterToClass"
		leave-active-class="duration-250 ease-linear"
		:leave-from-class="leaveFromClass"
		:leave-to-class="leaveToClass"
	>
		<div v-show="apps.simpleAction" class="fixed transform select-none flex-col items-center gap-2 rounded-md bg-base-300 p-3 transition duration-300 ease-linear" :class="position">
			<div class="flex items-center gap-2">
				<kbd class="kbd" :class="data.settings?.kbdClasses">{{ data.button?.toUpperCase() }}</kbd>
				<span class="text-base-content" :class="data.settings?.textClasses">{{ data.text }}</span>
			</div>
			<span class="text-sm text-base-content/80" v-html="data.description"></span>
		</div>
	</transition>
</template>
<script setup lang="ts">
import { inject, computed } from 'vue'

// Import Store
import { useApp } from '../stores/app'

const emitter: any = inject('emitter')

const { apps } = useApp()

interface SimpleAction {
	button: string
	text: string
	description?: string
	settings?: {
		kbdClasses?: string[]
		textClasses?: string[]
		position?: string
	}
}

const data = $ref<SimpleAction>({
	button: '',
	text: '',
	description: 'testing this shit',
})

const position = computed(() => {
	switch (data.settings?.position) {
		case 'left-center':
			return ['top-1/2', 'right-0', 'mr-3', '-translate-y-1/2']
		case 'top-center':
			return ['mt-10', 'left-1/2', '-translate-x-1/2']
		default:
			return ['top-1/2', 'left-0', 'ml-3', '-translate-y-1/2']
	}
})

const enterFromClass = computed(() => {
	switch (data.settings?.position) {
		case 'left-center':
			return 'transform translate-x-[100vw]'
		case 'top-center':
			return 'transform -translate-y-[100vh]'
		default:
			return 'transform -translate-x-[100vw]'
	}
})

const enterToClass = computed(() => {
	switch (data.settings?.position) {
		case 'left-center':
			return 'translate-x-0'
		case 'top-center':
			return 'translate-y-0'
		default:
			return 'translate-x-0'
	}
})

const leaveFromClass = computed(() => {
	switch (data.settings?.position) {
		case 'left-center':
			return 'translate-x-0'
		case 'top-center':
			return 'translate-y-0'
		default:
			return 'translate-x-0'
	}
})

function reset() {
	apps.simpleAction = false
}

const leaveToClass = computed(() => {
	switch (data.settings?.position) {
		case 'left-center':
			return 'transform translate-x-[100vw]'
		case 'top-center':
			return 'transform -translate-y-[100vh]'
		default:
			return 'transform -translate-x-[100vw]'
	}
})

emitter.on('simpleAction:open', (event: any) => {
	apps.simpleAction = true

	data.button = event.button ?? '-'
	data.text = event.text ?? 'No Content Provided'
	data.settings = event.settings ?? {}
	data.description = event.description ?? ''
})

emitter.on('simpleAction:close', () => {
	reset()
})
</script>
