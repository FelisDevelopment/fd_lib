<template>
	<transition
		enter-active-class="duration-300 ease-out"
		enter-from-class="transform opacity-0"
		enter-to-class="opacity-100"
		leave-active-class="duration-200 ease-in"
		leave-from-class="opacity-100"
		leave-to-class="transform opacity-0"
	>
		<div class="alert absolute top-1/4 left-1/2 min-w-[30rem] max-w-xl -translate-x-1/2 transform items-start overflow-hidden bg-base-300/80" v-if="apps.kbdAction">
			<div class="absolute top-0 left-0 h-1 bg-primary/50" :style="width"></div>
			<div class="flex-1 items-start">
				<span :class="kbd?.labelClasses || []" v-html="kbd?.label"></span>
			</div>
			<div class="flex items-start gap-2">
				<button class="btn btn-primary btn-sm flex-nowrap gap-2">
					<kbd class="kbd kbd-sm bg-neutral text-neutral-content">Y</kbd>
					<span>{{ locale.t('accept') }}</span>
				</button>
				<button class="btn btn-ghost btn-sm gap-2">
					<kbd class="kbd kbd-sm bg-neutral text-neutral-content">N</kbd>
					<span>{{ locale.t('deny') }}</span>
				</button>
			</div>
		</div>
	</transition>
</template>
<script setup lang="ts">
import { inject, computed } from 'vue'

// Import Store
import { useApp } from '../stores/app'
import { useLocale } from '../stores/locale'

const emitter: any = inject('emitter')

const { apps } = useApp()
const locale = useLocale()

let kbd = $ref<{
	label: string
	labelClasses?: string[]
	timeout?: number
}>()

let data = $ref<{
	width: number
	interval?: any
}>({
	width: 100,
})

const width = computed(() => {
	return `width: ${data.width}%`
})

emitter.on('kbdAction:open', (event: any) => {
	if (data.interval) clearInterval(data.interval)
	data.width = 100

	apps.kbdAction = true

	kbd = event

	data.interval = setInterval(() => {
		data.width--
	}, (kbd.timeout ?? 0) / 100)
})

emitter.on('kbdAction:close', () => {
	apps.kbdAction = false

	clearInterval(data.interval)

	kbd = {
		label: '',
	}
})
</script>
