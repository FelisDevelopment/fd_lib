<template>
	<transition
		enter-active-class="duration-300 ease-out"
		enter-from-class="transform opacity-0"
		enter-to-class="opacity-100"
		leave-active-class="duration-200 ease-in"
		leave-from-class="opacity-100"
		leave-to-class="transform opacity-0"
	>
		<div class="absolute bottom-1/4 left-1/2 flex -translate-x-1/2 transform items-center justify-center gap-2 rounded-md bg-base-300/90 px-4 py-2 text-base-content" v-if="apps.progressCircle">
			<div class="radial-progress" :class="progress?.classes || []" :style="styles">
				<i :class="progress?.icon" v-if="progress?.icon"></i>
			</div>
			<span v-if="progress?.label" class="p-2 text-lg font-semibold" :class="progress?.labelClasses" v-html="progress?.label"></span>
		</div>
	</transition>
</template>
<script setup lang="ts">
import { inject, computed } from 'vue'

import { useApp } from '../stores/app'
import { useLocale } from '../stores/locale'

const emitter: any = inject('emitter')

const { apps } = useApp()
const { ui } = useLocale()

interface Progress {
	duration: number
	label?: string
	style?: { [key: string]: any }
	classes?: string[]
	labelClasses?: string[]
	icon?: string[]
}

let progress = $ref<Progress | null>()

let data = $ref<{
	interval?: any
	width: number
	cancelled?: boolean
	timeout?: any
}>({
	width: 0,
})

const styles = computed(() => {
	return {
		...progress?.style,
		'--value': data.width,
	}
})

function reset() {
	data = {
		width: 0,
		cancelled: false,
		interval: null,
	}

	progress = null

	clearTimeout(data.timeout)
}

function close(timeout = 0) {
	setTimeout(() => {
		apps.progressCircle = false
	}, timeout)
}

function startProgress() {
	data.interval = setInterval(() => {
		data.width++

		if (data.width >= 100) {
			clearInterval(data.interval)
			setTimeout(() => {
				close()
			}, 200)
		}
	}, (progress?.duration ?? 0) / 100)
}

function cancelProgress() {
	data.cancelled = true

	clearInterval(data.interval)

	data.width = 100

	if (progress) {
		progress.classes = ['text-error']
		progress.labelClasses = ['text-error']
		progress.label = ui.cancelled
	}

	data.timeout = setTimeout(() => {
		close()
	}, 1000)
}

emitter.on('progressCircle:open', async (event: Progress) => {
	reset()

	apps.progressCircle = true
	progress = event

	if (!progress?.style) {
		progress.style = {
			'--size': '3rem',
		}
	}

	startProgress()
})

emitter.on('progressCircle:close', () => {
	if (!progress) {
		return
	}

	close()
})

emitter.on('progressCircle:cancel', () => {
	cancelProgress()
})
</script>
