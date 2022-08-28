<template>
	<transition
		enter-active-class="duration-300 ease-out"
		enter-from-class="transform opacity-0"
		enter-to-class="opacity-100"
		leave-active-class="duration-200 ease-in"
		leave-from-class="opacity-100"
		leave-to-class="transform opacity-0"
	>
		<div class="absolute bottom-1/4 left-1/2 h-[3.5vh] -translate-x-1/2 transform" v-if="apps.progressBar">
			<progress class="progress h-[3.5vh] w-[15vw] bg-base-300/40" :value="progress?.withValue ? data.width : undefined" max="100" :class="progress?.classes || ['progress-primary']"></progress>
			<span
				class="absolute top-1/2 left-1/2 -translate-y-1/2 -translate-x-1/2 transform text-base font-semibold text-base-content"
				:class="{ 'text-primary-content': data.width > 55, 'text-error-content': data.cancelled }"
				v-html="`${progress?.label}` || ''"
			></span>
		</div>
	</transition>
</template>
<script setup lang="ts">
import { inject } from 'vue'
// Import Store
import { useApp } from '../stores/app'
import { useLocale } from '../stores/locale'

const emitter: any = inject('emitter')

const { apps } = useApp()
const { ui } = useLocale()

interface Progress {
	duration: number
	label: string
	withValue?: boolean
	classes?: string[]
	labelClasses?: string[]
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

function startProgress() {
	data.interval = setInterval(() => {
		if (progress?.withValue) data.width++

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
		progress.classes = ['progress-error']
		progress.label = ui.cancelled
	}

	data.timeout = setTimeout(() => {
		close()
	}, 1000)
}

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
		apps.progressBar = false
	}, timeout)
}

emitter.on('progressBar:open', async (event: Progress) => {
	reset()

	apps.progressBar = true
	progress = event

	if (event.withValue === undefined) {
		progress.withValue = true
	}

	startProgress()
})

emitter.on('progressBar:close', () => {
	if (!progress) {
		return
	}

	close()
})

emitter.on('progressBar:cancel', () => {
	cancelProgress()
})
</script>
