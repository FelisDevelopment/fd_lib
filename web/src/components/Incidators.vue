<template>
	<div class="fixed flex gap-1" :style="app.getLeftPosition" v-show="!app.hudForcefullyHidden">
		<transition-group
			enter-active-class="duration-300 ease-out"
			enter-from-class="transform opacity-0"
			enter-to-class="opacity-100"
			leave-active-class="duration-200 ease-in"
			leave-from-class="opacity-100"
			leave-to-class="transform opacity-0"
		>
			<div
				class="indicator relative flex h-7 min-w-[1.75rem] flex-shrink-0 items-center justify-center rounded-md bg-base-300/70 2xl:h-10 2xl:min-w-[2.5rem] 2k:h-12 2k:min-w-[3rem]"
				v-for="indicator in filteredIndicators"
				:key="indicator.uuid"
				v-show="indicator.shown"
			>
				<span v-if="indicator.stack > 1" class="badge indicator-item badge-secondary">{{ indicator.stack }}</span>
				<div
					class="absolute bottom-0 transform rounded-b-md transition-all duration-100 ease-linear"
					:class="[indicator.bg || 'bg-primary', indicator.horizontal ? 'left-0' : 'bottom-0', indicator.value >= 95 ? `rounded-t-md` : ``]"
					:style="[`height: ${indicator.horizontal ? 100 : indicator.value}%;`, `width: ${indicator.horizontal ? indicator.value : 100}%;`]"
				></div>
				<div class="flex items-center justify-center gap-2 text-sm text-base-content 2xl:text-base" :class="{ 'px-4': indicator.text }">
					<i class="z-10" :class="indicator.icon"></i>
					<span class="z-10" v-html="indicator.text" v-if="indicator.text"></span>
				</div>
			</div>
		</transition-group>
		<!-- <div
			class="fixed bg-black/50"
			:style="[`width: ${app.minimap?.width ?? 0}px;`, `height: ${app.minimap?.height ?? 0}px;`, `top: ${app.minimap?.top ?? 0}px;`, `left: ${app.minimap?.left ?? 0}px;`]"
		></div> -->
	</div>
</template>
<script setup lang="ts">
import { inject, computed } from 'vue'
import { useApp } from '@/stores/app'

const emitter: any = inject('emitter')

const app = useApp()

interface Indicator {
	uuid: string
	icon: string
	value: number
	bg?: string
	position?: number
	shown: boolean
	horizontal?: boolean
	text?: string
	timeout?: number
	duration?: number
	notification?: boolean
	timer?: boolean
	stack: number
}

interface Indicators {
	[key: string]: Indicator
}

let indicators = $ref<Indicators>({})

const filteredIndicators = computed(() => {
	return Object.fromEntries(
		Object.entries(indicators).sort(([, a], [, b]) => {
			if (!a.position) {
				a.position = Object.keys(indicators).length + 99
			}

			if (!b.position) {
				b.position = Object.keys(indicators).length + 99
			}

			return a.position - b.position
		})
	)
})

emitter.on('indicators:open', async (event: any) => {
	if (event.uuid) {
		const indicator = indicators[event.uuid] as Indicator

		indicator.shown = true

		if (indicator.notification) {
			if (indicator.timeout) {
				indicator.stack++
			}

			clearTimeout(indicator.timeout)
			indicator.value = 100

			indicator.timeout = setTimeout(() => {
				clearTimeout(indicator.timeout)
				indicator.timeout = 0

				indicator.stack = 1
				indicator.shown = false
			}, indicator.duration ?? 2000)

			return
		}

		if (indicator.timer) {
			if (indicator.timeout) {
				indicator.stack++
			}

			clearInterval(indicator.timeout)
			indicator.value = 100

			indicator.timeout = setInterval(async () => {
				indicator.value--

				if (indicator.value <= 0) {
					clearInterval(indicator.timeout)
					indicator.timeout = 0

					indicator.shown = false
				}
			}, (indicator.duration ?? 2000) / 100.0)
		}
	}
})

emitter.on('indicators:register', async (event: any) => {
	if (event.uuid) {
		//@ts-ignore
		indicators[event.uuid] = event
		indicators[event.uuid].stack = 1
	}
})

emitter.on('indicators:update', async (event: any) => {
	if (event.uuid) {
		//@ts-ignore
		indicators[event.uuid][event.key] = event.value
	}
})

emitter.on('indicators:delete', async (event: any) => {
	if (event.uuid) {
		//@ts-ignore
		delete indicators[event.uuid]
	}
})

emitter.on('indicators:close', async (event: any) => {
	if (event.uuid) {
		indicators[event.uuid].shown = false

		if (indicators[event.uuid].timeout) {
			clearTimeout(indicators[event.uuid].timeout)
			clearInterval(indicators[event.uuid].timeout)
		}
	}
})
</script>
